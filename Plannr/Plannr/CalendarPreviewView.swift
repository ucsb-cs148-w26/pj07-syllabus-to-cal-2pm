//
//  CalendarPreviewView.swift
//  Plannr
//
//  Created by divyani punj on 1/29/26.
//

import SwiftUI

struct CalendarPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classManager: ClassManager
    
    let className: String
    let classSchedule: String
    let classColor: Color
    
    @State private var events: [CalendarEvent]
    @State private var editingEvent: CalendarEvent?
    @State private var isSyncing = false
    @State private var syncMessage: String?
    @State private var syncSuccess: Bool?
    @State private var showSyncAlert = false
    @State private var showExportOptions = false
    @State private var isExporting = false
    @State private var exportItem: ExportItem?
    @State private var exportErrorMessage: String?
    @State private var showExportError = false
    @State private var sharedEventColor: Color
    
    init(className: String, classSchedule: String, classColor: Color, events: [CalendarEvent]) {
        self.className = className
        self.classSchedule = classSchedule
        self.classColor = classColor
        _events = State(initialValue: events)
        _sharedEventColor = State(initialValue: classColor)
    }

    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Class name header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(className)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if !classSchedule.isEmpty {
                                Text(classSchedule)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)

                        CalendarGridView(events: events, sharedEventColor: sharedEventColor)
                            .padding(.horizontal)

                        // Accept All / Decline All buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                for index in events.indices {
                                    events[index].status = .accepted
                                }
                            }) {
                                Text("Accept All")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                for index in events.indices {
                                    events[index].status = .declined
                                }
                            }) {
                                Text("Decline All")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)

                        Text("Your Events")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        Text("\(events.count) items found")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        // Shared event color picker
                        HStack {
                            Text("Event Color")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                            ColorPicker("", selection: $sharedEventColor)
                                .labelsHidden()
                        }
                        .padding(.horizontal)

                        // Events list
                        VStack(spacing: 12) {
                            ForEach(events.indices, id: \.self) { index in
                                EventCard(
                                    event: events[index],
                                    colorOverride: sharedEventColor,
                                    onEdit: {
                                        editingEvent = events[index]
                                    },
                                    onAccept: {
                                        events[index].status = events[index].status == .accepted ? .pending : .accepted
                                    },
                                    onDecline: {
                                        events[index].status = events[index].status == .declined ? .pending : .declined
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 16)
                }

                // Sticky Sync button
                Button(action: {
                    syncToCalendar()
                }) {
                    HStack(spacing: 8) {
                        if isSyncing {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isSyncing ? "Syncing..." : "Sync!")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSyncing ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isSyncing)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.black)
            }
            .sheet(item: $editingEvent) { event in
                EventEditView(event: event) { updatedEvent in
                    if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
                        events[index] = updatedEvent
                    }
                    editingEvent = nil
                }
            }
            .alert(syncSuccess == true ? "Sync Complete" : "Sync Failed", isPresented: $showSyncAlert) {
                Button("OK", role: .cancel) {
                    if syncSuccess == true {
                        // Save class and navigate home
                        let newClass = Class(
                            name: className,
                            schedule: classSchedule,
                            colorHex: sharedEventColor.toHex(),
                            events: events.filter { $0.status == .accepted }
                        )
                        classManager.addClass(newClass)
                        
                        // Dismiss all the way to root (COULDN'T TEST THIS)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            // Pop to root view controller
                            if let navController = rootVC as? UINavigationController {
                                navController.popToRootViewController(animated: true)
                            }
                        }

                        // Dismiss back to home
                        dismiss()
                    }
                }
            } message: {
                Text(syncMessage ?? "")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isSyncing)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showExportOptions = true
                } label: {
                    if isExporting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
                .disabled(isExporting || isSyncing)
            }
        }
        .confirmationDialog("Export Events", isPresented: $showExportOptions, titleVisibility: .visible) {
            Button("Export as .ics (Calendar)") { exportEvents(format: "ics") }
            Button("Export as .csv (Spreadsheet)") { exportEvents(format: "csv") }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose a format to download your events.")
        }
        .sheet(item: $exportItem) { item in
            ActivityViewController(activityItems: [item.url])
        }
        .alert("Export Failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportErrorMessage ?? "An unknown error occurred.")
        }
    }

    func exportEvents(format: String) {
        guard let email = UserDefaults.standard.string(forKey: "userEmail"),
              let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(BACKEND_URL)/export?email=\(encodedEmail)&format=\(format)") else {
            exportErrorMessage = "Could not determine your account email. Please sign in again."
            showExportError = true
            return
        }

        isExporting = true

        struct ExportRequestBody: Encodable {
            let events: [CalendarEvent]
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(ExportRequestBody(events: events))
        } catch {
            isExporting = false
            exportErrorMessage = "Failed to encode events."
            showExportError = true
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                await MainActor.run {
                    isExporting = false
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        let ext = format == "ics" ? "ics" : "csv"
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent("events.\(ext)")
                        do {
                            try data.write(to: tempURL)
                            exportItem = ExportItem(url: tempURL)
                        } catch {
                            exportErrorMessage = "Failed to save export file."
                            showExportError = true
                        }
                    } else if let body = try? JSONDecoder().decode([String: String].self, from: data),
                              let errorMsg = body["error"] {
                        exportErrorMessage = errorMsg
                        showExportError = true
                    } else {
                        exportErrorMessage = "Export failed. Please try again."
                        showExportError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportErrorMessage = "Network error: \(error.localizedDescription)"
                    showExportError = true
                }
            }
        }
    }

    func syncToCalendar() {
        let acceptedEvents = events.filter { $0.status == .accepted }

        if acceptedEvents.isEmpty {
            syncMessage = "No accepted events to sync. Please accept events before syncing."
            syncSuccess = false
            showSyncAlert = true
            return
        }

        guard let email = UserDefaults.standard.string(forKey: "userEmail"),
              let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(BACKEND_URL)/calendar?email=\(encodedEmail)") else {
            syncMessage = "Could not determine your account email. Please sign in again."
            syncSuccess = false
            showSyncAlert = true
            return
        }

        isSyncing = true

        struct SyncRequestBody: Encodable {
            let events: [CalendarEvent]
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(SyncRequestBody(events: acceptedEvents))
        } catch {
            isSyncing = false
            syncMessage = "Failed to encode events."
            syncSuccess = false
            showSyncAlert = true
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                await MainActor.run {
                    isSyncing = false
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        syncMessage = "Successfully added \(acceptedEvents.count) events to your calendar!"
                        syncSuccess = true
                    } else if let body = try? JSONDecoder().decode([String: String].self, from: data),
                              let errorMsg = body["error"] ?? body["detail"] {
                        syncMessage = errorMsg
                        syncSuccess = false
                    } else {
                        syncMessage = "Sync failed. Please try again."
                        syncSuccess = false
                    }
                    showSyncAlert = true
                }
            } catch {
                await MainActor.run {
                    isSyncing = false
                    syncMessage = "Network error: \(error.localizedDescription)"
                    syncSuccess = false
                    showSyncAlert = true
                }
            }
        }
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: CalendarEvent
    var colorOverride: Color?
    var onEdit: (() -> Void)?
    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?
    
    init(
        event: CalendarEvent,
        colorOverride: Color? = nil,
        onEdit: (() -> Void)? = nil,
        onAccept: (() -> Void)? = nil,
        onDecline: (() -> Void)? = nil
    ) {
        self.event = event
        self.colorOverride = colorOverride
        self.onEdit = onEdit
        self.onAccept = onAccept
        self.onDecline = onDecline
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                // Title
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Status badge (if accepted or declined)
                if event.status != .pending {
                    Text(event.status.rawValue.capitalized)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor(event.status))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text(event.type.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(colorOverride ?? event.color)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            // Date
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(event.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Description (if not empty)
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // Action buttons
            HStack(spacing: 8) {
                // Edit button
                Button(action: {
                    onEdit?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.caption)
                        Text("Edit")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.6))
                    .cornerRadius(8)
                }
                
                // Accept button
                Button(action: {
                    onAccept?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: event.status == .accepted ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption)
                        Text("Accept")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(event.status == .accepted ? Color.green : Color.green.opacity(0.6))
                    .cornerRadius(8)
                }
                
                // Decline button
                Button(action: {
                    onDecline?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: event.status == .declined ? "xmark.circle.fill" : "xmark.circle")
                            .font(.caption)
                        Text("Decline")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(event.status == .declined ? Color.red : Color.red.opacity(0.6))
                    .cornerRadius(8)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
    
    func statusColor(_ status: EventStatus) -> Color {
        switch status {
        case .pending:
            return .gray
        case .accepted:
            return .green
        case .declined:
            return .red
        }
    }
}

// MARK: - Event Edit View
struct EventEditView: View {
    @State private var editedEvent: CalendarEvent
    @State private var selectedDate: Date
    let onSave: (CalendarEvent) -> Void
    @Environment(\.dismiss) var dismiss

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(event: CalendarEvent, onSave: @escaping (CalendarEvent) -> Void) {
        _editedEvent = State(initialValue: event)
        _selectedDate = State(initialValue: Self.dateFormatter.date(from: event.date) ?? Date())
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("Event title", text: $editedEvent.title)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Date field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Type field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("Event type", text: $editedEvent.type)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextEditor(text: $editedEvent.description)
                                .frame(height: 100)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Save button
                        Button(action: {
                            editedEvent.date = Self.dateFormatter.string(from: selectedDate)
                            onSave(editedEvent)
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    let events: [CalendarEvent]
    let sharedEventColor: Color
    @State private var isWeekly = true
    
    var body: some View {
        VStack {
            // Toggle
            Picker("View", selection: $isWeekly) {
                Text("Week").tag(true)
                Text("Month").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()
            .onAppear {
                UISegmentedControl.appearance().setTitleTextAttributes(
                    [.foregroundColor: UIColor.white],
                    for: .normal)
                UISegmentedControl.appearance().setTitleTextAttributes(
                    [.foregroundColor: UIColor.darkGray],
                    for: .selected)
                UISegmentedControl.appearance().backgroundColor = UIColor.darkGray
            }
            
            if isWeekly {
                WeeklyCalendarView(events: events, sharedEventColor: sharedEventColor)
            } else {
                MonthlyCalendarView(events: events, sharedEventColor: sharedEventColor)
            }
        }
    }
}

// MARK: - Weekly Calendar View
struct WeeklyCalendarView: View {
    let events: [CalendarEvent]
    let sharedEventColor: Color
    @State private var selectedDate: Date = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            // Week header with navigation
            HStack {
                Button(action: { moveWeek(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(weekRangeText())
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { moveWeek(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Days of the week
            HStack(spacing: 4) {
                ForEach(daysInWeek(), id: \.self) { date in
                    DayColumn(
                        date: date,
                        events: eventsForDate(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        sharedEventColor: sharedEventColor
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 0)
            
            VStack(spacing: 12){
                ForEach(eventsForDate(selectedDate), id: \.title){
                    event in EventCard(event: event, colorOverride: sharedEventColor)
                }
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    func daysInWeek() -> [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    func moveWeek(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func weekRangeText() -> String {
        let days = daysInWeek()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        guard let first = days.first, let last = days.last else { return "" }
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
    
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let dateString = dateFormatter.string(from: date)
        return events.filter { $0.date == dateString }
    }
}

// MARK: - Day Column
struct DayColumn: View {
    let date: Date
    let events: [CalendarEvent]
    let isSelected: Bool
    let sharedEventColor: Color
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 6) {
            // Day name
            Text(dayName())
                .font(.caption2)
                .foregroundColor(.gray)
            
            // Day number
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .blue : .white)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(8)
            
            // Event dots
            if !events.isEmpty {
                HStack(spacing: 2) {
                    ForEach(events.prefix(3), id: \.title) { event in
                        Circle()
                            .fill(sharedEventColor)
                            .frame(width: 6, height: 6)
                    }
                }
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isSelected ? Color.white.opacity(0.05) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { onTap() }
    }
    
    func dayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Monthly Calendar View
struct MonthlyCalendarView: View {
    let events: [CalendarEvent]
    let sharedEventColor: Color
    @State private var selectedDate: Date = Date()
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with navigation
            HStack {
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(monthYearText())
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Day labels
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<startingWeekday(), id: \.self) { _ in
                    Text("")
                        .frame(height: 40)
                }
                
                ForEach(daysInMonth(), id: \.self) { date in
                    DayCell(
                        date: date,
                        events: eventsForDate(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        sharedEventColor: sharedEventColor
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 0)
            
            VStack(spacing: 12){
                ForEach(eventsForDate(selectedDate), id: \.title){
                    event in EventCard(event: event, colorOverride: sharedEventColor)
                }
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    func daysInMonth() -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        return (0..<range.count).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfMonth) }
    }
    
    func startingWeekday() -> Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return calendar.component(.weekday, from: startOfMonth) - 1
    }
    
    func moveMonth(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .month, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func monthYearText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let dateString = dateFormatter.string(from: date)
        return events.filter { $0.date == dateString }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isSelected: Bool
    let sharedEventColor: Color
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .blue : .white)
            
            if !events.isEmpty {
                Circle()
                    .fill(sharedEventColor)
                    .frame(width: 5, height: 5)
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { onTap() }
    }
}

// MARK: - Export Helpers

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        CalendarPreviewView(
            className: "Advanced Calculus",
            classSchedule: "MWF 10:00 AM",
            classColor: .blue,
            events: [
                CalendarEvent(title: "Midterm Exam", date: "2026-03-15", type: "exam", description: "Chapters 1-5"),
                CalendarEvent(title: "Homework 3", date: "2026-03-20", type: "homework", description: "Problems 1-10")
            ]
        )
        .environmentObject(ClassManager())
    }
}

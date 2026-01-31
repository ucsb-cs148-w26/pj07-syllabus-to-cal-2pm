//
//  CalendarPreviewView.swift
//  Plannr
//
//  Created by divyani punj on 1/29/26.
//

import SwiftUI

struct CalendarPreviewView: View {
    @State private var events: [CalendarEvent]
    @State private var editingEvent: CalendarEvent?
        
    init(events: [CalendarEvent]) {
        _events = State(initialValue: events)
    }

    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Calendar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    CalendarGridView(events: events)
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
                    
                    // Events list
                    VStack(spacing: 12) {
                        ForEach(events.indices, id: \.self) { index in
                            EventCard(
                                event: events[index],
                                onColorChange: { newColor in
                                    events[index].color = newColor
                                },
                                onEdit: {
                                    editingEvent = events[index]
                                },
                                onAccept: {
                                    events[index].status = .accepted
                                },
                                onDecline: {
                                    events[index].status = .declined
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .sheet(item: $editingEvent) { event in
                EventEditView(event: event) { updatedEvent in
                    if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
                        events[index] = updatedEvent
                    }
                    editingEvent = nil
                }
            }
        }
    }
    
    // Color based on event type
//    func colorForType(_ type: String) -> Color {
//        switch type.lowercased() {
//        case "homework": return .blue
//        case "exam": return .red
//        case "quiz": return .orange
//        case "lab": return .green
//        default: return .gray
//        }
//    }
}

struct EventCard: View {
    let event: CalendarEvent
    @State private var selectedColor: Color
    var onColorChange: ((Color) -> Void)?
    var onEdit: (() -> Void)?
    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?
    
    init(
        event: CalendarEvent,
        onColorChange: ((Color) -> Void)? = nil,
        onEdit: (() -> Void)? = nil,
        onAccept: (() -> Void)? = nil,
        onDecline: (() -> Void)? = nil
    ) {
        self.event = event
        self.onColorChange = onColorChange
        self.onEdit = onEdit
        self.onAccept = onAccept
        self.onDecline = onDecline
        _selectedColor = State(initialValue: event.color)
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
                
                // Color Picker Button
                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
                    .frame(width: 30, height: 30)
                    .onChange(of: selectedColor) { newColor in
                        onColorChange?(newColor)
                    }
                
                Text(event.type.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(selectedColor)
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

//    func colorForType(_ type: String) -> Color {
//        switch type.lowercased() {
//        case "homework": return .blue
//        case "exam": return .red
//        case "quiz": return .orange
//        case "lab": return .green
//        default: return .gray
//        }
//    }
}

struct EventEditView: View {
    @State private var editedEvent: CalendarEvent
    @State private var selectedColor: Color
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
        _selectedColor = State(initialValue: event.color)
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
                        
                        // Color picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.headline)
                                .foregroundColor(.white)
                            ColorPicker("Event Color", selection: $selectedColor)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Save button
                        Button(action: {
                            editedEvent.date = Self.dateFormatter.string(from: selectedDate)
                            editedEvent.color = selectedColor
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

struct CalendarGridView: View {
    let events: [CalendarEvent]
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
                WeeklyCalendarView(events: events)
            } else {
                MonthlyCalendarView(events: events)
            }
        }
    }
}

struct WeeklyCalendarView: View {
    let events: [CalendarEvent]
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
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 0)
            
            VStack(spacing: 12){
                ForEach(eventsForDate(selectedDate), id: \.title){
                    event in EventCard(event: event)
                }
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Helper functions for weekly view
    
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

struct DayColumn: View {
    let date: Date
    let events: [CalendarEvent]
    let isSelected: Bool
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
                            .fill(event.color)
                            .frame(width: 6, height: 6)
                    }
                }
            } else {
                // Placeholder to keep alignment
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
    
//    func colorForType(_ type: String) -> Color {
//        switch type.lowercased() {
//        case "homework": return .blue
//        case "exam": return .red
//        case "quiz": return .orange
//        case "lab": return .green
//        default: return .gray
//        }
//    }
}

struct MonthlyCalendarView: View {
    let events: [CalendarEvent]
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
                
                // Day cells
                ForEach(daysInMonth(), id: \.self) { date in
                    DayCell(
                        date: date,
                        events: eventsForDate(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 0)
            
            VStack(spacing: 12){
                ForEach(eventsForDate(selectedDate), id: \.title){
                    event in EventCard(event: event)
                }
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    
    // MARK: - Helper functions for monthly view
    
    func daysInMonth() -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        return (0..<range.count).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfMonth) }
    }
    
    func startingWeekday() -> Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return calendar.component(.weekday, from: startOfMonth) - 1  // 0 = Sunday
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

struct DayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .blue : .white)
            
            // Event dot
            if !events.isEmpty {
                Circle()
                    .fill(events.first?.color ?? .gray)
                    .frame(width: 5, height: 5)
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { onTap() }
    }
    
//    func colorForType(_ type: String) -> Color {
//        switch type.lowercased() {
//        case "homework": return .blue
//        case "exam": return .red
//        case "quiz": return .orange
//        case "lab": return .green
//        default: return .gray
//        }
//    }
}


#Preview {
    CalendarPreviewView(events: EventFixtures.sampleEvents)
}

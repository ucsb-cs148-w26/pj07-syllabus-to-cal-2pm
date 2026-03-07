//
//  UnifiedCalendarView.swift
//  Plannr
//
//  Unified calendar view showing events from all classes, color-coded by class.
//

import SwiftUI

// MARK: - Unified Event Model

struct UnifiedEvent: Identifiable {
    let id: UUID
    let event: CalendarEvent
    let classColor: Color
    let className: String

    init(event: CalendarEvent, classColor: Color, className: String) {
        self.id = event.id
        self.event = event
        self.classColor = classColor
        self.className = className
    }
}

// MARK: - Unified Calendar View

struct UnifiedCalendarView: View {
    @EnvironmentObject var classManager: ClassManager
    @State private var isWeekly = true
    @State private var selectedEvent: UnifiedEvent?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var allEvents: [UnifiedEvent] {
        classManager.classes.flatMap { cls in
            cls.events.map { UnifiedEvent(event: $0, classColor: cls.color, className: cls.name) }
        }
    }

    var upcomingEvents: [UnifiedEvent] {
        let todayString = dateFormatter.string(from: Date())
        return allEvents
            .filter { $0.event.date >= todayString }
            .sorted { $0.event.date < $1.event.date }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Class color legend
                if !classManager.classes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(classManager.classes) { cls in
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(cls.color)
                                        .frame(width: 10, height: 10)
                                    Text(cls.name)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Calendar toggle + grid
                VStack {
                    Picker("View", selection: $isWeekly) {
                        Text("Week").tag(true)
                        Text("Month").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onAppear {
                        UISegmentedControl.appearance().setTitleTextAttributes(
                            [.foregroundColor: UIColor.white], for: .normal)
                        UISegmentedControl.appearance().setTitleTextAttributes(
                            [.foregroundColor: UIColor.darkGray], for: .selected)
                        UISegmentedControl.appearance().backgroundColor = UIColor.darkGray
                    }

                    if isWeekly {
                        UnifiedWeeklyCalendarView(events: allEvents) { selectedEvent = $0 }
                    } else {
                        UnifiedMonthlyCalendarView(events: allEvents) { selectedEvent = $0 }
                    }
                }
                .padding(.horizontal)

                // Upcoming Events list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Upcoming Events")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    if upcomingEvents.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No upcoming events")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Upload syllabi to your classes to see events here.")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    } else {
                        ForEach(upcomingEvents) { unifiedEvent in
                            UnifiedEventCard(unifiedEvent: unifiedEvent) {
                                selectedEvent = unifiedEvent
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.top)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailSheet(unifiedEvent: event)
        }
    }
}

// MARK: - Event Detail Sheet

struct EventDetailSheet: View {
    let unifiedEvent: UnifiedEvent
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title block
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(unifiedEvent.classColor)
                                .frame(width: 5, height: 64)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(unifiedEvent.event.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(unifiedEvent.className)
                                    .font(.subheadline)
                                    .foregroundColor(unifiedEvent.classColor)
                            }
                        }

                        Divider().background(Color.gray.opacity(0.3))

                        // Details
                        DetailRow(icon: "calendar", label: "Date", value: formattedDate)
                        DetailRow(
                            icon: "tag",
                            label: "Type",
                            value: unifiedEvent.event.type.capitalized,
                            valueColor: unifiedEvent.classColor
                        )

                        if !unifiedEvent.event.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                Text(unifiedEvent.event.description)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }

    var formattedDate: String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        let display = DateFormatter()
        display.dateFormat = "EEEE, MMMM d, yyyy"
        if let date = parser.date(from: unifiedEvent.event.date) {
            return display.string(from: date)
        }
        return unifiedEvent.event.date
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .foregroundColor(valueColor)
            }
        }
    }
}

// MARK: - Unified Weekly Calendar View

struct UnifiedWeeklyCalendarView: View {
    let events: [UnifiedEvent]
    let onTapEvent: (UnifiedEvent) -> Void
    @State private var selectedDate: Date = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { moveWeek(-1) }) {
                    Image(systemName: "chevron.left").foregroundColor(.white)
                }
                Spacer()
                Text(weekRangeText())
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { moveWeek(1) }) {
                    Image(systemName: "chevron.right").foregroundColor(.white)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 4) {
                ForEach(daysInWeek(), id: \.self) { date in
                    UnifiedDayColumn(
                        date: date,
                        events: eventsForDate(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = date
                    }
                }
            }

            VStack(spacing: 12) {
                ForEach(eventsForDate(selectedDate)) { unifiedEvent in
                    UnifiedEventCard(unifiedEvent: unifiedEvent) {
                        onTapEvent(unifiedEvent)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }

    func daysInWeek() -> [Date] {
        let start = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    func moveWeek(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }

    func weekRangeText() -> String {
        let days = daysInWeek()
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        guard let first = days.first, let last = days.last else { return "" }
        return "\(f.string(from: first)) - \(f.string(from: last))"
    }

    func eventsForDate(_ date: Date) -> [UnifiedEvent] {
        let s = dateFormatter.string(from: date)
        return events.filter { $0.event.date == s }
    }
}

// MARK: - Unified Monthly Calendar View

struct UnifiedMonthlyCalendarView: View {
    let events: [UnifiedEvent]
    let onTapEvent: (UnifiedEvent) -> Void
    @State private var selectedDate: Date = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left").foregroundColor(.white)
                }
                Spacer()
                Text(monthYearText())
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right").foregroundColor(.white)
                }
            }
            .padding(.horizontal)

            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<startingWeekday(), id: \.self) { _ in
                    Text("").frame(height: 40)
                }
                ForEach(daysInMonth(), id: \.self) { date in
                    UnifiedDayCell(
                        date: date,
                        events: eventsForDate(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 0)

            VStack(spacing: 12) {
                ForEach(eventsForDate(selectedDate)) { unifiedEvent in
                    UnifiedEventCard(unifiedEvent: unifiedEvent) {
                        onTapEvent(unifiedEvent)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }

    func daysInMonth() -> [Date] {
        let start = calendar.date(
            from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        return (0..<range.count).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    func startingWeekday() -> Int {
        let start = calendar.date(
            from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return calendar.component(.weekday, from: start) - 1
    }

    func moveMonth(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .month, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }

    func monthYearText() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: selectedDate)
    }

    func eventsForDate(_ date: Date) -> [UnifiedEvent] {
        let s = dateFormatter.string(from: date)
        return events.filter { $0.event.date == s }
    }
}

// MARK: - Unified Day Column (for Weekly view)

struct UnifiedDayColumn: View {
    let date: Date
    let events: [UnifiedEvent]
    let isSelected: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 6) {
            Text(dayName())
                .font(.caption2)
                .foregroundColor(.gray)

            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .blue : .white)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(8)

            // Color-coded dots per class
            if !events.isEmpty {
                HStack(spacing: 2) {
                    ForEach(events.prefix(3)) { e in
                        Circle()
                            .fill(e.classColor)
                            .frame(width: 6, height: 6)
                    }
                }
            } else {
                Circle().fill(Color.clear).frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isSelected ? Color.white.opacity(0.05) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { onTap() }
    }

    func dayName() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }
}

// MARK: - Unified Day Cell (for Monthly view)

struct UnifiedDayCell: View {
    let date: Date
    let events: [UnifiedEvent]
    let isSelected: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .blue : .white)

            if !events.isEmpty {
                HStack(spacing: 2) {
                    ForEach(events.prefix(3)) { e in
                        Circle()
                            .fill(e.classColor)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { onTap() }
    }
}

// MARK: - Unified Event Card

struct UnifiedEventCard: View {
    let unifiedEvent: UnifiedEvent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(unifiedEvent.classColor)
                        .frame(width: 3, height: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(unifiedEvent.event.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(unifiedEvent.className)
                            .font(.caption)
                            .foregroundColor(unifiedEvent.classColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(unifiedEvent.event.type.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(unifiedEvent.classColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formattedDate(unifiedEvent.event.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if !unifiedEvent.event.description.isEmpty {
                    Text(unifiedEvent.event.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    func formattedDate(_ raw: String) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        let display = DateFormatter()
        display.dateFormat = "MMM d, yyyy"
        if let date = parser.date(from: raw) {
            return display.string(from: date)
        }
        return raw
    }
}

#Preview {
    let manager = ClassManager()
    manager.addClass(Class(name: "CS 148", schedule: "MWF 2pm", colorHex: "007AFF", events: [
        CalendarEvent(title: "Midterm", date: "2026-03-15", type: "exam", description: "Chapters 1-4"),
        CalendarEvent(title: "HW 3", date: "2026-03-20", type: "homework", description: "")
    ]))
    manager.addClass(Class(name: "Math 51", schedule: "TTh 10am", colorHex: "34C759", events: [
        CalendarEvent(title: "Quiz 2", date: "2026-03-15", type: "quiz", description: "Linear algebra")
    ]))
    return ZStack {
        Color.black.ignoresSafeArea()
        UnifiedCalendarView()
            .environmentObject(manager)
    }
}

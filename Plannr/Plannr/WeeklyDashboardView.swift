//
//  WeeklyDashboardView.swift
//  Plannr
//
//  Created for Week at a Glance dashboard
//


import SwiftUI


struct WeeklyDashboardView: View {
   @EnvironmentObject var classManager: ClassManager
   @EnvironmentObject var authManager: AuthManager
  
   @State private var currentWeek: Date = Date()
   @State private var showCompletedItems = true
   @State private var selectedFilter: EventFilter = .all
  
   enum EventFilter: String, CaseIterable {
       case all = "All"
       case exam = "exam"
       case homework = "homework"
       case lab = "lab"
       case quiz = "quiz"
       case other = "other"
      
       var displayName: String {
           switch self {
           case .all: return "All"
           case .exam: return "Exams"
           case .homework: return "Homework"
           case .lab: return "Labs"
           case .quiz: return "Quizzes"
           case .other: return "Other"
           }
       }
      
       var systemImage: String {
           switch self {
           case .all: return "list.bullet"
           case .exam: return "doc.text"
           case .homework: return "pencil"
           case .lab: return "flask"
           case .quiz: return "questionmark.circle"
           case .other: return "circle"
           }
       }
   }
  
   var body: some View {
       ZStack {
           Color.black.ignoresSafeArea()
          
           VStack(spacing: 0) {
               // Header with week navigation
               weekHeader
              
               // Filter toggles
               filterSection
              
               // Quick stats widget
               weekStatsWidget
              
               ScrollView {
                   VStack(spacing: 16) {
                       // Week view with workload indicators
                       weekViewSection
                      
                       // Weekend preview
                       weekendPreviewSection
                      
                       // Events list for current week
                       eventsListSection
                   }
                   .padding(.horizontal)
                   .padding(.bottom, 100)
               }
           }
       }
   }
  
   // MARK: - Week Header
   private var weekHeader: some View {
       HStack {
           Button(action: { moveWeek(-1) }) {
               Image(systemName: "chevron.left")
                   .foregroundColor(.blue)
                   .font(.title2)
           }
          
           Spacer()
          
           VStack(spacing: 2) {
               Text(weekRangeText())
                   .font(.headline)
                   .fontWeight(.semibold)
                   .foregroundColor(.white)
              
               if isCurrentWeek {
                   Text("This Week")
                       .font(.caption)
                       .foregroundColor(.blue)
               } else if isNextWeek {
                   Text("Next Week")
                       .font(.caption)
                       .foregroundColor(.orange)
               } else {
                   Text(" ")
                       .font(.caption)
               }
           }
          
           Spacer()
          
           Button(action: { moveWeek(1) }) {
               Image(systemName: "chevron.right")
                   .foregroundColor(.blue)
                   .font(.title2)
           }
       }
       .padding(.horizontal)
       .padding(.vertical, 12)
       .background(Color.gray.opacity(0.1))
   }
  
   // MARK: - Filter Section
   private var filterSection: some View {
       VStack(spacing: 12) {
           // Event type filters
           ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 12) {
                   ForEach(EventFilter.allCases, id: \.self) { filter in
                       filterButton(for: filter)
                   }
               }
               .padding(.horizontal)
           }
          
           // Show/hide completed toggle
           HStack {
               Button(action: { showCompletedItems.toggle() }) {
                   HStack(spacing: 8) {
                       Image(systemName: showCompletedItems ? "eye" : "eye.slash")
                       Text(showCompletedItems ? "Hide Completed" : "Show Completed")
                   }
                   .font(.caption)
                   .foregroundColor(.gray)
                   .padding(.horizontal, 12)
                   .padding(.vertical, 6)
                   .background(Color.gray.opacity(0.2))
                   .cornerRadius(16)
               }
               Spacer()
           }
           .padding(.horizontal)
       }
       .padding(.vertical, 8)
       .background(Color.black)
   }
  
   private func filterButton(for filter: EventFilter) -> some View {
       Button(action: { selectedFilter = filter }) {
           HStack(spacing: 6) {
               Image(systemName: filter.systemImage)
               Text(filter.displayName)
           }
           .font(.caption)
           .fontWeight(.medium)
           .foregroundColor(selectedFilter == filter ? .black : .white)
           .padding(.horizontal, 12)
           .padding(.vertical, 8)
           .background(selectedFilter == filter ? Color.white : Color.gray.opacity(0.3))
           .cornerRadius(16)
       }
   }
  
   // MARK: - Week Stats Widget
   private var weekStatsWidget: some View {
       HStack(spacing: 20) {
           statCard(
               title: "This Week",
               count: thisWeekEvents.count,
               subtitle: "\(completedThisWeek)/\(thisWeekEvents.count) done",
               color: .blue
           )
          
           statCard(
               title: "Next Week",
               count: nextWeekEvents.count,
               subtitle: workloadMessage(for: nextWeekEvents.count),
               color: .orange
           )
          
           statCard(
               title: "Completion",
               count: completionPercentage,
               subtitle: "% this week",
               color: .green,
               isPercentage: true
           )
       }
       .padding(.horizontal)
       .padding(.vertical, 16)
       .background(Color.gray.opacity(0.05))
   }
  
   private func statCard(title: String, count: Int, subtitle: String, color: Color, isPercentage: Bool = false) -> some View {
       VStack(spacing: 4) {
           Text(title)
               .font(.caption2)
               .foregroundColor(.gray)
          
           Text(isPercentage ? "\(count)" : "\(count)")
               .font(.title2)
               .fontWeight(.bold)
               .foregroundColor(color)
          
           Text(subtitle)
               .font(.caption2)
               .foregroundColor(.gray)
               .multilineTextAlignment(.center)
       }
       .frame(maxWidth: .infinity)
       .padding(.vertical, 12)
       .background(Color.gray.opacity(0.1))
       .cornerRadius(12)
   }
  
   // MARK: - Week View Section
   private var weekViewSection: some View {
       VStack(alignment: .leading, spacing: 12) {
           Text("Week Overview")
               .font(.headline)
               .fontWeight(.bold)
               .foregroundColor(.white)
          
           HStack(spacing: 4) {
               ForEach(daysInCurrentWeek(), id: \.self) { date in
                   dayColumn(for: date)
               }
           }
           .padding(.vertical, 8)
       }
   }
  
   private func dayColumn(for date: Date) -> some View {
       let events = eventsForDate(date)
       let workload = workloadLevel(for: events.count)
      
       return VStack(spacing: 6) {
           // Day name
           Text(dayName(for: date))
               .font(.caption2)
               .fontWeight(.medium)
               .foregroundColor(.gray)
          
           // Day number with workload color
           Text("\(Calendar.current.component(.day, from: date))")
               .font(.system(size: 14, weight: .semibold))
               .foregroundColor(workload.textColor)
               .frame(width: 32, height: 32)
               .background(workload.backgroundColor)
               .cornerRadius(8)
          
           // Event count badge
           if events.count > 0 {
               Text("\(events.count)")
                   .font(.caption2)
                   .fontWeight(.bold)
                   .foregroundColor(.white)
                   .frame(width: 16, height: 16)
                   .background(Color.red)
                   .cornerRadius(8)
           } else {
               Text(" ")
                   .font(.caption2)
                   .frame(height: 16)
           }
          
           // Progress dots
           VStack(spacing: 2) {
               ForEach(0..<min(events.count, 3), id: \.self) { index in
                   Circle()
                       .fill(events[index].isCompleted ? Color.green : Color.gray.opacity(0.5))
                       .frame(width: 4, height: 4)
               }
           }
       }
       .frame(maxWidth: .infinity)
       .onTapGesture {
           // Could navigate to day detail view
       }
   }
  
   // MARK: - Weekend Preview Section
   private var weekendPreviewSection: some View {
       VStack(alignment: .leading, spacing: 8) {
           HStack {
               Image(systemName: "calendar.badge.clock")
                   .foregroundColor(.purple)
               Text("Weekend Preview")
                   .font(.headline)
                   .fontWeight(.bold)
                   .foregroundColor(.white)
               Spacer()
           }
          
           weekendPreviewCard
       }
   }
  
   private var weekendPreviewCard: some View {
       let earlyNextWeekEvents = getEarlyNextWeekEvents()
       let nextMondayEvents = getNextMondayEvents()
      
       return VStack(alignment: .leading, spacing: 8) {
           // Weekend status based on early next week workload
           if earlyNextWeekEvents.isEmpty {
               Text("🎉 Free Weekend Ahead!")
                   .font(.subheadline)
                   .foregroundColor(.green)
           } else if earlyNextWeekEvents.count == 1 {
               Text("📖 Light Weekend")
                   .font(.subheadline)
                   .foregroundColor(.orange)
               Text("1 assignment due early next week")
                   .font(.caption)
                   .foregroundColor(.orange.opacity(0.8))
           } else {
               Text("📚 Busy Weekend")
                   .font(.subheadline)
                   .foregroundColor(.red)
               Text("\(earlyNextWeekEvents.count) assignments due early next week")
                   .font(.caption)
                   .foregroundColor(.red.opacity(0.8))
           }
          
           // Show what's due when
           if !nextMondayEvents.isEmpty {
               HStack {
                   Image(systemName: "arrow.right")
                       .font(.caption2)
                       .foregroundColor(.blue)
                   Text("Monday: \(nextMondayEvents.map { "\($0.title) (\(getClassName(for: $0)))" }.joined(separator: ", "))")
                       .font(.caption)
                       .foregroundColor(.blue)
               }
           }
       }
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(Color.gray.opacity(0.1))
       .cornerRadius(12)
   }
  
   // MARK: - Events List Section
   private var eventsListSection: some View {
       VStack(alignment: .leading, spacing: 12) {
           Text("Upcoming Events")
               .font(.headline)
               .fontWeight(.bold)
               .foregroundColor(.white)
          
           LazyVStack(spacing: 8) {
               ForEach(filteredEventsThisWeek) { event in
                   EventRowView(event: event, className: getClassName(for: event)) {
                       toggleEventCompletion(event)
                   }
               }
           }
       }
   }
  
   // MARK: - Helper Properties
   private var isCurrentWeek: Bool {
       Calendar.current.isDate(currentWeek, equalTo: Date(), toGranularity: .weekOfYear)
   }
  
   private var isNextWeek: Bool {
       let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
       return Calendar.current.isDate(currentWeek, equalTo: nextWeek, toGranularity: .weekOfYear)
   }
  
   private var thisWeekEvents: [CalendarEvent] {
       allEvents.filter { event in
           guard let eventDate = dateFromString(event.date) else { return false }
           return Calendar.current.isDate(eventDate, equalTo: currentWeek, toGranularity: .weekOfYear)
       }
   }
  
   private var nextWeekEvents: [CalendarEvent] {
       let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
       return allEvents.filter { event in
           guard let eventDate = dateFromString(event.date) else { return false }
           return Calendar.current.isDate(eventDate, equalTo: nextWeek, toGranularity: .weekOfYear)
       }
   }
  
   private var completedThisWeek: Int {
       thisWeekEvents.filter { $0.isCompleted }.count
   }
  
   private var completionPercentage: Int {
       guard !thisWeekEvents.isEmpty else { return 0 }
       return Int((Double(completedThisWeek) / Double(thisWeekEvents.count)) * 100)
   }
  
   private var allEvents: [CalendarEvent] {
       classManager.classes.flatMap { $0.events }
   }
  
   private var filteredEventsThisWeek: [CalendarEvent] {
       var events = thisWeekEvents
      
       // Filter by completion status
       if !showCompletedItems {
           events = events.filter { !$0.isCompleted }
       }
      
       // Filter by type
       if selectedFilter != .all {
           events = events.filter { $0.type == selectedFilter.rawValue }
       }
      
       return events.sorted { dateFromString($0.date) ?? Date() < dateFromString($1.date) ?? Date() }
   }
  
   // MARK: - Helper Methods
   private func weekRangeText() -> String {
       let formatter = DateFormatter()
       formatter.dateFormat = "MMM d"
      
       let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
       let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? currentWeek
      
       return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
   }
  
   private func moveWeek(_ direction: Int) {
       withAnimation(.easeInOut(duration: 0.3)) {
           currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: direction, to: currentWeek) ?? currentWeek
       }
   }
  
   private func daysInCurrentWeek() -> [Date] {
       let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
       return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek) }
   }
  
   private func dayName(for date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateFormat = "EEE"
       return formatter.string(from: date).uppercased()
   }
  
   private func eventsForDate(_ date: Date) -> [CalendarEvent] {
       let dateString = dateFormatter.string(from: date)
       return allEvents.filter { $0.date == dateString }
   }
  
   private func workloadLevel(for eventCount: Int) -> (backgroundColor: Color, textColor: Color) {
       switch eventCount {
       case 0:
           return (Color.green.opacity(0.2), Color.green)
       case 1...2:
           return (Color.yellow.opacity(0.2), Color.yellow)
       case 3...4:
           return (Color.orange.opacity(0.2), Color.orange)
       default:
           return (Color.red.opacity(0.2), Color.red)
       }
   }
  
   private func workloadMessage(for count: Int) -> String {
       switch count {
       case 0: return "Free week!"
       case 1...2: return "Light week"
       case 3...4: return "Moderate week"
       default: return "Heavy week"
       }
   }
  
   private func getClassName(for event: CalendarEvent) -> String {
       for classItem in classManager.classes {
           if classItem.events.contains(where: { $0.id == event.id }) {
               return classItem.name
           }
       }
       return "Unknown"
   }
  
   private func getEarlyNextWeekEvents() -> [CalendarEvent] {
       // Get Monday and Tuesday of next week
       let nextWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
       let nextMondayStart = Calendar.current.dateInterval(of: .weekOfYear, for: nextWeekStart)?.start ?? nextWeekStart
       let nextTuesday = Calendar.current.date(byAdding: .day, value: 1, to: nextMondayStart) ?? nextMondayStart
      
       let mondayEvents = eventsForDate(nextMondayStart).filter { !$0.isCompleted }
       let tuesdayEvents = eventsForDate(nextTuesday).filter { !$0.isCompleted }
      
       return mondayEvents + tuesdayEvents
   }
  
   private func getWeekendEvents() -> [CalendarEvent] {
       let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
       let saturday = Calendar.current.date(byAdding: .day, value: 5, to: startOfWeek) ?? currentWeek
       let sunday = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? currentWeek
      
       let satEvents = eventsForDate(saturday)
       let sunEvents = eventsForDate(sunday)
      
       return (satEvents + sunEvents).filter { !$0.isCompleted }
   }
  
   private func getNextMondayEvents() -> [CalendarEvent] {
       // Get the Monday after the current week's weekend
       let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
       let nextMonday = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek) ?? currentWeek
       return eventsForDate(nextMonday).filter { !$0.isCompleted }
   }
  
   private func toggleEventCompletion(_ event: CalendarEvent) {
       // Find the class and event to update
       for classIndex in classManager.classes.indices {
           if let eventIndex = classManager.classes[classIndex].events.firstIndex(where: { $0.id == event.id }) {
               classManager.classes[classIndex].events[eventIndex].isTaskCompleted.toggle()
               classManager.classes[classIndex].hasUnsyncedChanges = true
               return
           }
       }
   }
  
   private func dateFromString(_ dateString: String) -> Date? {
       dateFormatter.date(from: dateString)
   }
  
   private let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
       formatter.dateFormat = "yyyy-MM-dd"
       return formatter
   }()
}


// MARK: - Event Row View
struct EventRowView: View {
   let event: CalendarEvent
   let className: String
   let onToggleCompletion: () -> Void
  
   var body: some View {
       HStack(spacing: 12) {
           // Completion button
           Button(action: onToggleCompletion) {
               Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                   .foregroundColor(event.isCompleted ? .green : .gray)
                   .font(.title3)
           }
          
           VStack(alignment: .leading, spacing: 4) {
               HStack {
                   Text(event.title)
                       .font(.subheadline)
                       .fontWeight(.medium)
                       .foregroundColor(.white)
                       .strikethrough(event.isCompleted)
                  
                   Spacer()
                  
                   Text(event.type.capitalized)
                       .font(.caption2)
                       .fontWeight(.medium)
                       .foregroundColor(.white.opacity(0.8))
                       .padding(.horizontal, 8)
                       .padding(.vertical, 4)
                       .background(typeColor(for: event.type))
                       .cornerRadius(8)
               }
              
               HStack {
                   Image(systemName: "calendar")
                       .foregroundColor(.gray)
                       .font(.caption)
                  
                   Text(formatDate(event.date))
                       .font(.caption)
                       .foregroundColor(.gray)
                   
                   Spacer()
                   
                   // Class name
                   Text(className)
                       .font(.caption)
                       .foregroundColor(.gray.opacity(0.8))
               }
           }
       }
       .padding()
       .background(Color.gray.opacity(event.isCompleted ? 0.05 : 0.1))
       .cornerRadius(12)
   }
  
   private func typeColor(for type: String) -> Color {
       switch type.lowercased() {
       case "exam": return Color.red.opacity(0.3)
       case "homework": return Color.blue.opacity(0.3)
       case "lab": return Color.purple.opacity(0.3)
       default: return Color.gray.opacity(0.3)
       }
   }
  
   private func formatDate(_ dateString: String) -> String {
       let formatter = DateFormatter()
       formatter.dateFormat = "yyyy-MM-dd"
       guard let date = formatter.date(from: dateString) else { return dateString }
      
       formatter.dateFormat = "EEEE, MMM d"
       return formatter.string(from: date)
   }
}


// MARK: - CalendarEvent Extension
extension CalendarEvent {
   var isCompleted: Bool {
       get { 
           // Use dedicated task completion property
           // This is separate from calendar sync status (.accepted)
           return isTaskCompleted 
       }
       set { 
           // Update task completion status independently of calendar sync
           isTaskCompleted = newValue
       }
   }
}


#Preview {
   WeeklyDashboardView()
       .environmentObject(ClassManager())
       .environmentObject(AuthManager())
}

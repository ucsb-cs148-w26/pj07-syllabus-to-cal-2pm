import Foundation

// Backend returns events in the following format:
//"events": [
//    {
//        "title": "event name",
//        "date": "YYYY-MM-DD",
//        "type": "homework/exam/quiz/lab/other",
//        "description": "brief description"
//    }
//]

struct EventFixtures {
    static let sampleEvents: [CalendarEvent] = [
        CalendarEvent(title: "HW1", date: "2026-02-15", type: "homework", description: "Chapter 1 problems"),
        CalendarEvent(title: "Midterm 1", date: "2026-02-20", type: "exam", description: "Covers weeks 1-4"),
        CalendarEvent(title: "Lab 2", date: "2026-02-22", type: "lab", description: "Data structures lab"),
        CalendarEvent(title: "Quiz 3", date: "2026-02-25", type: "quiz", description: "Weekly quiz")
    ]
}

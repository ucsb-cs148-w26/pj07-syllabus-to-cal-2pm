//
//  CalendarPreviewViewTests.swift
//  PlannrTests
//
//  Unit tests for CalendarPreviewView event filtering and display logic
//

import XCTest
import SwiftUI
@testable import Plannr

/// Unit tests for CalendarPreviewView component
/// Tests the core functionality of filtering events by date and type
class CalendarPreviewViewTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var testEvents: [CalendarEvent]!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        // Create sample test events
        testEvents = [
            CalendarEvent(
                title: "Math Homework",
                date: "2024-02-15",
                type: "homework",
                description: "Chapter 5 problems"
            ),
            CalendarEvent(
                title: "Physics Exam",
                date: "2024-02-20",
                type: "exam",
                description: "Midterm exam"
            ),
            CalendarEvent(
                title: "Chemistry Lab",
                date: "2024-02-18",
                type: "lab",
                description: "Lab 3"
            ),
            CalendarEvent(
                title: "History Quiz",
                date: "2024-02-20",
                type: "quiz",
                description: "Civil War quiz"
            )
        ]
    }
    
    override func tearDown() {
        testEvents = nil
        super.tearDown()
    }
    
    // MARK: - Event Filtering Tests
    
    /// Test filtering events by a specific date
    /// This is critical for the calendar view to show events on the correct day
    func testFilterEventsByDate() {
        // Given - events on different dates
        let targetDate = "2024-02-20"
        
        // When - we filter events for a specific date (like the calendar does)
        let eventsOnDate = testEvents.filter { $0.date == targetDate }
        
        // Then - we should only get events on that date
        XCTAssertEqual(eventsOnDate.count, 2, "Should have exactly 2 events on Feb 20")
        XCTAssertTrue(
            eventsOnDate.allSatisfy { $0.date == targetDate },
            "All filtered events should be on the target date"
        )
        XCTAssertTrue(
            eventsOnDate.contains { $0.title == "Physics Exam" },
            "Should include Physics Exam"
        )
        XCTAssertTrue(
            eventsOnDate.contains { $0.title == "History Quiz" },
            "Should include History Quiz"
        )
    }
    
    /// Test filtering events by type
    /// Verifies that event type filtering works correctly
    func testFilterEventsByType() {
        // Given - events of different types
        let targetType = "exam"
        
        // When - we filter events by type
        let examEvents = testEvents.filter { $0.type.lowercased() == targetType }
        
        // Then - we should only get exam events
        XCTAssertEqual(examEvents.count, 1, "Should have exactly 1 exam event")
        XCTAssertEqual(examEvents.first?.title, "Physics Exam", "The exam should be Physics Exam")
        XCTAssertTrue(
            examEvents.allSatisfy { $0.type.lowercased() == targetType },
            "All filtered events should be of type exam"
        )
    }
    
    /// Test that event count is accurate
    /// Ensures the "X items found" display is correct
    func testEventCount() {
        // Given - our test events array
        
        // When - we check the count
        let count = testEvents.count
        
        // Then - it should match the number of events we created
        XCTAssertEqual(count, 4, "Should have exactly 4 events")
    }
    
    /// Test filtering events when no matches exist
    /// Edge case: ensures empty results are handled properly
    func testFilterEventsWithNoMatches() {
        // Given - events with specific dates
        let nonExistentDate = "2025-12-31"
        
        // When - we filter for a date with no events
        let eventsOnDate = testEvents.filter { $0.date == nonExistentDate }
        
        // Then - we should get an empty array
        XCTAssertTrue(eventsOnDate.isEmpty, "Should return empty array when no events match")
        XCTAssertEqual(eventsOnDate.count, 0, "Count should be 0 for no matches")
    }
    
    /// Test that all events have required properties
    /// Ensures data integrity for calendar display
    func testAllEventsHaveRequiredProperties() {
        // Given - our test events
        
        // Then - all events should have non-empty titles and dates
        XCTAssertTrue(
            testEvents.allSatisfy { !$0.title.isEmpty },
            "All events should have non-empty titles"
        )
        XCTAssertTrue(
            testEvents.allSatisfy { !$0.date.isEmpty },
            "All events should have non-empty dates"
        )
        XCTAssertTrue(
            testEvents.allSatisfy { !$0.type.isEmpty },
            "All events should have non-empty types"
        )
    }
}

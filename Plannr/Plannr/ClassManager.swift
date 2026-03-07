//
//  ClassManager.swift
//  Plannr
//
//  Created by Divya Subramonian on 2/12/26.
//

import Foundation
import SwiftUI

enum ClassStatus: String, Codable {
    case noSyllabus = "NO_SYLLABUS"
    case active     = "ACTIVE"
    case inactive   = "INACTIVE"
}

class ClassManager: ObservableObject {
    @Published var classes: [Class] = []

    private let userDefaultsKey = "savedClasses"
    private let isGuest: Bool

    init(isGuest: Bool = false) {
        self.isGuest = isGuest
        if !isGuest {
            loadClasses()
        }
    }
    
    func addClass(_ newClass: Class) {
        classes.append(newClass)
        saveClasses()
    }
    
    func removeClass(_ classToRemove: Class) {
        classes.removeAll { $0.id == classToRemove.id }
        saveClasses()
    }

    func removeClassByID(_ id: UUID) {
        classes.removeAll { $0.id == id }
        saveClasses()
    }
    
    func updateClass(_ updatedClass: Class) {
        if let index = classes.firstIndex(where: { $0.id == updatedClass.id }) {
            classes[index] = updatedClass
            saveClasses()
        }
    }
    
    private func saveClasses() {
        guard !isGuest else { return }
        if let encoded = try? JSONEncoder().encode(classes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadClasses() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Class].self, from: data) {
            classes = decoded
        }
    }
}

// Class model
struct Class: Identifiable, Codable, Hashable {
    static func == (lhs: Class, rhs: Class) -> Bool {
        lhs.id == rhs.id
            && lhs.colorHex == rhs.colorHex
            && lhs.name == rhs.name
            && lhs.schedule == rhs.schedule
            && lhs.status == rhs.status
            && lhs.hasUnsyncedChanges == rhs.hasUnsyncedChanges
            && lhs.events.count == rhs.events.count
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(colorHex)
        hasher.combine(status)
    }
    let id: UUID
    var name: String
    var schedule: String
    var colorHex: String
    var events: [CalendarEvent]
    var status: ClassStatus
    var googleCalendarId: String?
    var lastSynced: Date?
    var hasUnsyncedChanges: Bool

    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, schedule, colorHex, events, status, googleCalendarId, lastSynced, hasUnsyncedChanges
    }

    init(
        name: String,
        schedule: String = "",
        colorHex: String = "007AFF",
        events: [CalendarEvent] = [],
        status: ClassStatus = .noSyllabus,
        googleCalendarId: String? = nil,
        lastSynced: Date? = nil,
        hasUnsyncedChanges: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.schedule = schedule
        self.colorHex = colorHex
        self.events = events
        self.status = status
        self.googleCalendarId = googleCalendarId
        self.lastSynced = lastSynced
        self.hasUnsyncedChanges = hasUnsyncedChanges
    }

    init(
        id: UUID,
        name: String,
        schedule: String = "",
        colorHex: String = "007AFF",
        events: [CalendarEvent] = [],
        status: ClassStatus = .noSyllabus,
        googleCalendarId: String? = nil,
        lastSynced: Date? = nil,
        hasUnsyncedChanges: Bool = false
    ) {
        self.id = id
        self.name = name
        self.schedule = schedule
        self.colorHex = colorHex
        self.events = events
        self.status = status
        self.googleCalendarId = googleCalendarId
        self.lastSynced = lastSynced
        self.hasUnsyncedChanges = hasUnsyncedChanges
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        schedule = try container.decodeIfPresent(String.self, forKey: .schedule) ?? ""
        colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex) ?? "007AFF"
        events = try container.decodeIfPresent([CalendarEvent].self, forKey: .events) ?? []
        status = try container.decodeIfPresent(ClassStatus.self, forKey: .status) ?? .noSyllabus
        googleCalendarId = try container.decodeIfPresent(String.self, forKey: .googleCalendarId)
        lastSynced = try container.decodeIfPresent(Date.self, forKey: .lastSynced)
        hasUnsyncedChanges = try container.decodeIfPresent(Bool.self, forKey: .hasUnsyncedChanges) ?? false
    }
}

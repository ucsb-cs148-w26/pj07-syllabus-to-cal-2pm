//
//  ClassManager.swift
//  Plannr
//
//  Created by Divya Subramonian on 2/12/26.
//

import Foundation
import SwiftUI

class ClassManager: ObservableObject {
    @Published var classes: [Class] = []
    
    private let userDefaultsKey = "savedClasses"
    
    init() {
        loadClasses()
    }
    
    func addClass(_ newClass: Class) {
        classes.append(newClass)
        saveClasses()
    }
    
    func removeClass(_ classToRemove: Class) {
        classes.removeAll { $0.id == classToRemove.id }
        saveClasses()
    }
    
    func updateClass(_ updatedClass: Class) {
        if let index = classes.firstIndex(where: { $0.id == updatedClass.id }) {
            classes[index] = updatedClass
            saveClasses()
        }
    }
    
    private func saveClasses() {
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
struct Class: Identifiable, Codable {
    let id: UUID
    var name: String
    var schedule: String
    var colorHex: String
    var events: [CalendarEvent]
    
    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }
    
    init(name: String, schedule: String = "", colorHex: String = "007AFF", events: [CalendarEvent] = []) {
        self.id = UUID()
        self.name = name
        self.schedule = schedule
        self.colorHex = colorHex
        self.events = events
    }
}

//
//  JSONLoader.swift
//  SyllabusToCalendar
//
//  Created by Avaneesh Kannan on 1/22/26.
//

import Foundation

class JSONLoader {
    static func loadAssignments() -> [Assignment] {
        guard let url = Bundle.main.url(forResource: "Assignments", withExtension: "json") else {
            print("JSON file not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let assignments = try JSONDecoder().decode([Assignment].self, from: data)
            return assignments
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}

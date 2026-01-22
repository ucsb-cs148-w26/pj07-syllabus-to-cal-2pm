//
//  Assignment.swift
//  SyllabusToCalendar
//
//  Created by Avaneesh Kannan on 1/22/26.
//

import Foundation

struct Assignment: Identifiable, Codable {
    var id = UUID()
    let className: String
    let assignmentType: String
    let name: String
    let dueDate: String

    enum CodingKeys: String, CodingKey {
        case className
        case assignmentType
        case name
        case dueDate
    }
}

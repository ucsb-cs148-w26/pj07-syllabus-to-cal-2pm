//
//  AssignmentCardView.swift
//  SyllabusToCalendar
//
//  Created by Avaneesh Kannan on 1/22/26.
//

import SwiftUI

struct AssignmentCardView: View {
    let assignment: Assignment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(assignment.name)
                .font(.headline)
            Text("\(assignment.assignmentType) — \(assignment.className)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Due: \(assignment.dueDate)")
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

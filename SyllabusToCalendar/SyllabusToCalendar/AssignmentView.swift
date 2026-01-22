//
//  AssignmentView.swift
//  SyllabusToCalendar
//
//  Created by Avaneesh Kannan on 1/22/26.
//

import SwiftUI

struct AssignmentView: View {
    let assignments: [Assignment] = JSONLoader.loadAssignments()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(assignments) { assignment in
                        AssignmentCardView(assignment: assignment)
                    }
                }
                .padding()
            }
            .navigationTitle("Syllabus Tasks")
        }
    }
}

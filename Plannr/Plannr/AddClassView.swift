//
//  AddClassView.swift
//  Plannr
//
//  Created by Divya Subramonian on 2/12/26.
//

import SwiftUI

struct AddClassView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classManager: ClassManager
    
    @State private var className: String = ""
    @State private var classSchedule: String = ""
    @State private var selectedColor: Color = .blue
    @State private var navigateToUpload = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Add New Class")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Class Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Class Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("e.g., Advanced Calculus", text: $className)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Schedule (optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Schedule (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("e.g., MWF 10:00 AM", text: $classSchedule)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Class Color")
                                .font(.headline)
                                .foregroundColor(.white)
                            ColorPicker("", selection: $selectedColor)
                                .labelsHidden()
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Continue Button
                    Button {
                        navigateToUpload = true
                    } label: {
                        Text("Continue to Upload Syllabus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(className.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(className.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .navigationDestination(isPresented: $navigateToUpload) {
                SyllabusUploadView(
                    className: className,
                    classSchedule: classSchedule,
                    classColor: selectedColor
                )
                .environmentObject(classManager)
            }
        }
    }
}

#Preview {
    AddClassView()
        .environmentObject(ClassManager())
}

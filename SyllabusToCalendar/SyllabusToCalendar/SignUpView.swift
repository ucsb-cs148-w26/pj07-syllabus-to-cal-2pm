//
//  SignUpView.swift
//  SyllabusToCalendar
//
//  Created for MVP login flow
//

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var school: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var navigateToPDFUpload: Bool = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Sign up to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    // Form fields
                    VStack(spacing: 16) {
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("Enter your full name", text: $name)
                                .textContentType(.name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }

                        // School field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("School/University")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("Enter your school name", text: $school)
                                .textContentType(.organizationName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }

                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("Enter your email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.gray)

                            SecureField("Create a password", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }

                        // Confirm Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.caption)
                                .foregroundColor(.gray)

                            SecureField("Confirm your password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Sign Up button
                    Button(action: {
                        navigateToPDFUpload = true
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    Spacer()
                        .frame(height: 40)
                }
            }

            // Navigation to PDF Upload
            NavigationLink(
                destination: PDFUploadView(),
                isActive: $navigateToPDFUpload
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}

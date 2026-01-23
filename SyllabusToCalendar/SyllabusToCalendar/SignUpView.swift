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
    @State private var showErrors: Bool = false
    
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isSchoolValid: Bool {
        !school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isEmailValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return trimmedEmail.range(of: emailRegEx, options: .regularExpression) != nil
    }
    
    private var isPasswordValid: Bool {
        password.count >= 8
    }
    
    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }
    
    
    private var isFormValid: Bool {
        isNameValid &&
        isSchoolValid &&
        isEmailValid &&
        isPasswordValid &&
        passwordsMatch
    }

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
                                .foregroundColor(showErrors && !isNameValid ? .red : .gray)

                            TextField("Enter your full name", text: $name)
                                .textContentType(.name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showErrors && !isNameValid ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            if showErrors && !isNameValid {
                                Text("Name is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // School field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("School/University")
                                .font(.caption)
                                .foregroundColor(showErrors && !isSchoolValid ? .red : .gray)

                            TextField("Enter your school name", text: $school)
                                .textContentType(.organizationName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showErrors && !isSchoolValid ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            if showErrors && !isSchoolValid {
                                Text("School is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(showErrors && !isEmailValid ? .red : .gray)

                            TextField("Enter your email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showErrors && !isEmailValid ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            if showErrors && !isEmailValid {
                                Text(email.isEmpty ? "Email is required." : "Please enter a valid email address.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(showErrors && !isPasswordValid ? .red : .gray)

                            SecureField("Create a password", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showErrors && !isPasswordValid ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            if showErrors && !isPasswordValid {
                                Text(password.isEmpty ? "Password is required." : "Password must be at least 8 characters.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Confirm Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.caption)
                                .foregroundColor(showErrors && !passwordsMatch ? .red : .gray)

                            SecureField("Confirm your password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showErrors && !passwordsMatch ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            if showErrors && !passwordsMatch {
                                Text(confirmPassword.isEmpty ? "Please confirm your password." : "Your passwords do not match.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Sign Up button
                    Button(action: {
                        showErrors = true
                        if isFormValid {
                            navigateToPDFUpload = true
                        }
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

                    // Divider with "or"
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Sign up with Google button
                    Button(action: {
                        navigateToPDFUpload = true
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Sign up with Google")
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)

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

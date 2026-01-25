//
//  SignInView.swift
//  Plannr
//
//  Created for MVP login flow
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToPDFUpload: Bool = false
    @State private var isAuthenticating: Bool = false
    @State private var authError: String?

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)

                Spacer()
                    .frame(height: 20)

                // Form fields
                VStack(spacing: 16) {
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

                        SecureField("Enter your password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 24)

                // Error message
                if let error = authError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // Sign In button (email/password - placeholder for now)
                Button(action: {
                    navigateToPDFUpload = true
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

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

                // Sign in with Google button
                Button(action: {
                    startGoogleSignIn()
                }) {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Sign in with Google")
                                .font(.headline)
                        }
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
                .disabled(isAuthenticating)
                .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 40)
            }

            // Navigation to PDF Upload
            NavigationLink(
                destination: PDFUploadView(),
                isActive: $navigateToPDFUpload
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                navigateToPDFUpload = true
            }
        }
    }

    private func startGoogleSignIn() {
        isAuthenticating = true
        authError = nil

        guard let authURL = authManager.getGoogleAuthURL() else {
            authError = "Could not create authentication URL"
            isAuthenticating = false
            return
        }

        // Use ASWebAuthenticationSession for secure OAuth
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "plannr"
        ) { callbackURL, error in
            isAuthenticating = false

            if let error = error {
                if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    // User cancelled - no error message needed
                    return
                }
                authError = "Authentication failed: \(error.localizedDescription)"
                return
            }

            // The callback URL will be plannr://auth/callback?email=...&name=...
            // But our backend returns JSON, so we need to fetch the result
            if let callbackURL = callbackURL {
                handleCallback(url: callbackURL)
            }
        }

        session.presentationContextProvider = WebAuthContextProvider.shared
        session.prefersEphemeralWebBrowserSession = false
        session.start()
    }

    private func handleCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            authError = "Invalid callback URL"
            return
        }

        var email: String?
        var name: String?

        for item in queryItems {
            if item.name == "email" {
                email = item.value
            }
            if item.name == "name" {
                name = item.value
            }
            if item.name == "error" {
                authError = item.value ?? "Authentication failed"
                return
            }
        }

        if let email = email {
            authManager.completeAuthentication(email: email, name: name)
            DispatchQueue.main.async {
                self.navigateToPDFUpload = true
            }
        } else {
            authError = "Could not get email from authentication"
        }
    }
}

// MARK: - Web Auth Context Provider
class WebAuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WebAuthContextProvider()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthManager())
    }
}

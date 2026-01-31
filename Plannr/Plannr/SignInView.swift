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
    @State private var isAuthenticating: Bool = false
    @State private var authError: String?
    @State private var showPDFUpload: Bool = false

    var body: some View {
        if showPDFUpload {
            PDFUploadView()
        } else {
            ZStack {
                // Background gradient - UCSB Navy Blue
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0, green: 0.2, blue: 0.4),
                        Color(red: 0, green: 0.15, blue: 0.35)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // App logo/icon and branding
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.white)

                        Text("Plannr")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Automatically organize your course schedules")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // Error message
                    if let error = authError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal, 32)
                    }

                    // Sign in with Google button
                    Button(action: {
                        startGoogleSignIn()
                    }) {
                        if isAuthenticating {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .tint(.black)
                                Text("Signing in...")
                            }
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                Text("Sign in with Google")
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 1, green: 0.72, blue: 0.11))
                    .cornerRadius(12)
                    .disabled(isAuthenticating)
                    .padding(.horizontal, 32)

                    Spacer()
                        .frame(height: 60)
                }
            }
            .navigationBarHidden(true)
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
                self.showPDFUpload = true
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

//
//  AuthManager.swift
//  Plannr
//
//  Manages Google OAuth authentication state
//

import SwiftUI
import AuthenticationServices

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let backendURL = "https://cs148.misc.iamjiamingliu.com/cs148api/"

    init() {
        // Check if user is already authenticated (from UserDefaults)
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            self.userEmail = email
            self.userName = UserDefaults.standard.string(forKey: "userName")
            self.isAuthenticated = true
        }
    }

    /// Returns the Google OAuth URL from the backend
    func getGoogleAuthURL() -> URL? {
        return URL(string: "\(backendURL)/auth/google")
    }

    /// Handle the OAuth callback URL
    func handleCallback(url: URL) {
        // Parse the custom URL callback (e.g. plannr://auth/callback?email=...&name=...)
        // The backend includes the email and name as URL query parameters after successful auth
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        // Check if this is our auth callback
        if components.host == "auth" && components.path == "/callback" {
            // Extract parameters from the URL
            if let queryItems = components.queryItems {
                for item in queryItems {
                    if item.name == "email", let value = item.value {
                        self.userEmail = value
                    }
                    if item.name == "name", let value = item.value {
                        self.userName = value
                    }
                }
            }

            if userEmail != nil {
                // Save to UserDefaults
                UserDefaults.standard.set(userEmail, forKey: "userEmail")
                UserDefaults.standard.set(userName, forKey: "userName")

                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            }
        }
    }

    /// Called when OAuth completes successfully via web
    func completeAuthentication(email: String, name: String?) {
        // Save to UserDefaults
        UserDefaults.standard.set(email, forKey: "userEmail")
        if let name = name {
            UserDefaults.standard.set(name, forKey: "userName")
        }

        DispatchQueue.main.async {
            self.userEmail = email
            self.userName = name
            self.isAuthenticated = true
            self.isLoading = false
        }
    }

    /// Sign out the user
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")

        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.userEmail = nil
            self.userName = nil
        }
    }
}

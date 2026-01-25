//
//  PlannrApp.swift
//  Plannr
//
//  Created by Divya Subramonian on 1/21/26.
//

import SwiftUI

@main
struct PlannrApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        // Handle plannr://auth/callback?email=...&name=...
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "plannr",
              components.host == "auth",
              components.path == "/callback" else {
            return
        }

        var email: String?
        var name: String?

        for item in components.queryItems ?? [] {
            if item.name == "email" {
                email = item.value
            }
            if item.name == "name" {
                name = item.value
            }
        }

        if let email = email {
            authManager.completeAuthentication(email: email, name: name)
        }
    }
}

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
        }
    }
}

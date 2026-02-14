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
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0, green: 0.2, blue: 0.4),
                        Color(red: 0, green: 0.15, blue: 0.35)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 24)

                    VStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.996, green: 0.722, blue: 0.074))

                        StorkeTowerLineArt()

                        Text("Plannr")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("Syllabus to Schedule")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 36)

                    Spacer()

                    if let error = authError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(10)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 6)
                    }

                    Button(action: {
                        startGoogleSignIn()
                    }) {
                        HStack(spacing: 12) {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "globe")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            Text(isAuthenticating ? "Signing in..." : "Sign in with Google")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 1, green: 0.72, blue: 0.11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.clear, lineWidth: 0)
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                    .disabled(isAuthenticating)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }

                BottomWave()
                    .frame(height: 120)
                    .offset(y: 30)
                    .ignoresSafeArea(edges: .bottom)
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

// MARK: - Storke Tower Line Art
struct StorkeTowerLineArt: View {
    private let primary = Color.white

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(primary, lineWidth: 2)
                .frame(width: 48, height: 128)
                .overlay(
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(primary, lineWidth: 1)
                            .frame(width: 16, height: 24)
                            .padding(.top, 8)
                        Rectangle()
                            .fill(primary)
                            .frame(width: 24, height: 4)
                        Rectangle()
                            .fill(primary)
                            .frame(width: 32, height: 4)
                        Spacer()
                        Rectangle()
                            .fill(primary)
                            .frame(width: 64, height: 6)
                            .padding(.bottom, 4)
                    }
                )
        }
        .frame(height: 140)
    }
}

// MARK: - Bottom Wave Shape
struct BottomWave: View {
    private let primary = Color(red: 0.1, green: 0.5, blue: 0.9)

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                path.move(to: CGPoint(x: 0, y: height * 0.5))
                path.addCurve(
                    to: CGPoint(x: width * 0.33, y: height * 0.7),
                    control1: CGPoint(x: width * 0.12, y: height * 0.9),
                    control2: CGPoint(x: width * 0.22, y: height * 0.55)
                )
                path.addCurve(
                    to: CGPoint(x: width * 0.66, y: height * 0.55),
                    control1: CGPoint(x: width * 0.45, y: height * 0.85),
                    control2: CGPoint(x: width * 0.55, y: height * 0.35)
                )
                path.addCurve(
                    to: CGPoint(x: width, y: height * 0.45),
                    control1: CGPoint(x: width * 0.78, y: height * 0.8),
                    control2: CGPoint(x: width * 0.9, y: height * 0.35)
                )
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(primary)
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

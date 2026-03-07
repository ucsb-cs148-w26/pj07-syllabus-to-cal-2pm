//
//  PDFUploadView.swift
//  Plannr
//
//  Created by Divya Subramonian on 1/21/26.
//

import SwiftUI

let BACKEND_URL = "https://cs148.misc.iamjiamingliu.com/cs148api/"

enum AppTab {
    case myClasses, calendar
}

struct PDFUploadView: View {
    @StateObject private var classManager: ClassManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showAddClass = false
    @State private var navigationPath = NavigationPath()
    @State private var selectedTab: AppTab = .myClasses
    @State private var showProfileSheet = false

    init(isGuest: Bool = false) {
        _classManager = StateObject(wrappedValue: ClassManager(isGuest: isGuest))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Guest mode banner
                    if authManager.isGuest {
                        HStack(spacing: 8) {
                            Image(systemName: "person.slash.fill")
                                .font(.caption)
                            Text("Guest Mode - data won't be saved between sessions")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(red: 1, green: 0.72, blue: 0.11))
                    }

                    // Header
                    HStack {
                        Menu {
                            Button(action: { selectedTab = .myClasses }) {
                                Label("My Classes", systemImage: "list.bullet")
                            }
                            Button(action: { selectedTab = .calendar }) {
                                Label("Calendar", systemImage: "calendar")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(.white)
                        }

                        Text(selectedTab == .myClasses ? "My Classes" : "Calendar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading, 8)

                        Spacer()

                        // User profile button
                        Button {
                            showProfileSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.3))
                                    .frame(width: 44, height: 44)

                                if authManager.isGuest {
                                    Text("G")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.yellow)
                                } else {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    if selectedTab == .myClasses {
                        ScrollView {
                            VStack(spacing: 16) {
                                // Existing classes
                                if !classManager.classes.isEmpty {
                                    ForEach(classManager.classes) { classItem in
                                        NavigationLink(value: classItem) {
                                            ClassCard(classItem: classItem)
                                                .environmentObject(classManager)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal)
                                    }
                                }

                                // Add New Class Button
                                Button {
                                    showAddClass = true
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add New Class")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            .padding(.bottom, 40)
                        }
                    } else {
                        UnifiedCalendarView()
                            .environmentObject(classManager)
                    }
                }
            }
            .navigationDestination(for: Class.self) { cls in
                SyllabusUploadView(
                    className: cls.name,
                    classSchedule: cls.schedule,
                    classColor: cls.color,
                    existingClassID: cls.id,
                    onSyncComplete: { navigationPath = NavigationPath() }
                )
                .environmentObject(classManager)
            }
            .sheet(isPresented: $showAddClass) {
                AddClassView()
                    .environmentObject(classManager)
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileSheetView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct ProfileSheetView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                // Handle bar
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 80, height: 80)
                    if authManager.isGuest {
                        Text("G")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.yellow)
                    }
                }

                // User info
                VStack(spacing: 6) {
                    if authManager.isGuest {
                        Text("Guest User")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Sign in to save your data across sessions")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        if let name = authManager.userName {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        if let email = authManager.userEmail {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer()

                // Sign out button
                Button {
                    authManager.signOut()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text(authManager.isGuest ? "Exit Guest Mode" : "Sign Out")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 1, green: 0.72, blue: 0.11))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

struct ClassCard: View {
    let classItem: Class
    @EnvironmentObject var classManager: ClassManager
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Color bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(classItem.color)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(classItem.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if !classItem.schedule.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(classItem.schedule)
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Status badge
                if classItem.events.isEmpty {
                    Text("NO SYLLABUS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text("ACTIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(classItem.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(classItem.color.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Delete button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.leading, 8)
            }
            
            // Event count / upload prompt
            if classItem.events.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.doc")
                        .font(.caption)
                    Text("Tap to upload syllabus")
                        .font(.caption)
                }
                .foregroundColor(.orange.opacity(0.8))
            } else {
                Text("\(classItem.events.count) events synced")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
        .confirmationDialog(
            "Delete \(classItem.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                classManager.removeClass(classItem)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    PDFUploadView()
}

// MARK: - Models

enum EventStatus: String, Codable {
    case pending
    case accepted
    case declined
}

struct CalendarEvent: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: String
    var type: String
    var description: String
    var colorHex: String = "007AFF"
    var status: EventStatus = .pending
    var isSyllabus: Bool = true

    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, date, type, description, colorHex, status, isSyllabus
    }

    init(title: String, date: String, type: String, description: String) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.type = type
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(String.self, forKey: .date)
        type = try container.decode(String.self, forKey: .type)
        description = try container.decode(String.self, forKey: .description)
        colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex) ?? "007AFF"
        status = try container.decodeIfPresent(EventStatus.self, forKey: .status) ?? .pending
        isSyllabus = try container.decodeIfPresent(Bool.self, forKey: .isSyllabus) ?? true
    }
}

struct SyllabusResponse: Codable {
    let message: String?
    let filename: String?
    let size: Int?
    let events: [CalendarEvent]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "007AFF" }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

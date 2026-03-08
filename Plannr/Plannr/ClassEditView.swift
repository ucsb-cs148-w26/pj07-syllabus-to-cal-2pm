//
//  ClassEditView.swift
//  Plannr
//

import SwiftUI

// MARK: - Sync response models

private struct ClassSyncResponse: Decodable {
    let googleCalendarId: String
    let syncedEvents: [SyncedEventEntry]

    private enum CodingKeys: String, CodingKey {
        case googleCalendarId = "google_calendar_id"
        case syncedEvents = "synced_events"
    }
}

private struct SyncedEventEntry: Decodable {
    let localId: String
    let googleEventId: String

    private enum CodingKeys: String, CodingKey {
        case localId = "local_id"
        case googleEventId = "google_event_id"
    }
}

// MARK: - ClassEditView

struct ClassEditView: View {
    @EnvironmentObject var classManager: ClassManager
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    // Local mutable copy of the class
    @State private var editableClass: Class
    @State private var editingEvent: CalendarEvent?
    @State private var isSyncing = false
    @State private var syncErrorMessage: String?
    @State private var showSyncError = false
    @State private var showSyncSuccess = false
    @State private var navigateToUpload = false
    @State private var showEndDatePicker = false
    // Tracks the name last synced to Google Calendar; used to detect renames
    @State private var originalName: String

    var onSyncComplete: (() -> Void)?

    init(cls: Class, onSyncComplete: (() -> Void)? = nil) {
        _editableClass = State(initialValue: cls)
        _originalName = State(initialValue: cls.name)
        self.onSyncComplete = onSyncComplete
    }

    // All events shown in the list; soft-deleted ones are visually marked but kept until resync
    private var visibleEvents: [CalendarEvent] {
        editableClass.events
    }

    private var activeEventCount: Int {
        editableClass.events.filter { !$0.isDeletedLocally }.count
    }

    // Count of changes pending a re-sync
    private var unsyncedCount: Int {
        editableClass.events.filter { $0.isEdited || $0.isDeletedLocally || $0.googleEventId == nil }.count
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // ── Header ────────────────────────────────────────
                        classHeader

                        // ── Events list ───────────────────────────────────
                        eventsSection
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100) // leave room for the sticky button
                }

                // ── Sticky bottom button ───────────────────────────────
                bottomButton
            }
        }
        .navigationTitle(editableClass.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingEvent) { event in
            EventEditView(event: event) { updatedEvent in
                applyEventEdit(updatedEvent)
                editingEvent = nil
            }
        }
        .navigationDestination(isPresented: $navigateToUpload) {
            SyllabusUploadView(
                className: editableClass.name,
                classSchedule: editableClass.schedule,
                classColor: editableClass.color,
                existingClassID: editableClass.id,
                existingEvents: editableClass.events,
                onSyncComplete: {
                    // Reload class from classManager to pick up new events + status
                    if let updated = classManager.classes.first(where: { $0.id == editableClass.id }) {
                        editableClass = updated
                    }
                    // Pop SyllabusUploadView + CalendarPreviewView back to ClassEditView
                    navigateToUpload = false
                }
            )
            .environmentObject(classManager)
            .environmentObject(authManager)
        }
        .alert("Sync Failed", isPresented: $showSyncError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(syncErrorMessage ?? "An unknown error occurred.")
        }
        .alert("Sync Successful", isPresented: $showSyncSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your changes have been synced to Google Calendar.")
        }
        .onAppear {
            // Refresh from classManager in case another view updated it
            if let latest = classManager.classes.first(where: { $0.id == editableClass.id }) {
                editableClass = latest
                originalName = latest.name
            }
            // Auto-transition to inactive if end date has passed
            if let endDate = editableClass.endDate, Date() > endDate, editableClass.status == .active {
                editableClass.status = .inactive
                persistClass()
            }
        }
    }

    // MARK: - Header

    private var classHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Class name", text: $editableClass.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .onChange(of: editableClass.name) { _, _ in
                            editableClass.hasUnsyncedChanges = true
                            persistClass()
                        }

                    if !editableClass.schedule.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(editableClass.schedule)
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Status picker (ACTIVE / INACTIVE only; NO_SYLLABUS is read-only)
                if editableClass.status == .noSyllabus {
                    Text("NO SYLLABUS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Menu {
                        Button("ACTIVE") {
                            editableClass.status = .active
                            persistClass()
                        }
                        Button("INACTIVE") {
                            editableClass.status = .inactive
                            persistClass()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(editableClass.status == .active ? "ACTIVE" : "INACTIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(editableClass.status == .active ? editableClass.color : .gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            (editableClass.status == .active ? editableClass.color : Color.gray).opacity(0.2)
                        )
                        .cornerRadius(8)
                    }
                }
            }

            // Color picker (no label — circle swatch speaks for itself)
            ColorPicker(selection: Binding(
                get: { editableClass.color },
                set: { newColor in
                    editableClass.colorHex = newColor.toHex()
                    persistClass()
                }
            ), supportsOpacity: false) {
                EmptyView()
            }
            .frame(maxWidth: 40) // constrain to just the swatch

            // End date row
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("End date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    if let endDate = editableClass.endDate {
                        Text(endDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.white)
                        Button {
                            editableClass.endDate = nil
                            persistClass()
                            showEndDatePicker = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button("Set") {
                            showEndDatePicker.toggle()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                if showEndDatePicker {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { editableClass.endDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date())! },
                            set: { newDate in
                                editableClass.endDate = newDate
                                persistClass()
                                showEndDatePicker = false
                            }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .colorScheme(.dark)
                    .labelsHidden()
                }
            }

            // Last synced
            if let lastSynced = editableClass.lastSynced {
                Text("Last synced: \(lastSynced.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Events section

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Events (\(activeEventCount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)

            if visibleEvents.isEmpty {
                Text("No events yet. Upload a PDF to get started.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(visibleEvents) { event in
                    ClassEventRow(event: event, classColor: editableClass.color) {
                        editingEvent = event
                    } onDelete: {
                        toggleDeleteEvent(event)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Bottom button

    private var bottomButton: some View {
        Group {
            if authManager.isGuest {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                    Text("Sign in to sync to Google Calendar")
                        .font(.headline)
                }
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.black)
            } else if editableClass.hasUnsyncedChanges {
                Button(action: { Task { await resyncChanges() } }) {
                    HStack(spacing: 8) {
                        if isSyncing {
                            ProgressView().tint(.white)
                        }
                        Text(isSyncing ? "Syncing..." : "Re-sync (\(unsyncedCount)) Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSyncing ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isSyncing)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.black)
            } else {
                Button(action: { navigateToUpload = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.doc.fill")
                        Text("Upload New PDF")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.black)
            }
        }
    }

    // MARK: - Helpers

    private func applyEventEdit(_ updated: CalendarEvent) {
        guard let idx = editableClass.events.firstIndex(where: { $0.id == updated.id }) else { return }
        var mutated = updated
        mutated.isEdited = true
        editableClass.events[idx] = mutated
        editableClass.hasUnsyncedChanges = true
        persistClass()
    }

    private func toggleDeleteEvent(_ event: CalendarEvent) {
        guard let idx = editableClass.events.firstIndex(where: { $0.id == event.id }) else { return }
        editableClass.events[idx].isDeletedLocally.toggle()
        editableClass.hasUnsyncedChanges = editableClass.events.contains { $0.isEdited || $0.isDeletedLocally }
        persistClass()
    }

    private func persistClass() {
        classManager.updateClass(editableClass)
    }

    // MARK: - Re-sync

    private func resyncChanges() async {
        guard let email = UserDefaults.standard.string(forKey: "userEmail"),
              let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(BACKEND_URL)calendar/sync?email=\(encodedEmail)") else {
            syncErrorMessage = "Could not determine your account email."
            showSyncError = true
            return
        }

        await MainActor.run { isSyncing = true }

        // Build request body
        struct SyncEventBody: Encodable {
            let localId: String
            let title: String
            let date: String
            let description: String
            let type: String
            let googleEventId: String?
            let isDeleted: Bool

            enum CodingKeys: String, CodingKey {
                case localId = "local_id"
                case title, date, description, type
                case googleEventId = "google_event_id"
                case isDeleted = "is_deleted"
            }
        }

        struct SyncRequestBody: Encodable {
            let className: String
            let googleCalendarId: String?
            let renameCalendarTo: String?
            let events: [SyncEventBody]

            enum CodingKeys: String, CodingKey {
                case className = "class_name"
                case googleCalendarId = "google_calendar_id"
                case renameCalendarTo = "rename_calendar_to"
                case events
            }
        }

        // Send all non-deleted events that need syncing + all deleted events
        let eventsToSync: [SyncEventBody] = editableClass.events.compactMap { ev in
            // Skip events that are deleted locally without a google ID (never synced, just drop them)
            if ev.isDeletedLocally && ev.googleEventId == nil { return nil }
            return SyncEventBody(
                localId: ev.id.uuidString,
                title: ev.title,
                date: ev.date,
                description: ev.description,
                type: ev.type,
                googleEventId: ev.googleEventId,
                isDeleted: ev.isDeletedLocally
            )
        }

        let body = SyncRequestBody(
            className: originalName,
            googleCalendarId: editableClass.googleCalendarId,
            renameCalendarTo: editableClass.name != originalName ? editableClass.name : nil,
            events: eventsToSync
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            await MainActor.run {
                isSyncing = false
                syncErrorMessage = "Failed to encode sync request."
                showSyncError = true
            }
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            await MainActor.run {
                isSyncing = false
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                   let syncResponse = try? JSONDecoder().decode(ClassSyncResponse.self, from: data) {
                    applySync(response: syncResponse)
                } else if let errBody = try? JSONDecoder().decode([String: String].self, from: data),
                          let errMsg = errBody["error"] {
                    syncErrorMessage = errMsg
                    showSyncError = true
                } else {
                    syncErrorMessage = "Re-sync failed. Please try again."
                    showSyncError = true
                }
            }
        } catch {
            await MainActor.run {
                isSyncing = false
                syncErrorMessage = "Network error: \(error.localizedDescription)"
                showSyncError = true
            }
        }
    }

    private func applySync(response: ClassSyncResponse) {
        // Update calendar ID
        editableClass.googleCalendarId = response.googleCalendarId

        // Build lookup: localId → googleEventId
        let idMap = Dictionary(uniqueKeysWithValues: response.syncedEvents.map { ($0.localId, $0.googleEventId) })

        // Apply to events
        for i in editableClass.events.indices {
            let ev = editableClass.events[i]
            if ev.isDeletedLocally {
                // Will be removed below
                continue
            }
            if let gid = idMap[ev.id.uuidString] {
                editableClass.events[i].googleEventId = gid
            }
            editableClass.events[i].isEdited = false
        }

        // Remove soft-deleted events from local storage
        editableClass.events.removeAll { $0.isDeletedLocally }

        // Update class metadata
        editableClass.hasUnsyncedChanges = false
        editableClass.lastSynced = Date()
        if editableClass.status == .noSyllabus {
            editableClass.status = .active
        }

        originalName = editableClass.name
        persistClass()
        showSyncSuccess = true
    }
}

// MARK: - ClassEventRow

struct ClassEventRow: View {
    let event: CalendarEvent
    let classColor: Color
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(event.isDeletedLocally ? Color.red : classColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(event.isDeletedLocally ? .gray : .white)
                        .strikethrough(event.isDeletedLocally, color: .gray)

                    Spacer()

                    if event.isDeletedLocally {
                        Text("QUEUED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(6)
                    } else if event.isEdited {
                        Text("EDITED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(6)
                    }

                    Text(event.type.capitalized)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(classColor.opacity(0.3))
                        .cornerRadius(6)
                }

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(event.date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                // Action buttons
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil").font(.caption2)
                            Text("Edit").font(.caption2).fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(event.isDeletedLocally ? 0.2 : 0.6))
                        .cornerRadius(6)
                    }
                    .disabled(event.isDeletedLocally)

                    Button(action: onDelete) {
                        HStack(spacing: 4) {
                            Image(systemName: event.isDeletedLocally ? "arrow.uturn.backward" : "trash")
                                .font(.caption2)
                            Text(event.isDeletedLocally ? "Undo" : "Delete")
                                .font(.caption2).fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(event.isDeletedLocally ? Color.red : Color.red.opacity(0.6))
                        .cornerRadius(6)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(event.isDeletedLocally ? Color.red.opacity(0.08) : Color.gray.opacity(0.12))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        ClassEditView(cls: Class(
            name: "CS148",
            schedule: "MWF 10:00 AM",
            colorHex: "007AFF",
            events: [
                CalendarEvent(title: "HW1", date: "2026-03-15", type: "homework", description: "Chapter 1"),
                CalendarEvent(title: "Midterm 1", date: "2026-03-20", type: "exam", description: "Covers weeks 1-4")
            ],
            status: .active
        ))
        .environmentObject(ClassManager())
        .environmentObject(AuthManager())
    }
}

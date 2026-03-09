import SwiftUI

struct SyncSessionsView: View {
    let sessions: [SyncSession]

    private var sortedSessions: [SyncSession] {
        sessions.sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if sessions.isEmpty {
                Text("No sync sessions yet.")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(sortedSessions.enumerated()), id: \.element.id) { index, session in
                            SessionRow(
                                sessionNumber: sortedSessions.count - index,
                                session: session
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Sync Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - SessionRow

struct SessionRow: View {
    let sessionNumber: Int
    let session: SyncSession
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — tap to expand/collapse
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Session \(sessionNumber)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("\(session.events.count) events")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 6)
                }
                .padding()
            }

            // Expandable event list
            if isExpanded {
                Divider()
                    .background(Color.gray.opacity(0.3))

                VStack(spacing: 10) {
                    ForEach(session.events) { event in
                        SyncEventRow(event: event)
                    }
                }
                .padding()
            }
        }
        .background(Color.gray.opacity(0.12))
        .cornerRadius(10)
    }
}

// MARK: - SyncEventRow (read-only, matches ClassEventRow style)

struct SyncEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()

                    Text(event.type.capitalized)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.3))
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
            }
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(10)
    }
}

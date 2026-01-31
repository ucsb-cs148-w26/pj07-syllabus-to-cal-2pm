//
//  PDFUploadView.swift
//  Plannr
//
//  Created by Divya Subramonian on 1/21/26.
//

import SwiftUI
import UniformTypeIdentifiers

// Using localhost for now by the way
let BACKEND_URL = "http://localhost:8000"


struct PDFUploadView: View {
    @State private var showDocumentPicker = false
    @State private var pdfURL: URL?
    @State private var pdfFileName: String = "No file attached"
    @State private var isUploading = false
    @State private var uploadError: String?
    @State private var parsedEvents: [CalendarEvent] = []
    @State private var navigateToPreview = false

    var body: some View {
        NavigationStack{
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    // header
                    Text("Let's organize your course schedules")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // upload button
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("Upload PDF")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isUploading)
                    
                    // display selected file name
                    Text(pdfFileName)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // loading indicator
                    if isUploading {
                        ProgressView("Uploading...")
                            .tint(.blue)
                    }
                    
                    // error message
                    if let error = uploadError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // display parsed events
                    if !parsedEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Parsed Events")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(parsedEvents, id: \.title) { event in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(event.title)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            
                                            HStack(spacing: 10) {
                                                Image(systemName: "calendar")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                                
                                                Text(event.date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            HStack(spacing: 8) {
                                                Text(event.type)
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .padding(6)
                                                    .background(Color.blue.opacity(0.3))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(4)
                                            }
                                            
                                            if !event.description.isEmpty {
                                                Text(event.description)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxHeight: 400)
                        .padding()
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
                .fileImporter(
                    isPresented: $showDocumentPicker,
                    allowedContentTypes: [.pdf],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        pdfURL = url
                        pdfFileName = url.lastPathComponent
                        
                        // start accessing the security-scoped resource
                        if url.startAccessingSecurityScopedResource() {
                            // process and upload PDF (security scope is kept alive during upload)
                            uploadPDF(url: url)
                        }
                        
                    case .failure(let error):
                        print("Error selecting file: \(error.localizedDescription)")
                        uploadError = "Error selecting file: \(error.localizedDescription)"
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                CalendarPreviewView(events: parsedEvents)
            }
        }
    }

    func uploadPDF(url: URL) {
        isUploading = true
        uploadError = nil
        parsedEvents = []

        Task {
            defer {
                // Stop accessing the security-scoped resource when done
                url.stopAccessingSecurityScopedResource()
            }

            do {
                let data = try Data(contentsOf: url)

                // Create the request
                var request = URLRequest(url: URL(string: "\(BACKEND_URL)/syllabus")!)
                request.httpMethod = "POST"

                // Create multipart/form-data body
                let boundary = UUID().uuidString
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                var body = Data()

                // Add file data
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

                request.httpBody = body

                // Send the request
                let (responseData, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Parse the response
                        do {
                            let jsonResponse = try JSONDecoder().decode(SyllabusResponse.self, from: responseData)
                            DispatchQueue.main.async {
                                self.parsedEvents = jsonResponse.events
                                self.isUploading = false
                                self.navigateToPreview = true
                            }
                        } catch {
                            print("JSON decode error: \(error)")
                            if let rawJSON = String(data: responseData, encoding: .utf8) {
                                print("Raw response: \(rawJSON)")
                            }
                            DispatchQueue.main.async {
                                self.uploadError = "Failed to parse response: \(error.localizedDescription)"
                                self.isUploading = false
                            }
                        }
                    } else {
                        let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
                        DispatchQueue.main.async {
                            self.uploadError = "Upload failed: \(errorMessage)"
                            self.isUploading = false
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.uploadError = "Error uploading PDF: \(error.localizedDescription)"
                    self.isUploading = false
                }
            }
        }
    }
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

    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, date, type, description, colorHex, status
    }

    init(title: String, date: String, type: String, description: String, colorHex: String = "007AFF", status: EventStatus = .pending) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.type = type
        self.description = description
        self.colorHex = colorHex
        self.status = status
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

#Preview {
    PDFUploadView()
}

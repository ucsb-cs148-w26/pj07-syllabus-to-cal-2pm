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

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {
                // header
                Text("Let's organize your course schedule")
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
                        if let jsonResponse = try? JSONDecoder().decode(SyllabusResponse.self, from: responseData) {
                            DispatchQueue.main.async {
                                self.parsedEvents = jsonResponse.events
                                self.isUploading = false
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.uploadError = "Failed to parse response"
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
struct CalendarEvent: Codable {
    let title: String
    let date: String
    let type: String
    let description: String
}

struct SyllabusResponse: Codable {
    let message: String?
    let filename: String?
    let size: Int?
    let events: [CalendarEvent]
}


#Preview {
    PDFUploadView()
}

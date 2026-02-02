//
//  PDFUploadView.swift
//  Plannr
//
//  Created by Divya Subramonian on 1/21/26.
//

import SwiftUI
import UniformTypeIdentifiers
import VisionKit
import PDFKit
import UIKit

// Using localhost for now by the way
let BACKEND_URL = "http://localhost:8000"

struct PDFUploadView: View {
    @State private var showActionSheet = false
    @State private var showDocumentPicker = false
    @State private var showCameraScanner = false

    @State private var pdfURL: URL?
    @State private var pdfFileName: String = "No file attached"
    @State private var isUploading = false
    @State private var uploadError: String?
    @State private var parsedEvents: [CalendarEvent] = []
    @State private var navigateToPreview = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)

                VStack(spacing: 20) {
                    // header
                    Text("Let's organize your course schedules")
                        .font(.headline)
                        .foregroundColor(.white)

                    // upload / scan button
                    Button {
                        showActionSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("Upload or Scan PDF")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isUploading)
                    .confirmationDialog(
                        "Select an option",
                        isPresented: $showActionSheet,
                        titleVisibility: .visible
                    ) {
                        Button("Upload PDF") {
                            showDocumentPicker = true
                        }

                        Button("Scan Document") {
                            // Safety check: scanner is not supported on all devices
                            if VNDocumentCameraViewController.isSupported {
                                showCameraScanner = true
                            } else {
                                uploadError = "Camera scanning is not supported on this device."
                            }
                        }

                        Button("Cancel", role: .cancel) {}
                    }

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

                    Spacer()
                }
                .padding()

                // MARK: - File Picker Sheet
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker { url in
                        guard url.pathExtension.lowercased() == "pdf" else { return }

                        pdfURL = url
                        pdfFileName = url.lastPathComponent

                        // Start accessing the security-scoped resource
                        if url.startAccessingSecurityScopedResource() {
                            uploadPDF(url: url)
                        } else {
                            uploadError = "Unable to access selected file."
                        }
                    }
                }

                // MARK: - Camera Scanner Sheet
                .sheet(isPresented: $showCameraScanner) {
                    DocumentScanner { images in
                        convertImagesToPDFAndUpload(images: images)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                CalendarPreviewView(events: parsedEvents)
            }
        }
    }

    // MARK: - Convert scanned images to PDF and upload
    func convertImagesToPDFAndUpload(images: [UIImage]) {
        let pdfDocument = PDFDocument()

        for (index, image) in images.enumerated() {
            if let page = PDFPage(image: image) {
                pdfDocument.insert(page, at: index)
            }
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ScannedSyllabus.pdf")

        if pdfDocument.write(to: tempURL) {
            pdfURL = tempURL
            pdfFileName = "ScannedSyllabus.pdf"
            uploadPDF(url: tempURL) // No security scope needed for temp files
        } else {
            uploadError = "Failed to create PDF from scan."
        }
    }

    // MARK: - Upload PDF
    func uploadPDF(url: URL) {
        isUploading = true
        uploadError = nil
        parsedEvents = []

        Task {
            // Stop accessing security-scoped resource when done (safe even for temp files)
            defer {
                url.stopAccessingSecurityScopedResource()
            }

            do {
                let data = try Data(contentsOf: url)

                var request = URLRequest(url: URL(string: "\(BACKEND_URL)/syllabus")!)
                request.httpMethod = "POST"

                // Create multipart/form-data body
                let boundary = UUID().uuidString
                request.setValue(
                    "multipart/form-data; boundary=\(boundary)",
                    forHTTPHeaderField: "Content-Type"
                )

                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append(
                    "Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n"
                        .data(using: .utf8)!
                )
                body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

                request.httpBody = body

                let (responseData, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        let jsonResponse = try JSONDecoder().decode(
                            SyllabusResponse.self,
                            from: responseData
                        )

                        DispatchQueue.main.async {
                            self.parsedEvents = jsonResponse.events
                            self.isUploading = false
                            self.navigateToPreview = true
                        }
                    } else {
                        let errorMessage =
                            String(data: responseData, encoding: .utf8) ?? "Unknown error"

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

//
// MARK: - iOS File Picker
//
struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(
        _ controller: UIDocumentPickerViewController,
        context: Context
    ) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

//
// MARK: - Camera Scanner using VisionKit
//
struct DocumentScanner: UIViewControllerRepresentable {
    var onScanComplete: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }

    func makeUIViewController(
        context: Context
    ) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onScanComplete: ([UIImage]) -> Void

        init(onScanComplete: @escaping ([UIImage]) -> Void) {
            self.onScanComplete = onScanComplete
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }

            controller.dismiss(animated: true)
            onScanComplete(images)
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            controller.dismiss(animated: true)
            print("Scan failed: \(error.localizedDescription)")
        }
    }
}

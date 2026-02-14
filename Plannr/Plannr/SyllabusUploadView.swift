//
//  SyllabusUploadView.swift
//  Plannr
//
//  Created by Divya Subramonian on 2/12/26.
//

import SwiftUI
import VisionKit
import PDFKit
import UIKit
import PhotosUI

struct SyllabusUploadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var classManager: ClassManager
    
    let className: String
    let classSchedule: String
    let classColor: Color
    
    @State private var showActionSheet = false
    @State private var showDocumentPicker = false
    @State private var showCameraScanner = false
    @State private var showImagePicker = false
    
    @State private var pdfURL: URL?
    @State private var pdfFileName: String = "No file attached"
    @State private var isUploading = false
    @State private var uploadError: String?
    @State private var parsedEvents: [CalendarEvent] = []
    @State private var navigateToPreview = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Upload Syllabus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("for \(className)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Upload area
                VStack(spacing: 16) {
                    Button {
                        showActionSheet = true
                    } label: {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Scan/Upload PDF Here")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text("BROWSE FILES")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                                )
                                .foregroundColor(.blue)
                        )
                    }
                    .disabled(isUploading)
                    .padding(.horizontal)
                    
                    // File name display
                    if pdfFileName != "No file attached" {
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.pink)
                            Text(pdfFileName)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Helper text
                    Text("We'll automatically extract deadlines, exam dates, and important events")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Loading indicator
                if isUploading {
                    ProgressView("Processing...")
                        .tint(.pink)
                        .foregroundColor(.white)
                }
                
                // Error message
                if let error = uploadError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .confirmationDialog(
                "Select an option",
                isPresented: $showActionSheet,
                titleVisibility: .visible
            ) {
                Button("Upload PDF") {
                    showDocumentPicker = true
                }
                
                Button("Scan Document") {
                    if VNDocumentCameraViewController.isSupported {
                        showCameraScanner = true
                    } else {
                        uploadError = "Camera scanning is not supported on this device."
                    }
                }

                Button("Upload from Photos") {
                    showImagePicker = true
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    guard url.pathExtension.lowercased() == "pdf" else { return }
                    pdfURL = url
                    pdfFileName = url.lastPathComponent
                    
                    if url.startAccessingSecurityScopedResource() {
                        uploadPDF(url: url)
                    } else {
                        uploadError = "Unable to access selected file."
                    }
                }
            }
            .sheet(isPresented: $showCameraScanner) {
                DocumentScanner { images in
                    convertImagesToPDFAndUpload(images: images)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { images in
                    guard !images.isEmpty else { return }
                    pdfFileName = "\(images.count) photo(s) selected"
                    convertImagesToPDFAndUpload(images: images)
                }
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                CalendarPreviewView(
                    className: className,
                    classSchedule: classSchedule,
                    classColor: classColor,
                    events: parsedEvents
                )
                .environmentObject(classManager)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
            uploadPDF(url: tempURL)
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
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let data = try Data(contentsOf: url)
                
                var request = URLRequest(url: URL(string: "\(BACKEND_URL)/syllabus")!)
                request.httpMethod = "POST"
                
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

// MARK: - iOS File Picker
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

// MARK: - Camera Scanner using VisionKit
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

//
// MARK: - Image Picker (Photo Library)
//
struct ImagePicker: UIViewControllerRepresentable {
    var onImagesPicked: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagesPicked: onImagesPicked)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // 0 = unlimited selection

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onImagesPicked: ([UIImage]) -> Void

        init(onImagesPicked: @escaping ([UIImage]) -> Void) {
            self.onImagesPicked = onImagesPicked
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            picker.dismiss(animated: true)

            var images: [UIImage] = []
            let dispatchGroup = DispatchGroup()

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    dispatchGroup.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            images.append(image)
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.onImagesPicked(images)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SyllabusUploadView(
            className: "Advanced Calculus",
            classSchedule: "MWF 10:00 AM",
            classColor: .blue
        )
        .environmentObject(ClassManager())
    }
}

//
//  PDFUploadView.swift
//  SyllabusToCalendar
//
//  Created by Divya Subramonian on 1/21/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct PDFUploadView: View {
    @State private var showDocumentPicker = false
    @State private var pdfURL: URL?
    @State private var pdfFileName: String = "No file attached"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    // header
                    Text("Let's organize your semester")
                        .font(.headline)
                    
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
                    
                    // display selected file name
                    Text(pdfFileName)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    NavigationLink("View Assignments", destination: AssignmentView())
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
                            // process PDF
                            processPDF(url: url)
                            
                            // stop accessing when done
                            url.stopAccessingSecurityScopedResource()
                        }
                        
                    case .failure(let error):
                        print("Error selecting file: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func processPDF(url: URL) {
        // process the PDF
        do {
            let data = try Data(contentsOf: url)
            print("PDF loaded successfully (\(data.count) bytes)")
        } catch {
            print("Error reading PDF: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PDFUploadView()
}

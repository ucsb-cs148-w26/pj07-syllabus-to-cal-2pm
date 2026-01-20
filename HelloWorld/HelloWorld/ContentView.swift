//
//  ContentView.swift
//  HelloWorld
//
//  Created by Matthew Blanke on 1/18/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello Syllabus to Cal 2pm!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  PatAMat
//
//  Created by Jacob Derynk on 11.11.2026.
//

import AppKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Memes go here")
                .foregroundStyle(.secondary)
            Spacer()
            HStack {
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
            }
        }
        .padding()
        .frame(width: 360, height: 420)
    }
}

#Preview {
    ContentView()
}

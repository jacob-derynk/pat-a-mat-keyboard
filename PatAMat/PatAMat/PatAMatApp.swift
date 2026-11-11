//
//  PatAMatApp.swift
//  PatAMat
//
//  Created by Jacob Derynk on 11.11.2026.
//

import SwiftUI

@main
struct PatAMatApp: App {
    init() {
        #if DEBUG
        checkSearchRules()
        #endif
    }

    var body: some Scene {
        MenuBarExtra("PatAMat", systemImage: "face.smiling") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}

//
//  PatAMatKeyboardApp.swift
//  PatAMatKeyboard
//
//  Created by Jacob Derynk on 11.11.2026.
//

import SwiftUI

@main
struct PatAMatKeyboardApp: App {
    init() {
        #if DEBUG
        checkSearchRules()
        #endif
    }

    var body: some Scene {
        MenuBarExtra("PatAMat Keyboard", systemImage: "face.smiling") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}

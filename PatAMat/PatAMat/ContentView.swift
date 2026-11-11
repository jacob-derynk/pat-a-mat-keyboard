//
//  ContentView.swift
//  PatAMat
//
//  Created by Jacob Derynk on 11.11.2026.
//

import AppKit
import ImageIO
import SwiftUI

struct Meme: Identifiable {
    let name: String
    let url: URL
    let thumbnail: NSImage

    var id: URL { url }

    // Xcode flattens the synchronized Images/ folder into Contents/Resources/, so we read the bundle root.
    static let all: [Meme] = {
        let urls = ["png", "jpg", "jpeg"].flatMap { ext in
            Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? []
        }
        return urls.compactMap { url in
            guard let thumbnail = makeThumbnail(url: url) else {
                print("PatAMat: cannot read image \(url.lastPathComponent), skipping it")
                return nil
            }
            return Meme(name: url.deletingPathExtension().lastPathComponent, url: url, thumbnail: thumbnail)
        }
        .sorted { $0.name < $1.name }
    }()

    private static func makeThumbnail(url: URL) -> NSImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 400, // ~2x the cell width, sharp on Retina
        ]
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else { return nil }
        return NSImage(cgImage: cgImage, size: .zero)
    }
}

struct ContentView: View {
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        VStack(spacing: 8) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Meme.all) { meme in
                        MemeCell(meme: meme) { copy(meme) }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
            }
        }
        .padding()
        .frame(width: 360, height: 420)
    }

    private func copy(_ meme: Meme) {
        guard let image = NSImage(contentsOf: meme.url) else {
            print("PatAMat: cannot load \(meme.url.lastPathComponent) for copying")
            NSSound.beep()
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if !pasteboard.writeObjects([image]) {
            print("PatAMat: pasteboard refused \(meme.name)")
            NSSound.beep()
            return
        }
        // @Environment(\.dismiss) does nothing for a MenuBarExtra window; closing the key window does.
        NSApp.keyWindow?.close()
    }
}

private struct MemeCell: View {
    let meme: Meme
    let onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        Image(nsImage: meme.thumbnail)
            .resizable()
            .scaledToFit()
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(4)
            .background(isHovered ? Color.accentColor.opacity(0.25) : Color.clear, in: .rect(cornerRadius: 8))
            .contentShape(.rect)
            .onHover { isHovered = $0 }
            .onTapGesture(perform: onTap)
            .help(meme.name)
    }
}

#Preview {
    ContentView()
}

// Renames images by the text in them (OCR) and moves them into Images/new/ for review.
// After checking the names, move them up into Images/ (the bundle is flat, so names must be unique across the whole tree).
// Usage: swift scripts/import-memes.swift <folder> [--apply]
// Without --apply it only prints what it would do.

import Foundation
import Vision

let imagesDir = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent()
    .appendingPathComponent("PatAMatKeyboard/PatAMatKeyboard/Images")
let targetDir = imagesDir.appendingPathComponent("new")
let maxNameLength = 60
// Regexes matched against the slug, e.g. "made-with-mematic". Add new watermarks here.
let watermarks = [
    "made-with-mematic",
    "pat-a-mat-memes",
    "patamatmemes",
    "aparat-com(-[a-z0-9]+)?",
]

func recognizeText(_ url: URL) throws -> String {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["cs-CZ", "en-US"]
    try VNImageRequestHandler(url: url).perform([request])
    return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
}

// "Když to bylo, předpovězeno!" -> "kdyz-to-bylo-predpovezeno"
func slug(_ text: String) -> String {
    var full = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        .lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .filter { !$0.isEmpty }
        .joined(separator: "-")
    for watermark in watermarks {
        full = full.replacingOccurrences(of: "\\b\(watermark)\\b", with: "", options: .regularExpression)
    }
    let words = full.split(separator: "-").map(String.init)
    var name = ""
    for word in words {
        let next = name.isEmpty ? word : name + "-" + word
        if next.count > maxNameLength { break }
        name = next
    }
    return name
}

// File names already used anywhere under Images/, e.g. "this-is-fine.png".
func existingNames() -> Set<String> {
    let enumerator = FileManager.default.enumerator(at: imagesDir, includingPropertiesForKeys: nil)
    return Set((enumerator?.allObjects as? [URL] ?? []).map { $0.lastPathComponent.lowercased() })
}

func uniqueURL(_ base: String, ext: String, taken: inout Set<String>) -> URL {
    var name = base
    var n = 2
    while taken.contains("\(name).\(ext)") {
        name = "\(base)-\(n)"
        n += 1
    }
    taken.insert("\(name).\(ext)")
    return targetDir.appendingPathComponent("\(name).\(ext)")
}

let args = CommandLine.arguments.dropFirst()
guard let input = args.first(where: { $0 != "--apply" }) else {
    print("Usage: swift scripts/import-memes.swift <folder> [--apply]")
    exit(1)
}
let apply = args.contains("--apply")
let files = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: input), includingPropertiesForKeys: nil)
    .filter { ["png", "jpg", "jpeg"].contains($0.pathExtension.lowercased()) }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }

var taken = existingNames()
if apply { try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true) }
var failed = 0
for file in files {
    do {
        // ponytail: no text found -> "meme", user renames by hand; add a description model if that gets common
        let name = slug(try recognizeText(file))
        let target = uniqueURL(name.isEmpty ? "meme" : name, ext: file.pathExtension.lowercased(), taken: &taken)
        print("\(file.lastPathComponent) -> \(target.lastPathComponent)")
        if apply { try FileManager.default.moveItem(at: file, to: target) }
    } catch {
        failed += 1
        print("FAILED \(file.lastPathComponent): \(error.localizedDescription)")
    }
}
print(apply ? "Moved \(files.count - failed) images into \(targetDir.path). Check the names, then move them up into Images/." : "Dry run. Add --apply to move the files.")
if failed > 0 { exit(1) }

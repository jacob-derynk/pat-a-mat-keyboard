# pat-a-mat-keyboard

Native macOS menu bar app for finding a reaction/meme image by keyword and copying it to the clipboard in one click. Paste it straight into Slack, Messages, etc.

`CLAUDE.md` only imports this file. Put all agent context here.

## Goals (v1)

- Lives in the menu bar only. No Dock icon, no main window.
- Clicking the menu bar icon opens a small popup with a search field and a grid of thumbnails large enough to read the content of the image but not too large.
- Typing filters the grid. Clicking a thumbnail copies the image to the clipboard and closes the popup.
- Images are bundled inside the app. No import, no settings, no network.
- Static images only (PNG, JPG). No GIFs yet.

Non-goals for v1: user-added images, tag editing, favourites or recents, GIF/animated support, sync, launch at login, auto-update, App Store distribution.

## Search rules

Tags come only from the file name. There is no metadata file.

- Take the name without its extension, lowercase it, and replace `-` and `_` with spaces: `this-is-fine.png` → `this is fine`.
- Fold diacritics in both the name and the query (`folding(options: .diacriticInsensitive, locale: nil)`), so `kdyz` and `když` match the same image.
- Split the query on whitespace. An image matches when its normalized name contains every query word as a substring.
- Empty query shows all images, sorted by name.
- Examples for `this-is-fine.png`: `fine` ✅, `this is` ✅, `is fi` ✅, `dog` ❌.
- Example for `kdyz-to-bylo.png`: `když` ✅.

Naming convention for images: lowercase, no diacritics, words separated by `-`, e.g. `surprised-pikachu.png`.

## Implementation overview

- **Stack:** Swift + SwiftUI, Xcode project, no third-party dependencies. Deployment target macOS 27 (Xcode default; personal use only).
- **Menu bar:** SwiftUI `MenuBarExtra` with `.menuBarExtraStyle(.window)` as the app's only scene. `LSUIElement = YES` in Info.plist hides the Dock icon.
- **Images:** a plain folder `Images/` added to the app target as bundled resources (not an asset catalog: an asset catalog cannot be enumerated at runtime). Loaded once at launch via `Bundle.main.urls(forResourcesWithExtension:subdirectory:)` for `png`, `jpg`, `jpeg`. Adding a meme = drop a file in the folder and rebuild.
- **Clipboard:** `NSPasteboard.general.clearContents()` then `writeObjects([NSImage])`. Check paste into Slack and Messages; if an app ignores TIFF, also write PNG data.
- **UI:** search field (focused on open) above a `LazyVGrid` of fixed-size thumbnails in a scroll view. Popup about 360×420 pt.
- **Size:** aim for 1–3 Swift files. No view models, protocols or persistence layers until something actually needs them.

## Possible next steps (not in v1)

1. Global hotkey to open the popup (Carbon `RegisterEventHotKey`, no dependency needed).
2. Keyboard navigation: arrow keys + Enter to copy.
3. GIF support: copy as a file URL so that apps keep the animation.
4. Images from a user folder (e.g. `~/Pictures/Memes`) instead of the bundle.

## Repo layout

```
PLAN.md                    # phased implementation plan, work one phase per session
PatAMat/
  PatAMat.xcodeproj
  PatAMat/                 # synchronized folder: files dropped here join the target
    PatAMatApp.swift       # MenuBarExtra scene + popup view
    Images/                # bundled meme images, file name = tags
```

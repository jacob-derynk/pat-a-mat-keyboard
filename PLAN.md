# Implementation plan

Work one phase per fresh session: "Implement phase N of PLAN.md". Each phase ends with a build that runs, a manual check, and one commit. Tick the phase off here in the same commit.

Project facts (Xcode 27, generated project):
- Project: `PatAMat/PatAMat.xcodeproj`, sources in `PatAMat/PatAMat/`.
- `PatAMat/PatAMat/` is a synchronized folder: any file dropped there is in the target automatically. Don't edit the project file to add files.
- Info.plist is generated. Add keys as `INFOPLIST_KEY_*` build settings, not a plist file.
- App Sandbox is on. That's fine: the clipboard and bundle reads work inside it.
- Build: `xcodebuild -project PatAMat/PatAMat.xcodeproj -scheme PatAMat -configuration Debug build`

---

## Phase 1 — Menu bar shell  [x]

- Replace `WindowGroup` in `PatAMatApp.swift` with `MenuBarExtra("PatAMat", systemImage: …)` + `.menuBarExtraStyle(.window)`.
- Add build setting `INFOPLIST_KEY_LSUIElement = YES` (Debug + Release) so the app has no Dock icon.
- Popup content: placeholder text, fixed frame about 360×420.
- Delete `ContentView.swift` or turn it into the popup view. Keep it to one view file at most.
- Add a Quit button (⌘Q) to the popup. Without a Dock icon there's no other way to quit.

**Done when:** the build runs, the icon is in the menu bar, there's no Dock icon, clicking the icon opens the popup, and Quit works.

## Phase 2 — Bundled images, grid, copy  [x]

- Create `PatAMat/PatAMat/Images/` with 3–5 sample images, named per AGENTS.md.
- **Verify first:** synchronized folders may flatten resources into `Contents/Resources/` instead of keeping `Images/`. Check the built `.app`. If they're flattened, load from the bundle root (filter `png`/`jpg`/`jpeg`). If not, use `subdirectory: "Images"`.
- Load the list once at launch: name (file name without extension) and URL. Downscale thumbnails so the popup doesn't hold full-size images. The thumbnails must be large enough to read the content of the image (see AGENTS.md).
- `ScrollView` + `LazyVGrid` of thumbnails. Show a hover highlight.
- Click → `NSPasteboard.general.clearContents()` + `writeObjects([NSImage(contentsOf: url)])`, then close the popup.
- **Known risk:** `MenuBarExtra` has no public dismiss API. Try `@Environment(\.dismiss)` first, then `NSApp.keyWindow?.close()`. Note in a comment which one works.

**Done when:** clicking an image puts it on the clipboard and pasting works in Slack and Messages. If one of them pastes nothing, also write PNG data to the pasteboard.

## Phase 3 — Search  [ ]

- Search field above the grid, focused when the popup opens (`@FocusState`). Clear it when the popup reopens.
- Pure function `matches(name:query:) -> Bool` implementing the rules in AGENTS.md "Search rules".
- Leave one runnable check: DEBUG-only `assert`s for the AGENTS.md examples (`fine`, `this is`, `is fi`, `dog`, empty query), run once at launch.
- Esc closes the popup.

**Done when:** typing filters the grid live, the asserts pass in a Debug run, and an empty result shows a short "No match" text.

## Phase 4 — Ship your real images  [ ]

- You (the user) drop the real images into `Images/` and rename them to the convention.
- Release build, copy `PatAMat.app` to `/Applications`, add it to Login Items manually in System Settings.

---

## Later (not v1, plan when needed)

- Global hotkey (Carbon `RegisterEventHotKey`).
- Arrow keys + Enter to copy.
- GIF support (copy as a file URL).

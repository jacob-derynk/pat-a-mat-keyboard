# PatAMat

A macOS menu bar app for finding a reaction image by keyword and copying it to the clipboard in one click. Paste it straight into Slack, Messages, etc.

## Build

Requires Xcode (macOS 27). No other dependencies.

The app has no Dock icon and no window: after launch, look for the smiley icon in the menu bar. Quit it from the popup (Quit button or ⌘Q while the popup is open).

### Dev build

Open the project in Xcode and press ⌘R:

```
open PatAMat/PatAMat.xcodeproj
```

Or from the terminal:

```
xcodebuild -project PatAMat/PatAMat.xcodeproj -scheme PatAMat -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/PatAMat.app
```

The Debug build checks the search rules on launch with `assert`s and crashes right away if one fails. Quit the installed app first, or you'll have two icons in the menu bar.

### Prod build and install

```
xcodebuild -project PatAMat/PatAMat.xcodeproj -scheme PatAMat -configuration Release -derivedDataPath build clean build
pkill -x PatAMat
rm -rf /Applications/PatAMat.app
ditto build/Build/Products/Release/PatAMat.app /Applications/PatAMat.app
open /Applications/PatAMat.app
```

Use `clean`: an incremental build can keep images you deleted from `Images/` in the app bundle. `pkill` doesn't stop a build running from Xcode: stop it there with ⌘. first. Otherwise `open` just brings that running copy forward instead of starting the installed app (they share a bundle ID).

To start it at login, add `/Applications/PatAMat.app` in System Settings → General → Login Items (once; reinstalling to the same path should keep it, re-add it if it disappears).

Images are bundled into the app, so after adding, renaming or deleting images, run the prod build and install again.

## Usage

Click the icon in the menu bar, type a few words, click an image. The image is now on your clipboard.

Search matches words from the file name, in any order and as partial words. Diacritics don't matter: `kdyz` and `když` find the same image.

## Adding your own images

Images are bundled in `PatAMat/PatAMat/Images/`. The file name is the search tag: lowercase, no diacritics, words separated by `-`, e.g. `this-is-fine.png`. PNG and JPG only.

You can name and drop the files there by hand, or let the import script name them from the text in the image:

```
swift scripts/import-memes.swift ~/Downloads/my-memes            # dry run: prints old -> new
swift scripts/import-memes.swift ~/Downloads/my-memes --apply    # moves the files into Images/
```

The script uses macOS's built-in text recognition (Czech and English). You don't need to install anything besides Xcode. It:

- names each image by its text, e.g. `Když to bylo předpovězeno!` → `kdyz-to-bylo-predpovezeno.jpg`, capped at 60 characters
- drops known watermarks such as `made with mematic`. To strip more, add them to the `watermarks` list at the top of the script
- adds `-2`, `-3` when a name is already taken
- names images without text `meme`, `meme-2`, … so you can rename them by hand

Always check the dry run first: OCR sometimes misreads a word. Rebuild the app after adding images.

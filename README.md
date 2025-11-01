# Glassons Capture One Scripts

### Rename and Export Selects (⌘ 6)
Renames and exports rated images from Capture One to a defined local output folder. Images are exported as sharpened and resized JPGs ready for upload. Handles conflict resolution when re-running with different selections by renaming previously unrated images, ensuring clean exports without filename conflicts.

### New Capture Folder from Clipboard (⌘ 0)
Creates a new capture folder in Capture One using text from the clipboard. Replaces the first space/tab with an underscore, adds to favourites, sets as active capture location, and resets the counter.

### New Folder from Clipboard (⌘ 9)
Identical to the New Capture Folder from Clipboard script, but with `setCaptureFolder` set to false. Useful when shooting multiple SKUs per look.

## Installation

1. Download `glassons-scripts.zip` from the latest release
2. Unzip the files and place the .applescript files in `~/Library/Scripts/Capture One Scripts`
3. Assign keyboard shortcuts via System Settings > Keyboard > Shortcuts > App Shortcuts

## Configuration

**Rename and Export Selects:** Update the `exportOutputFolder` property at the top of the script to match your export destination.

**Folder Scripts:** Configure `setCaptureFolder` and `resetCaptureCounter` properties as needed.

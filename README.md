# Glassons Scripts

AppleScript utilities for Capture One workflow automation at Glassons.

## Scripts

### Export Rated Images
Exports 1-5 star rated images from Capture One to JPG format for the Glassons Ecom system. Handles conflict resolution when re-running with different selections.

**Recommended shortcut:** Command + 6

### New Capture Folder from Clipboard
Creates a new capture folder in Capture One using text from the clipboard. Replaces the first space/tab with an underscore, adds to favorites, sets as active capture location, and resets the counter.

**Recommended shortcut:** Command + 0

### New Folder from Clipboard
Creates a new folder in Capture One using text from the clipboard. Similar to the capture folder script but without setting as the active capture location.

**Recommended shortcut:** Command + 9

## Installation

1. Open each `.applescript` file in Script Editor (Applications > Utilities > Script Editor)
2. Save as a compiled script (.scpt) or application (.app)
3. Place in `~/Library/Scripts/Capture One Scripts` or configure via Capture One's script menu
4. Assign keyboard shortcuts via System Settings > Keyboard > Shortcuts > App Shortcuts

## Configuration

**Export Rated Images:** Update the `exportOutputFolder` property at the top of the script to match your export destination.

**Folder Scripts:** Configure `setCaptureFolder` and `resetCaptureCounter` properties as needed.

## Author

Jesse Morley, October 2025

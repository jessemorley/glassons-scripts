# Glassons Scripts

AppleScript utilities for Capture One workflow automation at Glassons.

## Scripts

### Rename and Export Rated Images
Exports 1-5 star rated images from Capture One to JPG format for the Glassons Ecom system. Handles conflict resolution when re-running with different selections.

**Recommended shortcut:** Command + 6

### New Capture Folder from Clipboard
Creates a new capture folder in Capture One using text from the clipboard. Replaces the first space/tab with an underscore, adds to favourites, sets as active capture location, and resets the counter.

**Recommended shortcut:** Command + 0

### New Folder from Clipboard
Creates a new folder in Capture One using text from the clipboard. Replaces the first space/tab with an underscore, adds to favourites, and resets the counter.

**Recommended shortcut:** Command + 9

## Installation

1. Download `glassons-scripts.zip` from the latest release
2. Unzip the files and place the .applescript files in `~/Library/Scripts/Capture One Scripts`
3. Assign keyboard shortcuts via System Settings > Keyboard > Shortcuts > App Shortcuts

## Configuration

**Rename and Export Rated Images:** Update the `exportOutputFolder` property at the top of the script to match your export destination.

**Folder Scripts:** Configure `setCaptureFolder` and `resetCaptureCounter` properties as needed.

## Author

Jesse Morley, October 2025

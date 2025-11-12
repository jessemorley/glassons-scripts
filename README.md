# Glassons Capture One Scripts

### Rename and Export Selects (⌘ 6)

Renames and exports rated images from Capture One to a defined local output folder. Images are exported as sharpened and resized JPGs ready for upload. Handles conflict resolution when re-running with different selections by renaming previously unrated images, ensuring clean exports without filename conflicts.

Renaming sequence: `SKU_1, SKU_2, SKU_3, SKU_4, SKU_5, SKU_6, SKU_ADDITIONAL 1, SKU_ADDITIONAL 2, SKU_ADDITIONAL 3, SKU_ADDITIONAL 4`

### Rename and Export Clearcut (⌘ 7)

Renaming sequence: `SKU_ACCMODEL, SKU_3, SKU_4, SKU_5`

### Rename and Export Acc Model (⌘ 8)

Renaming sequence: `SKU_ACCMODEL, SKU_3, SKU_4, SKU_5`

### New Capture Folder from Clipboard (⌘ 0)

Creates a new capture folder in Capture One using text from the clipboard. Replaces the first space/tab with an underscore, optionally adds to favourites, sets as active capture location, and resets the counter. Copies folder name to clipboard with "_7" suffix ready to rename the video file.

### New Folder from Clipboard (⌘ 9)

Identical to the New Capture Folder from Clipboard script, but with `setCaptureFolder` set to false. Useful when shooting multiple SKUs per look.

## Installation

1. Download `glassons-scripts.zip` from the latest release
2. Unzip the files
3. Copy scripts to `~/Library/Scripts/Capture One Scripts`
4. Configure keyboard shortcuts in `System Settings > Keyboard > Keyboard Shortcuts... > App Shortcuts`

## Configuration

**Rename and Export Selects:**
- Update the `exportOutputFolder` property at the top of the script to match your export destination.
- Set `exportRecipeType` property to `web-size` or `full-size`
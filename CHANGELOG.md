# Changelog

All notable changes to the Glassons Scripts will be documented in this file.

## Export Rated Images

### [1.2] - 2025-10-31

#### Added
- User-defined `exportOutputFolder` property for custom export locations

#### Changed
- Files are now overwritten instead of deleting folder contents before export
- Reduced batch rename wait time from 10s to 1s

#### Removed
- Unused `getOutputFolderPathFromCapturesPath` function
- Upload functionality

### [1.1]

#### Added
- Support for all RAW file formats (CR3, NEF, EIP, etc.)

#### Changed
- Rating filter expanded from 1-star only to 1-5 stars
- Simplified file format detection logic

### [1.0]

#### Added
- Initial release with core export functionality

## New Capture Folder from Clipboard

### [1.0] - 2025-10-31

#### Added
- Initial release with clipboard-based folder creation
- Automatic capture location setting
- Capture counter reset functionality

## New Folder from Clipboard

### [1.0] - 2025-10-31

#### Added
- Initial release with clipboard-based folder creation
- Favorites integration

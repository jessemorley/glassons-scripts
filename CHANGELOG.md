# Changelog

All notable changes to the Glassons Scripts will be documented in this file.

## [1.3.0] - 2025-11-02

### Added

- Automated installation script (`install.command`) with Capture One version detection (supports v15-23) and error handling
- Automated keyboard shortcut configuration for all three scripts

### Changed

- Simplified installation process to double-click installer instead of manual file copying and shortcut setup
- Updated README with streamlined installation instructions
- New Capture Folder from Clipboard and New Folder from Clipboard now always reset capture counter

### Removed

- Removed `resetCaptureCounter` configuration property from both clipboard folder scripts

## [1.2.4] - 2025-11-01

### Changed

- Renamed "Rename and Export Rated Images" script to "Rename and Export Selects"
- Updated all references to renamed script across documentation and configuration files
- Updated New Folder from Clipboard script description in README to clarify its relationship to New Capture Folder from Clipboard
- Changed New Folder from Clipboard `setCaptureFolder` property to `false` (distinguishing it from New Capture Folder from Clipboard)

## [1.2.3] - 2025-10-31

### Added

- Added error handling for unmounted export volume/folder with user-friendly alert message in Rename and Export Selects
- Added ERROR HANDLING section in Rename and Export Selects documentation listing all validation checks

### Changed

- Updated Rename and Export Selects export output folder path to `/Volumes/ProductImages`
- Improved error alert messages in Rename and Export Selects for better clarity

## [1.2.2] - 2025-10-31

### Changed

- Updated Rename and Export Rated Images script description to clarify export dimensions and web sharpening
- README.txt now generated during release workflow instead of being tracked in repository

## [1.2.1] - 2025-10-31

### Changed

- Rename and Export Selects now scales images to 2000 x 2547 pixels (bounding dimensions)
- Rename and Export Selects applies output sharpening for screen (Amount: 60, Radius: 0.6, Threshold: 0)
- Rename and Export Selects scaling unit explicitly set to pixels to prevent incorrect unit conversion

## [1.2.0] - 2025-10-31

### Added

- User-defined `exportOutputFolder` property in Rename and Export Selects for custom export locations

### Changed

- Rename and Export Selects now overwrites files instead of deleting folder contents before export
- Reduced Rename and Export Selects batch rename wait time from 10s to 1s

### Removed

- Removed unused `getOutputFolderPathFromCapturesPath` function from Rename and Export Selects
- Removed upload functionality from Rename and Export Selects

## [1.1.0] - 2025-10-31

### Added

- Support for all RAW file formats (CR3, NEF, EIP, etc.) in Rename and Export Selects
- Rating filter expanded from 1-star only to 1-5 stars in Rename and Export Selects

### Changed

- Simplified file format detection logic in Rename and Export Selects

## [1.0.0] - 2025-10-31

### Added

- Initial release of Rename and Export Selects with core export functionality
- Initial release of New Capture Folder from Clipboard with clipboard-based folder creation
- Automatic capture location setting in New Capture Folder from Clipboard
- Capture counter reset functionality in New Capture Folder from Clipboard
- Initial release of New Folder from Clipboard with clipboard-based folder creation
- Favorites integration in New Folder from Clipboard

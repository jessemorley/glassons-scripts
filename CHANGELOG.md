# Changelog

All notable changes to the Glassons Scripts will be documented in this file.

## [1.2.4] - 2025-11-01

### Rename and Export Selects

#### Changed
- Renamed script from "Rename and Export Rated Images" to "Rename and Export Selects"
- Updated all references across documentation and configuration files

## [1.2.3] - 2025-10-31

### Rename and Export Selects

#### Added
- Error handling for unmounted export volume/folder with user-friendly alert message
- ERROR HANDLING section in script documentation listing all validation checks

#### Changed
- Updated export output folder path to `/Volumes/ProductImages`
- Simplified recipe name from "Glassons Ecom Recipe" to "Glassons Ecomm"
- Improved error alert messages for better clarity

## [1.2.2] - 2025-10-31

### Rename and Export Rated Images

#### Changed
- Updated script description to clarify export dimensions and web sharpening

### Infrastructure

#### Changed
- README.txt now generated during release workflow instead of being tracked in repository

## [1.2.1] - 2025-10-31

### Rename and Export Selects

#### Added
- Image scaling to 2000 x 2547 pixels (bounding dimensions)
- Output sharpening for screen (Amount: 60, Radius: 0.6, Threshold: 0)

#### Changed
- Scaling unit explicitly set to pixels to prevent incorrect unit conversion

## [1.2.0] - 2025-10-31

### Rename and Export Selects

#### Added
- User-defined `exportOutputFolder` property for custom export locations

#### Changed
- Files are now overwritten instead of deleting folder contents before export
- Reduced batch rename wait time from 10s to 1s

#### Removed
- Unused `getOutputFolderPathFromCapturesPath` function
- Upload functionality

## [1.1.0]

### Rename and Export Selects

#### Added
- Support for all RAW file formats (CR3, NEF, EIP, etc.)

#### Changed
- Rating filter expanded from 1-star only to 1-5 stars
- Simplified file format detection logic

## [1.0.0]

### Rename and Export Selects

#### Added
- Initial release with core export functionality

### New Capture Folder from Clipboard

#### Added
- Initial release with clipboard-based folder creation
- Automatic capture location setting
- Capture counter reset functionality

### New Folder from Clipboard

#### Added
- Initial release with clipboard-based folder creation
- Favorites integration

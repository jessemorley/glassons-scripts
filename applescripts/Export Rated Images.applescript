(*
================================================================================
GLASSONS EXPORT RATED IMAGES SCRIPT
================================================================================

DESCRIPTION:
This script exports rated images (1-5 stars) from Capture One to JPGs for the
Glassons Ecom system. It handles conflict resolution when re-running with
different selections by renaming previously unrated images, ensuring clean
exports without filename conflicts.

WORKFLOW:
1. Validate session (single document open, rated images exist)
2. Identify capture folder and SKU from rated image location
3. Rename conflicting unrated images with "_prev" suffix
4. Configure export recipe (Glassons Ecom Recipe)
5. Batch rename rated images to SKU_COUNTER format
6. Export rated images as JPGs (overwrites existing files)

RECOMMENDED SHORTCUT: Command + 6

AUTHOR: Jesse Morley
DATE: October 2025
================================================================================
*)

use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

property exportOutputFolder : "/Users/jmorley/Pictures/ProductImages"
-- The folder where exported JPG images will be saved
-- Glassons: "Volumes/ProductImages"

-- ============================================================================
-- FUNCTION: Check for Image Files
-- ============================================================================


-- Check if a folder contains any image files.
on hasImageFiles(folderPath)
	-- Count all common RAW and image formats
	set imageCount to do shell script ("find \"" & folderPath & "\" -type f \\( -iname \"*.CR3\" -o -iname \"*.NEF\" -o -iname \"*.eip\" -o -iname \"*.ARW\" -o -iname \"*.RAF\" -o -iname \"*.ORF\" -o -iname \"*.DNG\" -o -iname \"*.TIF\" -o -iname \"*.TIFF\" \\) | wc -l | bc")
	return imageCount > 0
end hasImageFiles


-- ============================================================================
-- FUNCTION: Rename Unrated Matching Images
-- ============================================================================
(*
Renames unrated images that would conflict with the new batch rename pattern.
This prevents the " 1" appendage issue when re-running the script with different
selections. Uses Capture One's batch rename to preserve catalog references.
*)
on renameUnstarredMatchingImages(capturesFolderPath, sku, ratedImagesCount)
	-- Check if image files exist
	if not my hasImageFiles(capturesFolderPath) then return -- No image files found

	-- Generate the expected new filenames that will be created
	-- Check for files matching SKU_N with any extension
	repeat with i from 1 to ratedImagesCount
		set expectedBasename to sku & "_" & i
		-- Find any file matching this basename with any extension
		set matchingFiles to do shell script "find \"" & capturesFolderPath & "\" -maxdepth 1 -name \"" & expectedBasename & ".*\" | head -1 || true"

		set fileExists to (matchingFiles is not "")

		if fileExists then
			-- Check if this file is currently rated (rating 1-5) in Capture One
			set isRated to false
			set targetVariant to null
			try
				tell application "Capture One"
					set allVariants to (get variants of current document)
					repeat with currentVariant in allVariants
						set variantPath to (get path of (get parent image of currentVariant))
						if variantPath is matchingFiles then
							set currentRating to (get rating of currentVariant)
							if currentRating is greater than or equal to 1 and currentRating is less than or equal to 5 then
								set isRated to true
								exit repeat
							else
								set targetVariant to currentVariant
							end if
						end if
					end repeat
				end tell
			on error
				-- If we can't check the rating, skip this file
				set isRated to true
			end try

			-- If the file is NOT rated, rename it using Capture One's batch rename
			if not isRated and targetVariant is not null then
				try
					tell application "Capture One"
						-- Set up batch rename for this specific variant with _prev suffix
						tell batch rename settings of current document
							set method to text and tokens
							set counter to 1
							set token format to "[Image Folder Name]_[1 Digit Counter]_prev"
						end tell

						-- Rename just this one variant using Capture One's system
						tell current document
							batch rename variants {targetVariant}
						end tell

						-- Give Capture One a moment to complete the rename
						delay 1
					end tell
				on error errMsg
					-- If Capture One rename fails, log the error but continue
				end try
			end if
		end if
	end repeat
end renameUnstarredMatchingImages


-- ============================================================================
-- MAIN SCRIPT EXECUTION - PART 1: VALIDATION AND SETUP
-- ============================================================================

tell application "Capture One"
	-- Validate only one session is open
	set windowCount to (get count of documents)
	if windowCount > 1 then
		display alert "Glassons Ecom Upload Failure." message "You have more than one Capture Session open. Please close all other sessions before attempting upload."
		return
	end if

	-- Validate that rated images exist
	set ratedVariants to (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)
	if ratedVariants = {} then
		display alert "Glassons Ecom Upload Failure." message "Please ensure you have a SKU Capture folder selected, and you have images marked with 1-5 stars."
		return
	end if

	-- Get capture folder path and SKU from first rated image
	set selectedVariant to the path of (get parent image of (get item 1 of ratedVariants))
	set capturesFolderPath to (do shell script "dirname \"" & selectedVariant & "\"")
	set outputFolderPath to exportOutputFolder
	set sku to do shell script ("basename '" & capturesFolderPath & "'")
	set ratedImagesCount to count (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)

	-- Validate we're in a Capture folder
	if "Capture" is not in capturesFolderPath then
		display alert "Glassons Ecom Upload Failure." message "Incorrect folder selected, please choose a SKU folder within the Capture folder."
		return
	end if

	-- Rename unrated images that would conflict with new naming BEFORE any other operations
	my renameUnstarredMatchingImages(capturesFolderPath, sku, ratedImagesCount)

	-- Create output folder for export
	do shell script ("mkdir -p \"" & outputFolderPath & "\"")

	-- Set up the Glassons Ecom export recipe if not already existing
	try
		get recipe "Glassons Ecom Recipe" of front document
	on error errMsg
		tell front document
			make new recipe with properties {name:"Glassons Ecom Recipe"}
		end tell
	end try

	-- Configure export options for Glassons Ecom export recipe
	tell recipe "Glassons Ecom Recipe" of front document
		set enabled to true
		set root folder type to custom location
		set root folder location to POSIX file exportOutputFolder
		set output format to JPEG
		set JPEG quality to 100
		set color profile to "sRGB Color Space Profile"
		set output sub folder to ""
		set output name format to "[Image Name]"
		set existing files to overwrite
	end tell
end tell


-- ============================================================================
-- MAIN SCRIPT EXECUTION - PART 2: RENAME AND EXPORT
-- ============================================================================

-- Bring Capture One to front
tell application "System Events" to set frontmost of process "Capture One" to true

tell application "Capture One"
	-- Configure batch rename settings for rated images
	tell batch rename settings of current document
		set method to text and tokens
		set counter to 1
		set token format to "[Image Folder Name]_[1 Digit Counter]"
	end tell

	-- Rename rated images to SKU_COUNTER format (happens asynchronously)
	tell current document
		batch rename variants (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)
	end tell

	-- Check if image files exist before waiting
	if not my hasImageFiles(capturesFolderPath) then return

	-- Wait for batch rename to complete (max 1 second for testing)
	-- Matches any file with pattern SKU_N.* (any extension)
	set setWaitForRenameScript to "/bin/bash -s <<'EOF'
	waitCount=0
	renamedImagesCount=0
	while	[[ ${renamedImagesCount} -ne " & ratedImagesCount & "  ]] && [[ ${waitCount} -lt 1 ]]
	do
		renamedImagesCount=$(find \"" & capturesFolderPath & "\" -maxdepth 1 | grep -E \"/[A-Z0-9]+_[0-9]+(_M)?\\.[^.]+$\" | wc -l | bc)
		((waitCount++))
		sleep 1
	done
EOF"
	do shell script setWaitForRenameScript

	-- Export rated images to JPGs using the configured recipe (will overwrite existing files)
	repeat with selectedVariant in (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)
		set filePath to get path of (get parent image of (get item 1 of selectedVariant))
		process filePath recipe "Glassons Ecom Recipe"
	end repeat
end tell

(*
================================================================================
END OF SCRIPT
================================================================================
*)

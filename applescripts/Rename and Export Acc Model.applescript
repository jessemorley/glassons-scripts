(*
================================================================================
GLASSONS RENAME AND EXPORT ACC MODEL SCRIPT
================================================================================

DESCRIPTION:
Renames and exports rated images from Capture One to a user-defined local output
folder. Images are exported at web-size (2000x2537px) or full-size (100%).
Handles conflict resolution when re-running with different selections by renaming
previously unrated images, ensuring clean exports without filename conflicts.

WORKFLOW:
1. Validate session (single document open, rated images exist)
2. Identify capture folder and SKU from rated image location
3. Rename conflicting unrated images with "_prev" suffix
4. Configure export recipe (Glassons Ecomm) (full-size or web-size)
5. Batch rename rated images to SKU_ACCMODEL and SKU_3-5 format
6. Export rated images as JPGs (overwrites existing files)

RENAMING SEQUENCE:
SKU_ACCMODEL, SKU_3, SKU_4, SKU_5

ERROR HANDLING:
- No images are rated
- The ProductImages drive is not mounted
- Multiple capture sessions are open
- Target capture folder is not a subfolder of the session Capture folder
- More than 4 images are selected

RECOMMENDED SHORTCUT: Command + 5

AUTHOR: Jesse Morley
LAST UPDATED: November 2025
================================================================================
*)

use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

property exportOutputFolder : "/Volumes/ProductImages"
-- The folder where exported JPG images will be saved

property exportRecipeType : "web-size"
-- Export recipe type: "full-size" or "web-size"
-- - full-size: Original dimensions, higher quality
-- - web-size: Smaller dimensions (2000 x 2537px), optimized for web

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
-- FUNCTION: Configure Export Recipe
-- ============================================================================
(*
Configures the export recipe based on the exportRecipeType property.
- full-size: Original dimensions (Fixed 100%), screen sharpening
- web-size: Smaller dimensions (2000 x 2537px), screen sharpening
*)
on configureExportRecipe(recipeName)
	tell application "Capture One"
		tell recipe recipeName of front document
			set enabled to true
			set root folder type to custom location
			set root folder location to POSIX file exportOutputFolder
			set output format to JPEG
			set JPEG quality to 95
			set color profile to "sRGB Color Space Profile"
			set output sub folder to ""
			set output name format to "[Image Name]"
			set existing files to overwrite
			-- Scale dimensions based on exportRecipeType
			if exportRecipeType is "full-size" then
				-- Full-size settings: original dimensions
				set scaling method to Fixed
				set primary scaling value to 100
			else
				-- Web-size settings: smaller dimensions (default)
				set scaling method to BoundingDimensions
				set scaling unit to pixels
				set primary scaling value to 2000
				set secondary scaling value to 2537
			end if
			-- Output sharpening for screen: Amount 60, Radius 0.6, Threshold 0
			set sharpening to for screen
			set sharpening amount to 60
			set sharpening radius to 0.6
			set sharpening threshold to 0
		end tell
	end tell
end configureExportRecipe


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

	-- Check for files matching SKU_ACCMODEL with any extension
	set expectedBasename to sku & "_ACCMODEL"
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
	
	-- Check for files matching SKU_3, SKU_4, SKU_5 with any extension
	repeat with i from 3 to 5
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
		display alert "Export Failure" message "You have more than one Capture Session open. Please close all other sessions before attempting upload."
		return
	end if

	-- Validate that rated images exist
	set ratedVariants to (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)
	if ratedVariants = {} then
		display alert "Export Failure" message "No selects detected. Please ensure have images marked with 1-5 stars."
		return
	end if

	-- Get capture folder path and SKU from first rated image
	set selectedVariant to the path of (get parent image of (get item 1 of ratedVariants))
	set capturesFolderPath to (do shell script "dirname \"" & selectedVariant & "\"")
	set outputFolderPath to exportOutputFolder
	set sku to do shell script ("basename '" & capturesFolderPath & "'")
	set ratedImagesCount to count (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)

	-- Validate image count (max 4 images)
	if ratedImagesCount > 4 then
		display alert "Export Failure" message ((ratedImagesCount as string) & " Images selected. Select fewer images and export again.")
		return
	end if

	-- Validate we're in a Capture folder
	if "Capture" is not in capturesFolderPath then
		display alert "Export Failure" message "Incorrect folder selected, please choose a SKU folder within the Capture folder."
		return
	end if

	-- Validate that export output folder/volume is accessible
	try
		do shell script "test -d \"" & outputFolderPath & "\""
	on error
		display alert "Export Failure" message "Export destination not found:" & return & outputFolderPath & return & return & "Please ensure the volume is mounted."
		return
	end try

	-- Rename unrated images that would conflict with new naming BEFORE any other operations
	my renameUnstarredMatchingImages(capturesFolderPath, sku, ratedImagesCount)

	-- Create output folder for export (ensure it exists)
	try
		do shell script ("mkdir -p \"" & outputFolderPath & "\"")
	on error errMsg
		display alert "Export Failure" message "Could not create export folder:" & return & outputFolderPath & return & return & "Error: " & errMsg
		return
	end try

	-- Set up the Glassons Ecomm export recipe if not already existing
	try
		get recipe "Glassons Ecomm" of front document
	on error errMsg
		tell front document
			make new recipe with properties {name:"Glassons Ecomm"}
		end tell
	end try

	-- Configure export options for Glassons Ecomm export recipe based on exportRecipeType
	my configureExportRecipe("Glassons Ecomm")
end tell


-- ============================================================================
-- MAIN SCRIPT EXECUTION - PART 2: RENAME AND EXPORT
-- ============================================================================

-- Bring Capture One to front
tell application "System Events" to set frontmost of process "Capture One" to true

tell application "Capture One"
	-- Get all rated variants
	set allRatedVariants to (get variants whose rating is greater than or equal to 1 and rating is less than or equal to 5)
	
	-- Split variants into groups: first image (ACCMODEL), and images 2-4 (SKU_3, SKU_4, SKU_5)
	set firstVariant to {}
	set secondVariant to {}
	set thirdVariant to {}
	set fourthVariant to {}
	set variantIndex to 1
	
	repeat with currentVariant in allRatedVariants
		if variantIndex = 1 then
			set end of firstVariant to currentVariant
		else if variantIndex = 2 then
			set end of secondVariant to currentVariant
		else if variantIndex = 3 then
			set end of thirdVariant to currentVariant
		else if variantIndex = 4 then
			set end of fourthVariant to currentVariant
		end if
		set variantIndex to variantIndex + 1
	end repeat
	
	-- Rename first image: SKU_ACCMODEL
	if (count of firstVariant) > 0 then
		tell batch rename settings of current document
			set method to text and tokens
			set counter to 1
			set token format to "[Image Folder Name]_ACCMODEL"
		end tell
		
		tell current document
			batch rename variants firstVariant
		end tell
	end if
	
	-- Rename second image: SKU_3
	if (count of secondVariant) > 0 then
		tell batch rename settings of current document
			set method to text and tokens
			set counter to 3
			set token format to "[Image Folder Name]_[1 Digit Counter]"
		end tell
		
		tell current document
			batch rename variants secondVariant
		end tell
	end if
	
	-- Rename third image: SKU_4
	if (count of thirdVariant) > 0 then
		tell batch rename settings of current document
			set method to text and tokens
			set counter to 4
			set token format to "[Image Folder Name]_[1 Digit Counter]"
		end tell
		
		tell current document
			batch rename variants thirdVariant
		end tell
	end if
	
	-- Rename fourth image: SKU_5
	if (count of fourthVariant) > 0 then
		tell batch rename settings of current document
			set method to text and tokens
			set counter to 5
			set token format to "[Image Folder Name]_[1 Digit Counter]"
		end tell
		
		tell current document
			batch rename variants fourthVariant
		end tell
	end if

	-- Check if image files exist before waiting
	if not my hasImageFiles(capturesFolderPath) then return

	-- Wait for batch rename to complete
	-- Matches any file with pattern SKU_ACCMODEL.* or SKU_3.*, SKU_4.*, SKU_5.* (any extension)
	set setWaitForRenameScript to "/bin/bash -s <<'EOF'
	waitCount=0
	renamedImagesCount=0
	while	[[ ${renamedImagesCount} -ne " & ratedImagesCount & "  ]] && [[ ${waitCount} -lt 1 ]]
	do
		renamedImagesCount=$(find \"" & capturesFolderPath & "\" -maxdepth 1 | grep -E \"/[A-Z0-9]+_(ACCMODEL|[345])(_M)?\\.[^.]+$\" | wc -l | bc)
		((waitCount++))
		sleep 1
	done
EOF"
	do shell script setWaitForRenameScript

	-- Export rated images to JPGs using the configured recipe (will overwrite existing files)
	repeat with selectedVariant in allRatedVariants
		set filePath to get path of (get parent image of selectedVariant)
		process filePath recipe "Glassons Ecomm"
	end repeat
end tell

(*
================================================================================
END OF SCRIPT
================================================================================
*)


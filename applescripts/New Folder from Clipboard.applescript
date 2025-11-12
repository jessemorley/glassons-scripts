(*
================================================================================
GLASSONS NEW FOLDER FROM CLIPBOARD
================================================================================

DESCRIPTION:
Creates a new capture folder in Capture One using text from the clipboard.
Replaces the first space/tab with an underscore, optionally adds to favourites,
optionally sets as active capture location, and resets the counter.

WORKFLOW:
1. Read folder name from clipboard
2. Process the name (replace first whitespace with underscore; tabs with spaces)
3. Create folder in Capture One's capture directory
4. Optionally add folder to Capture One favourites (configurable)
5. Optionally set as active capture location (configurable)
6. Reset capture counter
7. Copy folderName to clipboard with "_7" for video file renaming

RECOMMENDED SHORTCUT: Command + 9

AUTHOR: Jesse Morley
LAST UPDATED: October 2025
================================================================================
*)

-- ============================================================================
-- CONFIGURATION SETTINGS
-- ============================================================================

property addToFavorites : true
-- When true, adds the newly created folder to Capture One favorites

property setCaptureFolder : true
-- When true, sets the newly created folder as the active capture location

-- ============================================================================
-- MAIN SCRIPT EXECUTION
-- ============================================================================

-- Get folder name from clipboard
try
	set folderName to (the clipboard as text)
	log "Clipboard content: " & folderName
on error errMsg number errNum
	display dialog "Error reading clipboard: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
	return
end try

-- Validate clipboard is not empty
if folderName is "" then
	display dialog "Clipboard is empty. Please copy a name to the clipboard and try again." buttons {"OK"} default button "OK"
	return
end if

-- Process folder name
try
	set foundWhitespace to false
	set processedName to ""
	
	repeat with i from 1 to length of folderName
		set currentChar to character i of folderName
		
		-- Replace only the first whitespace character with underscore
		if not foundWhitespace and (currentChar is " " or currentChar is tab) then
			set processedName to processedName & "_"
			set foundWhitespace to true
		else if foundWhitespace and currentChar is tab then
			-- Replace tabs after the first whitespace with spaces
			set processedName to processedName & " "
		else
			set processedName to processedName & currentChar
		end if
	end repeat
	
	set folderName to processedName
	log "Processed folder name: " & folderName
on error errMsg number errNum
	display dialog "Error processing folder name: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
	return
end try

-- Create new folder (and set as Capture Folder if enabled)
set newDir to createNewFolderInCapture(folderName)
if newDir is not "" then
	addToFavoritesAndSetCapture(newDir, addToFavorites, setCaptureFolder)
	
	-- Copy the processed folder name plus "_7" to clipboard for the video file
	try
		set the clipboard to folderName & "_7"
		log "Copied to clipboard: " & folderName & "_7"
	on error errMsg number errNum
		display dialog "Error copying video string to clipboard: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
	end try
end if


-- ============================================================================
-- FUNCTION: Create New Folder in Capture Directory
-- ============================================================================

-- Gets the current capture directory from Capture One
-- Finds the root "Capture" folder (even if Capture One is pointing to a subfolder)
-- Checks for duplicate folders
-- Creates the new folder

on createNewFolderInCapture(folderName)
	try
		log "Starting createNewFolderInCapture with: " & folderName
		
		-- Variables for tracking capture folder name
		set captureName to ""
		set captureNameSet to false
		
		tell front document of application "Capture One"
			
			-- Get current capture directory from Capture One
			try
				set currentCaptureDir to captures
				log "Current capture dir: " & (currentCaptureDir as text)
			on error errMsg number errNum
				display dialog "Error getting capture directory from Capture One: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
				return ""
			end try
			
			-- Verify the capture directory exists; If it doesn't exist, try to find the parent "Capture" folder
			try
				set currentCaptureDir to currentCaptureDir as alias
				log "Converted to alias successfully"
			on error errMsg number errNum
				log "Current capture folder doesn't exist, attempting to use parent Capture folder"
				
				set capturePath to currentCaptureDir as text
				set oldDelims to AppleScript's text item delimiters
				set AppleScript's text item delimiters to ":Capture:"
				set pathParts to text items of capturePath
				
				if (count of pathParts) >= 2 then
					-- Reconstruct path to the "Capture" folder
					set parentPath to (first item of pathParts) & ":Capture:"
					try
						set currentCaptureDir to parentPath as alias
						set captureName to "Capture"
						set captureNameSet to true
						log "Found parent Capture folder"
					on error
						display dialog "Could not find a valid Capture folder in the path." buttons {"OK"} default button "OK"
						set AppleScript's text item delimiters to oldDelims
						return ""
					end try
				else
					display dialog "Could not parse path to find Capture folder." buttons {"OK"} default button "OK"
					set AppleScript's text item delimiters to oldDelims
					return ""
				end if
				set AppleScript's text item delimiters to oldDelims
			end try
			
			-- Get the folder name (if not already set from error handling)
			if not captureNameSet then
				try
					tell application "Finder" to set captureName to name of folder currentCaptureDir
					log "Capture folder name: " & captureName
				on error errMsg number errNum
					display dialog "Error getting folder name from Finder: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
					return ""
				end try
			end if
			
			-- Navigate to the root "Capture" folder if necessary
			-- This handles cases where Capture One is pointing to a subfolder or a sibling folder (like "Selects")
			if captureName is not "Capture" then
				try
					tell application "Finder"
						set d to currentCaptureDir as alias
						set fullPath to POSIX path of d
						
						if fullPath contains "/Capture/" then
							-- Navigate to Capture folder from subfolder
							repeat while captureName is not "Capture"
								set d to container of d as alias
								set captureName to name of folder d
							end repeat
							set currentCaptureDir to d as alias
							log "Found Capture folder by navigating up from subfolder"
						else
							-- Navigate to Capture folder from sibling folder (e.g. "Output")
							set parentDir to container of d as alias
							if exists folder "Capture" of parentDir then
								set currentCaptureDir to folder "Capture" of parentDir as alias
								log "Found Capture folder at sibling level"
							else
								display dialog "Could not find Capture folder at expected location." buttons {"OK"} default button "OK"
								return ""
							end if
						end if
					end tell
				on error errMsg number errNum
					display dialog "Error adjusting path: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
					return ""
				end try
			end if
			
			-- Build path for new folder
			set newDirPath to POSIX path of currentCaptureDir & folderName
			log "New folder path will be: " & newDirPath
			
			-- Check for duplicate folder
			tell application "Finder"
				if exists folder folderName of currentCaptureDir then
					tell application "Capture One"
						display alert "Duplicate Folder" message "A folder named \"" & folderName & "\" already exists in the Capture folder." as critical
					end tell
					return ""
				end if
			end tell
			
			-- Create the new folder
			tell application "Finder"
				try
					make new folder at currentCaptureDir with properties {name:folderName}
					log "Folder created successfully"
				on error errMsg number errNum
					display dialog "Error creating folder: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
					return ""
				end try
			end tell
			
			return newDirPath
		end tell
	on error errMsg number errNum
		display dialog "Unexpected error in createNewFolderInCapture: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
		return ""
	end try
end createNewFolderInCapture


-- ============================================================================
-- FUNCTION: Add to Favorites and Configure Capture Settings
-- ============================================================================

-- Optionally adds the folder path to Capture One favorites
-- Optionally setting the path as the active capture location
-- Resets the capture counter to 0

on addToFavoritesAndSetCapture(dirPath, addToFav, setCapture)
	try
		log "Starting addToFavoritesAndSetCapture"
		
		tell front document of application "Capture One"
			
			-- Add folder to Capture One favorites (if requested)
			if addToFav is true then
				try
					make collection with properties {kind:favorite, file:dirPath}
					log "Added to favorites: " & dirPath
				on error errMsg number errNum
					display dialog "Error adding to favorites: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
					return
				end try
			end if
			
			-- Set as active capture folder (if requested)
			if setCapture is true then
				try
					set captures to dirPath
					log "Set capture folder to: " & dirPath
				on error errMsg number errNum
					display dialog "Error setting capture folder: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
					return
				end try
			end if
			
			-- Reset capture counter
			try
				set capture counter to 0
				log "Reset capture counter to 0"
			on error errMsg number errNum
				display dialog "Error resetting counter: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
				return
			end try
		end tell
		
		log "addToFavoritesAndSetCapture completed successfully"
	on error errMsg number errNum
		display dialog "Unexpected error in addToFavoritesAndSetCapture: " & errMsg & " (" & errNum & ")" buttons {"OK"} default button "OK"
	end try
end addToFavoritesAndSetCapture

(*
================================================================================
END OF SCRIPT
================================================================================
*)

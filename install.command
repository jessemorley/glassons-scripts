#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR=$(dirname "${0}")
INSTALL_DIR="${HOME}/Library/Scripts/Capture One Scripts"

# Function to detect Capture One bundle identifier
detect_captureone_bundle() {
  # Common Capture One bundle IDs (newest first)
  local bundles=(
    "com.captureone.captureone23"
    "com.captureone.captureone22"
    "com.captureone.captureone21"
    "com.captureone.captureone16"
    "com.captureone.captureone15"
  )

  for bundle in "${bundles[@]}"; do
    if defaults read "${bundle}" &>/dev/null; then
      echo "${bundle}"
      return 0
    fi
  done

  return 1
}

# Function to display error and exit
error_exit() {
  echo ""
  echo "ERROR: $1"
  echo ""
  exit 1
}

# Detect Capture One installation
echo "Detecting Capture One installation..."
CAPTUREONE=$(detect_captureone_bundle)

if [ -z "${CAPTUREONE}" ]; then
  error_exit "Capture One not found. Please install Capture One before running this script."
fi

echo "  ✓ Found: ${CAPTUREONE}"
echo ""

ADD_SHORTCUT="defaults write ${CAPTUREONE} NSUserKeyEquivalents -dict-add"

# Validate source directory exists
if [ ! -d "${SCRIPT_DIR}/applescripts" ]; then
  error_exit "Source directory '${SCRIPT_DIR}/applescripts' not found."
fi

# Check if there are any scripts to install
SCRIPT_COUNT=$(find "${SCRIPT_DIR}/applescripts" -name "*.applescript" -type f | wc -l | tr -d ' ')
if [ "${SCRIPT_COUNT}" -eq 0 ]; then
  error_exit "No .applescript files found in '${SCRIPT_DIR}/applescripts'."
fi

# Create install directory if it doesn't exist
echo "Installing Glassons Capture One Scripts..."
echo ""
if ! mkdir -p "${INSTALL_DIR}"; then
  error_exit "Failed to create directory '${INSTALL_DIR}'."
fi

# Copy scripts
echo "Copying scripts to ${INSTALL_DIR}..."
COPIED_COUNT=0
for script in "${SCRIPT_DIR}/applescripts"/*.applescript ; do
  if [ -f "${script}" ]; then
    filename=$(basename "${script}")
    if cp "${script}" "${INSTALL_DIR}/"; then
      echo "  ✓ ${filename}"
      ((COPIED_COUNT++))
    else
      error_exit "Failed to copy '${filename}'."
    fi
  fi
done

if [ "${COPIED_COUNT}" -eq 0 ]; then
  error_exit "No scripts were copied."
fi

echo ""
echo "Setting keyboard shortcuts..."

# Rename and Export Selects - ⌘6
if ${ADD_SHORTCUT} "Rename and Export Selects" "@6"; then
  echo "  ✓ Rename and Export Selects: ⌘6"
else
  echo "  ⚠ Warning: Failed to set shortcut for Rename and Export Selects"
fi

# New Capture Folder from Clipboard - ⌘0
if ${ADD_SHORTCUT} "New Capture Folder from Clipboard" "@0"; then
  echo "  ✓ New Capture Folder from Clipboard: ⌘0"
else
  echo "  ⚠ Warning: Failed to set shortcut for New Capture Folder from Clipboard"
fi

# New Folder from Clipboard - ⌘9
if ${ADD_SHORTCUT} "New Folder from Clipboard" "@9"; then
  echo "  ✓ New Folder from Clipboard: ⌘9"
else
  echo "  ⚠ Warning: Failed to set shortcut for New Folder from Clipboard"
fi

echo ""
echo "Installation complete! Installed ${COPIED_COUNT} script(s)."
echo ""
echo "Note: You may need to restart Capture One for the keyboard shortcuts to take effect."
echo "If shortcuts don't work, verify them in: System Settings > Keyboard > Shortcuts > App Shortcuts"

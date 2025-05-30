#!/bin/bash
# 
# Script to install Pano clipboard manager as GNOME Shell extension
# This script is idempotent - it can be run multiple times without side effects.
# Sudo privileges will be requested only for commands that require it.

# Source the shared helper functions
source $OMAKUB_PATH/shared/helpers.sh

# --- Configuration ---
APP_NAME="pano"
EXTENSION_NAME="pano@elhan.io"
REPO_OWNER="oae"
REPO_NAME="gnome-shell-pano"
REPO_PATH="${REPO_OWNER}/${REPO_NAME}"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/${EXTENSION_NAME}"
TEMP_DIR=$(create_temp_dir)

# Set up logging
LOG_FILE=$(setup_log "$APP_NAME")

# --- Main Script ---
log_message "INFO" "Starting ${APP_NAME} installation script..." "$LOG_FILE"
log_message "INFO" "Temporary directory: ${TEMP_DIR}" "$LOG_FILE"

# 1. Check if required tools are available
if ! command_exists unzip; then
  log_message "INFO" "Installing unzip..." "$LOG_FILE"
  sudo apt update && sudo apt install -y unzip >> "$LOG_FILE" 2>&1
fi

# 3. Check if the extension is already installed
if [ -d "$EXTENSION_DIR" ]; then
  log_message "INFO" "Pano extension is already installed at $EXTENSION_DIR" "$LOG_FILE"
  echo "Do you want to reinstall it? (y/n)"
  read -r choice
  
  if [[ $choice != "y" && $choice != "Y" ]]; then
    log_message "INFO" "Installation skipped by user." "$LOG_FILE"
    return 0
  fi
  
  log_message "INFO" "Removing existing installation at $EXTENSION_DIR" "$LOG_FILE"
  rm -rf "$EXTENSION_DIR"
fi

# 4. Get release information
log_message "INFO" "Fetching release information..." "$LOG_FILE"

# Use a specific release tag instead of "latest" since we know which release we need
RELEASE_TAG="v23-alpha5"  # Known working pre-release version
log_message "INFO" "Using release: ${RELEASE_TAG}" "$LOG_FILE"

# Direct download URL for the extension zip file
DOWNLOAD_URL="https://github.com/${REPO_PATH}/releases/download/${RELEASE_TAG}/${EXTENSION_NAME}.zip"
log_message "INFO" "Download URL: ${DOWNLOAD_URL}" "$LOG_FILE"

# 6. Set up the download file path
ZIP_FILE="${TEMP_DIR}/${EXTENSION_NAME}.zip"

# 7. Download the extension zip file
log_message "INFO" "Downloading Pano extension..." "$LOG_FILE"
if ! download_file "$DOWNLOAD_URL" "$ZIP_FILE" "$LOG_FILE"; then
  log_message "ERROR" "Failed to download Pano extension." "$LOG_FILE"
  return 1
fi

log_message "SUCCESS" "Pano extension downloaded successfully" "$LOG_FILE"

# 9. Create extension directory if it doesn't exist
mkdir -p "$EXTENSION_DIR"
log_message "INFO" "Created extension directory: $EXTENSION_DIR" "$LOG_FILE"

# 10. Extract the extension to the GNOME Shell extensions directory
log_message "INFO" "Extracting extension to $EXTENSION_DIR" "$LOG_FILE"
unzip -o "$ZIP_FILE" -d "$EXTENSION_DIR" >> "$LOG_FILE" 2>&1

# 11. Clean up
# rm -rf "$TEMP_DIR"

# 12. Verify installation
if [ -f "$EXTENSION_DIR/metadata.json" ]; then
  log_message "SUCCESS" "Pano extension installed successfully!" "$LOG_FILE"
  
  # Configure GNOME to auto-enable the extension
  if command_exists gnome-extensions; then
    log_message "INFO" "Enabling Pano extension..." "$LOG_FILE"
    gnome-extensions enable "$EXTENSION_NAME" >> "$LOG_FILE" 2>&1 || true
  fi
  
  log_message "INFO" "To use Pano, you need to log out and log back in or restart the GNOME Shell." "$LOG_FILE"
  log_message "INFO" "After that, you can enable the extension using the GNOME Extensions app if it's not already enabled." "$LOG_FILE"
else
  log_message "ERROR" "Installation failed. metadata.json not found in $EXTENSION_DIR" "$LOG_FILE" 
  return 1
fi

log_message "INFO" "Complete installation log saved to $LOG_FILE" "$LOG_FILE"

sleep 15

return 0

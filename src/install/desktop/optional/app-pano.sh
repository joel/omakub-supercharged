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

log_message "INFO" "Installing dependencies..." "$LOG_FILE"
sudo apt update
sudo apt install gir1.2-gda-5.0 gir1.2-gsound-1.0

log_message "INFO" "Cloning ${REPO_NAME} repository..." "$LOG_FILE"
RELEASE_TAG="v23-alpha5"  # Known working pre-release version
git clone https://github.com/oae/gnome-shell-pano.git -b "$RELEASE_TAG" --depth 1 $HOME/.gnome-shell-pano

log_message "INFO" "Building ${REPO_NAME}..." "$LOG_FILE"
cd $HOME/.gnome-shell-pano
npm install
npm run build

log_message "INFO" "Copying ${REPO_PATH} to GNOME Shell extensions directory ..." "$LOG_FILE"
if [ -d "$EXTENSION_DIR" ]; then
  log_message "INFO" "Removing existing extension directory: $EXTENSION_DIR" "$LOG_FILE"
  rm -rf "$EXTENSION_DIR"
fi
mkdir -p "$EXTENSION_DIR"
cp -r dist/* "$EXTENSION_DIR"

log_message "INFO" "Complete installation log saved to $LOG_FILE" "$LOG_FILE"

cd -

sleep 15

return 0

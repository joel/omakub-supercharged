#!/usr/bin/env bash

# Install Antigravity IDE from the official Google apt repository.
# See https://antigravity.google/download/linux

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

set -euo pipefail

KEY_URL="https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg"
KEYRING_PATH="/etc/apt/keyrings/antigravity-repo-key.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/antigravity.list"
SOURCE_LINE="deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main"
PACKAGE_NAME="antigravity"

tmp_dir="$(create_temp_dir)"
key_file="$tmp_dir/antigravity-repo-signing-key.gpg"

cleanup() {
  if [[ -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
    log_message "INFO" "Cleaned up temporary directory: $tmp_dir" "$LOG_FILE"
  fi
}
trap cleanup EXIT

log_message "INFO" "Starting Antigravity installation..." "$LOG_FILE"

log_message "INFO" "Updating apt package lists..." "$LOG_FILE"
if ! sudo apt-get update >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to update apt package lists." "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Installing prerequisites (ca-certificates, curl, gnupg)..." "$LOG_FILE"
if ! sudo apt-get install -y ca-certificates curl gnupg >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to install prerequisites." "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Ensuring keyring directory exists..." "$LOG_FILE"
if ! sudo mkdir -p /etc/apt/keyrings >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to create /etc/apt/keyrings." "$LOG_FILE"
  exit 1
fi

if ! download_file "$KEY_URL" "$key_file" "$LOG_FILE"; then
  log_message "ERROR" "Failed to download Antigravity repository key." "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Installing Antigravity repository key..." "$LOG_FILE"
if ! sudo gpg --dearmor --yes -o "$KEYRING_PATH" "$key_file" >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to import Antigravity repository key." "$LOG_FILE"
  exit 1
fi

if ! sudo chmod 644 "$KEYRING_PATH" >>"$LOG_FILE" 2>&1; then
  log_message "WARNING" "Unable to chmod $KEYRING_PATH to 644 (non-fatal)." "$LOG_FILE"
fi

if [[ -f "$SOURCE_LIST_PATH" ]] && sudo grep -Fxq "$SOURCE_LINE" "$SOURCE_LIST_PATH" >>"$LOG_FILE" 2>&1; then
  log_message "INFO" "Antigravity apt source is already configured." "$LOG_FILE"
else
  log_message "INFO" "Writing Antigravity apt source list..." "$LOG_FILE"
  if ! echo "$SOURCE_LINE" | sudo tee "$SOURCE_LIST_PATH" >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to write $SOURCE_LIST_PATH." "$LOG_FILE"
    exit 1
  fi
fi

log_message "INFO" "Refreshing apt cache after repository setup..." "$LOG_FILE"
if ! sudo apt-get update >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to refresh apt cache." "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Installing $PACKAGE_NAME package..." "$LOG_FILE"
if ! sudo apt-get install -y "$PACKAGE_NAME" >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to install $PACKAGE_NAME." "$LOG_FILE"
  exit 1
fi

if package_installed "$PACKAGE_NAME"; then
  log_message "SUCCESS" "Antigravity installed successfully." "$LOG_FILE"
else
  log_message "ERROR" "Package verification failed for $PACKAGE_NAME." "$LOG_FILE"
  exit 1
fi

log_message "SUCCESS" "Antigravity installation script finished." "$LOG_FILE"

sleep 3

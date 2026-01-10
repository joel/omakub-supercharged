#!/usr/bin/env bash

# Install Bitwarden desktop app (deb package).
# See https://bitwarden.com/download/

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

log_message "INFO" "Updating package lists..." "$LOG_FILE"
if ! sudo apt-get update >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to update package lists." "$LOG_FILE"
  exit 1
fi

tmp_dir="$(create_temp_dir)"
cd "$tmp_dir" || {
  log_message "ERROR" "Failed to cd to temp dir $tmp_dir" "$LOG_FILE"
  exit 1
}

deb_url="https://bitwarden.com/download/?app=desktop&platform=linux&variant=deb"
deb_file="$tmp_dir/bitwarden.deb"

if ! download_file "$deb_url" "$deb_file" "$LOG_FILE"; then
  log_message "ERROR" "Failed to download Bitwarden .deb package." "$LOG_FILE"
  exit 1
fi

if install_deb_package "$deb_file" "$LOG_FILE"; then
  log_message "SUCCESS" "Bitwarden installed successfully." "$LOG_FILE"
else
  log_message "ERROR" "Failed to install Bitwarden." "$LOG_FILE"
  exit 1
fi

rm -f "$deb_file"
log_message "INFO" "Cleaned up the downloaded package." "$LOG_FILE"

log_message "SUCCESS" "Bitwarden installation script finished." "$LOG_FILE"

sleep 3

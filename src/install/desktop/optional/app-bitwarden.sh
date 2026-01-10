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

log_message "INFO" "Configuring Bitwarden native messaging for Chromium-based browsers..." "$LOG_FILE"
source_host="$HOME/.config/google-chrome/NativeMessagingHosts/com.8bit.bitwarden.json"
if [[ -f "$source_host" ]]; then
  chromium_target_dirs=(
    "$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    "$HOME/.config/BraveSoftware/Brave-Browser-Beta/NativeMessagingHosts"
    "$HOME/.config/BraveSoftware/Brave-Browser-Nightly/NativeMessagingHosts"
    "$HOME/.config/google-chrome-beta/NativeMessagingHosts"
    "$HOME/.config/google-chrome-unstable/NativeMessagingHosts"
    "$HOME/.config/chromium/NativeMessagingHosts"
  )

  for target_dir in "${chromium_target_dirs[@]}"; do
    if mkdir -p "$target_dir" && ln -sf "$source_host" "$target_dir/com.8bit.bitwarden.json"; then
      log_message "SUCCESS" "Linked Bitwarden host to $target_dir" "$LOG_FILE"
    else
      log_message "WARNING" "Failed to link Bitwarden host to $target_dir" "$LOG_FILE"
    fi
  done
else
  log_message "WARNING" "Bitwarden native messaging host not found at $source_host; run Bitwarden once and re-run this installer to link other browsers." "$LOG_FILE"
fi

rm -f "$deb_file"
log_message "INFO" "Cleaned up the downloaded package." "$LOG_FILE"

log_message "SUCCESS" "Bitwarden installation script finished." "$LOG_FILE"

sleep 3

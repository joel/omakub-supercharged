#!/usr/bin/env bash

# Install NordVPN GUI.
# See https://nordvpn.com/

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

log_message "INFO" "Starting NordVPN GUI installation..." "$LOG_FILE"

cleanup() {
  if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
    log_message "INFO" "Cleaned up temporary files." "$LOG_FILE"
  fi
}

TMP_DIR="$(create_temp_dir)"
if [[ -z "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
  log_message "ERROR" "Failed to create temporary directory." "$LOG_FILE"
  exit 1
fi

INSTALL_SCRIPT="$TMP_DIR/nordvpn-install.sh"
INSTALL_URL="https://downloads.nordcdn.com/apps/linux/install.sh"

if ! download_file "$INSTALL_URL" "$INSTALL_SCRIPT" "$LOG_FILE"; then
  log_message "ERROR" "Failed to download NordVPN installer." "$LOG_FILE"
  cleanup
  exit 1
fi

chmod +x "$INSTALL_SCRIPT"

log_message "INFO" "Running NordVPN installer (nordvpn-gui)..." "$LOG_FILE"
if sh "$INSTALL_SCRIPT" -p nordvpn-gui >>"$LOG_FILE" 2>&1; then
  log_message "SUCCESS" "NordVPN GUI installed successfully." "$LOG_FILE"
else
  log_message "ERROR" "NordVPN installer failed." "$LOG_FILE"
  cleanup
  exit 1
fi

if getent group nordvpn >/dev/null 2>&1; then
  log_message "INFO" "Group 'nordvpn' already exists." "$LOG_FILE"
else
  if sudo groupadd nordvpn >>"$LOG_FILE" 2>&1; then
    log_message "SUCCESS" "Created group 'nordvpn'." "$LOG_FILE"
  else
    log_message "ERROR" "Failed to create group 'nordvpn'." "$LOG_FILE"
    cleanup
    exit 1
  fi
fi

if sudo usermod -aG nordvpn "$USER" >>"$LOG_FILE" 2>&1; then
  log_message "SUCCESS" "Added $USER to 'nordvpn' group." "$LOG_FILE"
else
  log_message "ERROR" "Failed to add $USER to 'nordvpn' group." "$LOG_FILE"
  cleanup
  exit 1
fi

log_message "WARNING" "Reboot required for group membership changes to take effect." "$LOG_FILE"

cleanup

log_message "SUCCESS" "NordVPN installation script finished." "$LOG_FILE"

sleep 3

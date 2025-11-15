#!/usr/bin/env bash

set -euo pipefail

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

POSTMAN_URL="https://dl.pstmn.io/download/latest/linux_64"
POSTMAN_SHARE_DIR="${HOME}/.local/share"
POSTMAN_DIR="${POSTMAN_SHARE_DIR}/Postman"
POSTMAN_BIN="${POSTMAN_DIR}/Postman"
TMP_DIR="$(create_temp_dir)"
ARCHIVE_PATH="${TMP_DIR}/postman.tar.gz"
LOCAL_BIN_DIR="${HOME}/.local/bin"
LOCAL_BIN_LINK="${LOCAL_BIN_DIR}/postman"
APPLICATIONS_DIR="${HOME}/.local/share/applications"
DESKTOP_TEMPLATE="${OMAKUB_PATH}/configs/postman.desktop"
DESKTOP_TARGET="${APPLICATIONS_DIR}/postman.desktop"

log_message "INFO" "Starting Postman installation" "$LOG_FILE"
log_message "INFO" "Download URL: ${POSTMAN_URL}" "$LOG_FILE"

mkdir -p "$POSTMAN_SHARE_DIR"

if [[ -d "$POSTMAN_DIR" ]]; then
  log_message "INFO" "Removing previous Postman installation at ${POSTMAN_DIR}" "$LOG_FILE"
  rm -rf "$POSTMAN_DIR"
fi

if ! download_file "$POSTMAN_URL" "$ARCHIVE_PATH" "$LOG_FILE"; then
  log_message "ERROR" "Unable to download Postman package" "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Extracting Postman archive to ${POSTMAN_SHARE_DIR}" "$LOG_FILE"
if tar -xzf "$ARCHIVE_PATH" -C "$POSTMAN_SHARE_DIR" >>"$LOG_FILE" 2>&1; then
  log_message "SUCCESS" "Postman extracted to ${POSTMAN_DIR}" "$LOG_FILE"
else
  log_message "ERROR" "Failed to extract Postman archive" "$LOG_FILE"
  exit 1
fi

if [[ ! -x "$POSTMAN_BIN" ]]; then
  log_message "ERROR" "Postman binary not found after extraction" "$LOG_FILE"
  exit 1
fi

chmod +x "$POSTMAN_BIN"
mkdir -p "$LOCAL_BIN_DIR"
ln -sf "$POSTMAN_BIN" "$LOCAL_BIN_LINK"
log_message "INFO" "Symlinked ${POSTMAN_BIN} to ${LOCAL_BIN_LINK}" "$LOG_FILE"

mkdir -p "$APPLICATIONS_DIR"
if [[ -f "$DESKTOP_TEMPLATE" ]]; then
  sed "s|/home/joel|${HOME}|g" "$DESKTOP_TEMPLATE" > "$DESKTOP_TARGET"
  chmod 644 "$DESKTOP_TARGET"
  log_message "INFO" "Desktop entry installed at ${DESKTOP_TARGET}" "$LOG_FILE"
else
  log_message "WARNING" "Desktop entry template not found at ${DESKTOP_TEMPLATE}" "$LOG_FILE"
fi

log_message "SUCCESS" "Postman installation completed successfully" "$LOG_FILE"
gum spin --spinner globe --title "Postman install completed" -- sleep 2

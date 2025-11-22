#!/usr/bin/env bash

set -euo pipefail

# Source shared log initialization (provides LOG_FILE and helper funcs)
source "${OMAKUB_PATH}/shared/log-init"

INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/sxyazi/yazi/main/install.sh"
TMP_DIR="$(create_temp_dir)"
INSTALL_SCRIPT_PATH="${TMP_DIR}/yazi-install.sh"

log_message "INFO" "Starting Yazi installation..." "$LOG_FILE"

mkdir -p "${HOME}/.local/bin"

if command -v yazi >/dev/null 2>&1; then
  log_message "INFO" "Yazi already present; running installer to update to latest." "$LOG_FILE"
fi

if ! download_file "$INSTALL_SCRIPT_URL" "$INSTALL_SCRIPT_PATH" "$LOG_FILE"; then
  log_message "ERROR" "Unable to download Yazi installer from ${INSTALL_SCRIPT_URL}" "$LOG_FILE"
  sleep 5
  exit 1
fi

chmod +x "$INSTALL_SCRIPT_PATH"

if bash "$INSTALL_SCRIPT_PATH" >>"$LOG_FILE" 2>&1; then
  log_message "SUCCESS" "Yazi installer finished successfully." "$LOG_FILE"
else
  log_message "ERROR" "Yazi installer failed. Check ${LOG_FILE} for details." "$LOG_FILE"
  sleep 5
  exit 1
fi

YAZI_BIN="$(command -v yazi || true)"
if [[ -x "$YAZI_BIN" ]]; then
  log_message "INFO" "Yazi binary detected at ${YAZI_BIN}" "$LOG_FILE"
  if YAZI_VERSION_OUTPUT=$(yazi --version 2>&1); then
    log_message "INFO" "$YAZI_VERSION_OUTPUT" "$LOG_FILE"
  fi
else
  log_message "WARNING" "Yazi binary not found on PATH after install." "$LOG_FILE"
fi

gum spin --spinner globe --title "Yazi install completed" -- sleep 3

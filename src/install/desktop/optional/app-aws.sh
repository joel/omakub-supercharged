#!/usr/bin/env bash

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

set -euo pipefail

APP_NAME="aws-cli"

tmp_dir="$(create_temp_dir)"
cd "$tmp_dir" || {
  log_message "ERROR" "Failed to cd to temp dir $tmp_dir" "$LOG_FILE"
  exit 1
}

log_message "INFO" "Starting $APP_NAME installation flow" "$LOG_FILE"

if snap list "$APP_NAME" >/dev/null 2>&1; then
  log_message "INFO" "$APP_NAME already installed; checking for updates" "$LOG_FILE"

  if SNAP_REFRESH_LIST_OUTPUT=$(snap refresh --list 2>>"$LOG_FILE"); then
    if echo "$SNAP_REFRESH_LIST_OUTPUT" | grep -qE '^aws-cli[[:space:]]'; then
      log_message "INFO" "Update available for $APP_NAME; refreshing" "$LOG_FILE"
      if ! sudo snap refresh aws-cli >>"$LOG_FILE" 2>&1; then
        log_message "ERROR" "Failed to refresh $APP_NAME snap" "$LOG_FILE"
        exit 1
      fi
      log_message "INFO" "$APP_NAME refresh completed" "$LOG_FILE"
    else
      log_message "INFO" "No newer $APP_NAME revision available" "$LOG_FILE"
    fi
  else
    log_message "WARN" "Could not determine update availability for $APP_NAME; attempting refresh" "$LOG_FILE"
    if ! sudo snap refresh aws-cli >>"$LOG_FILE" 2>&1; then
      log_message "ERROR" "Failed to refresh $APP_NAME snap" "$LOG_FILE"
      exit 1
    fi
    log_message "INFO" "$APP_NAME refresh completed" "$LOG_FILE"
  fi
else
  log_message "INFO" "Installing $APP_NAME via snap" "$LOG_FILE"
  if ! sudo snap install aws-cli --classic >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to install $APP_NAME via snap" "$LOG_FILE"
    exit 1
  fi
  log_message "INFO" "$APP_NAME installed successfully" "$LOG_FILE"
fi

if AWS_VERSION_OUTPUT=$(aws --version 2>&1); then
  log_message "INFO" "$AWS_VERSION_OUTPUT" "$LOG_FILE"
else
  log_message "WARN" "aws --version command failed" "$LOG_FILE"
fi

gum spin --spinner globe --title "aws-cli ready" -- sleep 2

log_message "INFO" "$APP_NAME installation flow finished" "$LOG_FILE"

gum confirm "Go back to the menu?"

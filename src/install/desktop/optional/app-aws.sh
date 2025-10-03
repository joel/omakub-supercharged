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
  log_message "INFO" "$APP_NAME already installed; skipping snap install" "$LOG_FILE"
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

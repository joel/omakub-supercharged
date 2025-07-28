#!/usr/bin/env bash

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

log_message "INFO" "Starting Fish installation..." "$LOG_FILE"

sudo apt install -y fish || {
  log_message "ERROR" "Failed to install Fish shell" "$LOG_FILE"
  exit 1
}

#!/usr/bin/env bash

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

log_message "INFO" "Starting Fish installation..." "$LOG_FILE"

sudo apt install -y fish || {
  log_message "ERROR" "Failed to install Fish shell" "$LOG_FILE"
  exit 1
}


log_message "INFO" "Fish installation completed successfully." "$LOG_FILE"

log_message "INFO" "Installing Fish plugins..." "$LOG_FILE"

# Fisher A plugin manager for Fish
# https://github.com/jorgebucaran/fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

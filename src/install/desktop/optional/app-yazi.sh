#!/usr/bin/env bash

set -euo pipefail

# Source shared log initialization (provides LOG_FILE and helper funcs)
source "${OMAKUB_PATH}/shared/log-init"

APP_NAME="yazi"
SNAP_NAME="yazi"

log_message "INFO" "Starting ${APP_NAME} installation via snap (edge, classic confinement)..." "$LOG_FILE"

if ! command -v snap >/dev/null 2>&1; then
  log_message "ERROR" "snapd is not available; install snapd first." "$LOG_FILE"
  sleep 5
  exit 1
fi

if snap list "$SNAP_NAME" >/dev/null 2>&1; then
  log_message "INFO" "${APP_NAME} snap already installed; refreshing from edge channel." "$LOG_FILE"
  if ! sudo snap refresh "$SNAP_NAME" --edge >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to refresh ${APP_NAME} snap from edge channel." "$LOG_FILE"
    sleep 5
    exit 1
  fi
else
  log_message "INFO" "Installing ${APP_NAME} snap (edge, classic confinement)..." "$LOG_FILE"
  if ! sudo snap install "$SNAP_NAME" --classic --edge >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to install ${APP_NAME} snap." "$LOG_FILE"
    sleep 5
    exit 1
  fi
fi

if SNAP_INFO=$(snap info "$SNAP_NAME" 2>/dev/null); then
  log_message "INFO" "snap info ${SNAP_NAME}: ${SNAP_INFO}" "$LOG_FILE"
fi

if YAZI_VERSION_OUTPUT=$(yazi --version 2>&1); then
  log_message "INFO" "$YAZI_VERSION_OUTPUT" "$LOG_FILE"
fi

gum spin --spinner globe --title "Yazi install completed" -- sleep 3

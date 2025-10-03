#!/usr/bin/env bash

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

set -euo pipefail

APP_NAME="kubectl"
KUBE_KEYRING="/etc/apt/keyrings/kubernetes-apt-keyring.gpg"

KUBECTL_INSTALLED=false
PREVIOUS_VERSION=""

tmp_dir="$(create_temp_dir)"
cd "$tmp_dir" || {
  log_message "ERROR" "Failed to cd to temp dir $tmp_dir" "$LOG_FILE"
  exit 1
}

log_message "INFO" "Starting $APP_NAME installation (Kubernetes CLI)" "$LOG_FILE"
log_message "INFO" "Using temp directory: $tmp_dir" "$LOG_FILE"

if command -v kubectl >/dev/null 2>&1; then
  KUBECTL_INSTALLED=true
  PREVIOUS_VERSION=$(kubectl version --client --output=yaml 2>>"$LOG_FILE" | grep gitVersion | awk '{print $2}') || PREVIOUS_VERSION="unknown"
  log_message "INFO" "$APP_NAME already present (current version: ${PREVIOUS_VERSION:-unknown})" "$LOG_FILE"
else
  log_message "INFO" "$APP_NAME not detected; proceeding with fresh installation" "$LOG_FILE"
fi

# Prerequisites
log_message "INFO" "Updating apt cache" "$LOG_FILE"
if ! sudo apt-get update -y >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "apt-get update failed" "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Installing transport + CA + curl + gnupg packages" "$LOG_FILE"
if ! sudo apt-get install -y apt-transport-https ca-certificates curl gnupg >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed installing prerequisite packages" "$LOG_FILE"
  exit 1
fi

# Ensure keyrings directory exists BEFORE writing key (handle older distros)
if [[ ! -d /etc/apt/keyrings ]]; then
  log_message "INFO" "Creating /etc/apt/keyrings directory" "$LOG_FILE"
  if ! sudo mkdir -p -m 755 /etc/apt/keyrings >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to create /etc/apt/keyrings" "$LOG_FILE"
    exit 1
  fi
fi

log_message "INFO" "Adding Kubernetes apt repository key" "$LOG_FILE"
if ! curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o "$KUBE_KEYRING" 2>>"$LOG_FILE"; then
  log_message "ERROR" "Failed fetching or storing Kubernetes Release.key" "$LOG_FILE"
  exit 1
fi
if ! sudo chmod 644 "$KUBE_KEYRING" >>"$LOG_FILE" 2>&1; then
  log_message "WARN" "Could not chmod keyring (non-fatal)" "$LOG_FILE"
fi

# Add the Kubernetes apt source list (idempotent)
KUBE_LIST="/etc/apt/sources.list.d/kubernetes.list"
if [[ ! -f "$KUBE_LIST" ]] || ! grep -q "pkgs.k8s.io/core:/stable:/v1.34/deb" "$KUBE_LIST" 2>/dev/null; then
  log_message "INFO" "Creating Kubernetes apt source list" "$LOG_FILE"
  if ! echo "deb [signed-by=$KUBE_KEYRING] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | sudo tee "$KUBE_LIST" >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed writing $KUBE_LIST" "$LOG_FILE"
    exit 1
  fi
else
  log_message "INFO" "Kubernetes apt source already present" "$LOG_FILE"
fi

log_message "INFO" "Refreshing apt cache after adding Kubernetes repo" "$LOG_FILE"
if ! sudo apt-get update -y >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "apt-get update failed after adding Kubernetes repo" "$LOG_FILE"
  exit 1
fi

if [[ "$KUBECTL_INSTALLED" == "true" ]]; then
  log_message "INFO" "$APP_NAME detected; attempting upgrade to latest version" "$LOG_FILE"
  if ! sudo apt-get install -y --only-upgrade kubectl >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to upgrade $APP_NAME" "$LOG_FILE"
    exit 1
  fi
else
  log_message "INFO" "Installing $APP_NAME" "$LOG_FILE"
  if ! sudo apt-get install -y kubectl >>"$LOG_FILE" 2>&1; then
    log_message "ERROR" "Failed to install kubectl" "$LOG_FILE"
    exit 1
  fi
fi

if command -v kubectl >/dev/null 2>&1; then
  CLIENT_VERSION=$(kubectl version --client --output=yaml 2>>"$LOG_FILE" | grep gitVersion | awk '{print $2}') || CLIENT_VERSION="unknown"
  if [[ "$KUBECTL_INSTALLED" == "true" ]]; then
    log_message "INFO" "$APP_NAME now at version: $CLIENT_VERSION (previous: ${PREVIOUS_VERSION:-unknown})" "$LOG_FILE"
  else
    log_message "INFO" "$APP_NAME installed successfully (client version: $CLIENT_VERSION)" "$LOG_FILE"
  fi
else
  log_message "ERROR" "$APP_NAME binary not found in PATH after installation" "$LOG_FILE"
  exit 1
fi

gum spin --spinner globe --title "kubectl install completed" -- sleep 2

log_message "INFO" "kubectl installation flow finished" "$LOG_FILE"

gum confirm "Go back to the menu?"

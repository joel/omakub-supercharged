#!/usr/bin/env bash

# https://github.com/ByteNess/aws-vault/releases

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

set -euo pipefail

APP_NAME="aws-vault"
REPO_SLUG="ByteNess/aws-vault"
GITHUB_API_URL="https://api.github.com/repos/${REPO_SLUG}/releases/latest"
DEFAULT_INSTALL_PATH="/usr/local/bin/aws-vault"

extract_semver() {
  local raw="$1"
  local pattern='v?([0-9]+(\.[0-9]+)*)'
  if [[ "$raw" =~ $pattern ]]; then
    local match="${BASH_REMATCH[0]}"
    match="${match#v}"
    echo "$match"
  else
    echo "unknown"
  fi
}

ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)
    ARCH_LABEL="amd64"
    ;;
  arm64|aarch64)
    ARCH_LABEL="arm64"
    ;;
  *)
    log_message "ERROR" "Unsupported architecture: $ARCH" "$LOG_FILE"
    exit 1
    ;;
esac

if ! command_exists python3; then
  log_message "ERROR" "python3 is required to process GitHub release metadata" "$LOG_FILE"
  exit 1
fi

if ! command_exists curl && ! command_exists wget; then
  log_message "ERROR" "Neither curl nor wget is available for downloading releases" "$LOG_FILE"
  exit 1
fi

tmp_dir="$(create_temp_dir)"

cleanup() {
  if [[ -n "${tmp_dir:-}" && -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

cd "$tmp_dir" || {
  log_message "ERROR" "Failed to cd to temp dir $tmp_dir" "$LOG_FILE"
  exit 1
}

log_message "INFO" "Starting $APP_NAME installation" "$LOG_FILE"
log_message "INFO" "Working directory: $tmp_dir" "$LOG_FILE"

INSTALL_PATH="$DEFAULT_INSTALL_PATH"
AWS_VAULT_INSTALLED=false
PREVIOUS_VERSION="unknown"
PREVIOUS_VERSION_OUTPUT=""

if command -v aws-vault >/dev/null 2>&1; then
  AWS_VAULT_INSTALLED=true
  INSTALL_PATH="$(command -v aws-vault)"
  PREVIOUS_VERSION_OUTPUT="$(aws-vault --version 2>&1 || true)"
  PREVIOUS_VERSION="$(extract_semver "$PREVIOUS_VERSION_OUTPUT")"
  log_message "INFO" "$APP_NAME already present at $INSTALL_PATH (version: ${PREVIOUS_VERSION_OUTPUT:-unknown})" "$LOG_FILE"
else
  log_message "INFO" "$APP_NAME not detected in PATH; preparing fresh install" "$LOG_FILE"
fi

log_message "INFO" "Fetching latest release metadata from GitHub" "$LOG_FILE"
if command_exists curl; then
  if ! RELEASE_JSON=$(curl -fsSL "$GITHUB_API_URL" 2>>"$LOG_FILE"); then
    log_message "ERROR" "Failed to download release metadata via curl" "$LOG_FILE"
    exit 1
  fi
else
  if ! RELEASE_JSON=$(wget -qO- "$GITHUB_API_URL" 2>>"$LOG_FILE"); then
    log_message "ERROR" "Failed to download release metadata via wget" "$LOG_FILE"
    exit 1
  fi
fi

if ! ASSET_INFO=$(RELEASE_JSON="$RELEASE_JSON" ARCH_LABEL="$ARCH_LABEL" python3 - <<'PY'
import json
import os
import sys

data = json.loads(os.environ["RELEASE_JSON"])
arch = os.environ["ARCH_LABEL"]

tag = data.get("tag_name") or "unknown"
suffix = f"linux-{arch}"

for asset in data.get("assets", []):
    name = asset.get("name") or ""
    url = asset.get("browser_download_url") or ""
    if suffix in name and url:
        print(f"{url}|{name}|{tag}")
        break
else:
    sys.exit(1)
PY
); then
  log_message "ERROR" "Unable to locate a linux-$ARCH_LABEL asset in the latest release" "$LOG_FILE"
  exit 1
fi

ASSET_URL="${ASSET_INFO%%|*}"
ASSET_REMAINDER="${ASSET_INFO#*|}"
ASSET_NAME="${ASSET_REMAINDER%%|*}"
LATEST_TAG="${ASSET_REMAINDER##*|}"
LATEST_VERSION="$(extract_semver "$LATEST_TAG")"

log_message "INFO" "Latest available version: ${LATEST_TAG:-unknown}" "$LOG_FILE"
log_message "INFO" "Selected asset: $ASSET_NAME" "$LOG_FILE"

if [[ "$AWS_VAULT_INSTALLED" == "true" && "$PREVIOUS_VERSION" != "unknown" && "$LATEST_VERSION" != "unknown" && "$PREVIOUS_VERSION" == "$LATEST_VERSION" ]]; then
  log_message "INFO" "$APP_NAME already at latest version ($PREVIOUS_VERSION); skipping download" "$LOG_FILE"
  gum spin --spinner globe --title "$APP_NAME ready" -- sleep 2
  log_message "INFO" "$APP_NAME installation flow finished" "$LOG_FILE"
  gum confirm "Go back to the menu?"
  exit 0
fi

ASSET_PATH="$tmp_dir/$ASSET_NAME"
log_message "INFO" "Downloading $ASSET_URL" "$LOG_FILE"
if ! download_file "$ASSET_URL" "$ASSET_PATH" "$LOG_FILE"; then
  log_message "ERROR" "Failed to download $ASSET_NAME" "$LOG_FILE"
  exit 1
fi

EXTRACT_DIR="$tmp_dir/extracted"
mkdir -p "$EXTRACT_DIR"

log_message "INFO" "Extracting $ASSET_NAME" "$LOG_FILE"
case "$ASSET_NAME" in
  *.tar.gz|*.tgz)
    if ! tar -xzf "$ASSET_PATH" -C "$EXTRACT_DIR" >>"$LOG_FILE" 2>&1; then
      log_message "ERROR" "Failed to extract tar.gz archive" "$LOG_FILE"
      exit 1
    fi
    ;;
  *.tar.xz|*.txz)
    if ! tar -xJf "$ASSET_PATH" -C "$EXTRACT_DIR" >>"$LOG_FILE" 2>&1; then
      log_message "ERROR" "Failed to extract tar.xz archive" "$LOG_FILE"
      exit 1
    fi
    ;;
  *.zip)
    if command -v unzip >/dev/null 2>&1; then
      if ! unzip -o "$ASSET_PATH" -d "$EXTRACT_DIR" >>"$LOG_FILE" 2>&1; then
        log_message "ERROR" "Failed to unzip archive" "$LOG_FILE"
        exit 1
      fi
    elif command -v bsdtar >/dev/null 2>&1; then
      if ! bsdtar -xf "$ASSET_PATH" -C "$EXTRACT_DIR" >>"$LOG_FILE" 2>&1; then
        log_message "ERROR" "Failed to extract archive with bsdtar" "$LOG_FILE"
        exit 1
      fi
    else
      log_message "ERROR" "Neither unzip nor bsdtar available to extract zip archive" "$LOG_FILE"
      exit 1
    fi
    ;;
  *)
    cp "$ASSET_PATH" "$EXTRACT_DIR/aws-vault" >>"$LOG_FILE" 2>&1
    ;;
esac

BINARY_CANDIDATE=$(find "$EXTRACT_DIR" -type f -perm -u+x -name 'aws-vault*' ! -name '*.sha*' -print -quit 2>/dev/null || true)

if [[ -z "$BINARY_CANDIDATE" ]]; then
  BINARY_CANDIDATE=$(find "$EXTRACT_DIR" -type f -name 'aws-vault*' ! -name '*.sha*' -print -quit 2>/dev/null || true)
fi

if [[ -z "$BINARY_CANDIDATE" ]]; then
  log_message "ERROR" "No aws-vault binary found after extraction" "$LOG_FILE"
  exit 1
fi

chmod +x "$BINARY_CANDIDATE"

log_message "INFO" "Installing $APP_NAME to $INSTALL_PATH" "$LOG_FILE"
if ! sudo install -m 755 "$BINARY_CANDIDATE" "$INSTALL_PATH" >>"$LOG_FILE" 2>&1; then
  log_message "ERROR" "Failed to install $APP_NAME binary" "$LOG_FILE"
  exit 1
fi

if command -v aws-vault >/dev/null 2>&1; then
  NEW_VERSION_OUTPUT="$(aws-vault --version 2>&1 || true)"
  NEW_VERSION="$(extract_semver "$NEW_VERSION_OUTPUT")"
  if [[ "$AWS_VAULT_INSTALLED" == "true" ]]; then
    log_message "INFO" "$APP_NAME upgraded to version: ${NEW_VERSION_OUTPUT:-unknown} (previous: ${PREVIOUS_VERSION_OUTPUT:-unknown})" "$LOG_FILE"
  else
    log_message "INFO" "$APP_NAME installed successfully (version: ${NEW_VERSION_OUTPUT:-unknown})" "$LOG_FILE"
  fi
else
  log_message "ERROR" "$APP_NAME binary not found in PATH after installation" "$LOG_FILE"
  exit 1
fi

gum spin --spinner globe --title "$APP_NAME ready" -- sleep 2

log_message "INFO" "$APP_NAME installation flow finished" "$LOG_FILE"

gum confirm "Go back to the menu?"

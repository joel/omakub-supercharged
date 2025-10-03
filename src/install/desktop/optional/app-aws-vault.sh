#!/usr/bin/env bash

# https://github.com/ByteNess/aws-vault/releases

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

set -euo pipefail

APP_NAME="aws-vault"
REPO="ByteNess/aws-vault"
LATEST_RELEASE_URL="https://github.com/${REPO}/releases/latest"
INSTALL_PATH="/usr/local/bin/aws-vault"

command -v curl >/dev/null 2>&1 || {
  log_message "ERROR" "curl is required to install ${APP_NAME}" "$LOG_FILE"
  exit 1
}

ARCH_SUFFIX=""
case "$(uname -m)" in
  x86_64|amd64) ARCH_SUFFIX="linux-amd64" ;;
  arm64|aarch64) ARCH_SUFFIX="linux-arm64" ;;
  *)
    log_message "ERROR" "Unsupported architecture $(uname -m)" "$LOG_FILE"
    exit 1
    ;;
esac

tmp_dir="$(create_temp_dir)"
trap 'rm -rf "${tmp_dir}"' EXIT
cd "$tmp_dir" || {
  log_message "ERROR" "Failed to enter temp directory ${tmp_dir}" "$LOG_FILE"
  exit 1
}

log_message "INFO" "Preparing ${APP_NAME} installation" "$LOG_FILE"

current_path=""
current_version=""
if command -v aws-vault >/dev/null 2>&1; then
  current_path="$(command -v aws-vault)"
  current_version="$(aws-vault --version 2>&1 | head -n1)"
  log_message "INFO" "Existing ${APP_NAME} detected at ${current_path} (${current_version:-unknown})" "$LOG_FILE"
else
  log_message "INFO" "No existing ${APP_NAME} binary found; continuing with fresh install" "$LOG_FILE"
fi

log_message "INFO" "Checking latest release metadata" "$LOG_FILE"

# Grab the final tag from the redirect URL
latest_tag=$(curl -fsSL -o /dev/null -w '%{url_effective}' "$LATEST_RELEASE_URL" 2>>"$LOG_FILE" | awk -F'/' 'NF{print $NF}')
if [[ -z "${latest_tag}" ]]; then
  log_message "ERROR" "Unable to determine latest release tag" "$LOG_FILE"
  exit 1
fi

latest_version="${latest_tag#v}"

# Pull the release HTML once so we can find the correct download link.
release_html=$(curl -fsSL "$LATEST_RELEASE_URL" 2>>"$LOG_FILE") || {
  log_message "ERROR" "Failed to fetch release page" "$LOG_FILE"
  exit 1
}

asset_path=$(printf '%s\n' "$release_html" | grep -oE "/${REPO}/releases/download/${latest_tag}/aws-vault[^\"]*${ARCH_SUFFIX}[^\"]*" | head -n1 || true)

if [[ -z "${asset_path}" ]]; then
  log_message "ERROR" "Could not locate a ${ARCH_SUFFIX} asset on the release page" "$LOG_FILE"
  exit 1
fi

download_url="https://github.com${asset_path}"
archive_name="${asset_path##*/}"
archive_path="${tmp_dir}/${archive_name}"

if [[ -n "${current_version}" && "${current_version}" == *"${latest_version}"* ]]; then
  final_message="${APP_NAME} already at latest version (${current_version:-unknown})"
  log_message "INFO" "$final_message" "$LOG_FILE"
  gum spin --spinner globe --title "${APP_NAME} current" -- sleep 2
  log_message "INFO" "${APP_NAME} installation flow finished" "$LOG_FILE"
  gum confirm "Go back to the menu?"
  exit 0
fi

log_message "INFO" "Downloading ${archive_name}" "$LOG_FILE"
if ! download_file "$download_url" "$archive_path" "$LOG_FILE"; then
  log_message "ERROR" "Download failed" "$LOG_FILE"
  exit 1
fi

log_message "INFO" "Extracting archive" "$LOG_FILE"
case "$archive_name" in
  *.tar.gz|*.tgz)
    tar -xzf "$archive_path" >>"$LOG_FILE" 2>&1 ;;
  *.zip)
    unzip -o "$archive_path" >>"$LOG_FILE" 2>&1 ;;
  *)
    log_message "ERROR" "Unsupported archive format: ${archive_name}" "$LOG_FILE"
    exit 1
    ;;
esac

binary_path=$(find "$tmp_dir" -maxdepth 2 -type f -name 'aws-vault*' -perm -u+x | head -n1 || true)

if [[ -z "${binary_path}" ]]; then
  log_message "ERROR" "aws-vault binary not found after extraction" "$LOG_FILE"
  exit 1
fi

sudo install -m 755 "$binary_path" "$INSTALL_PATH" >>"$LOG_FILE" 2>&1

new_version="$(aws-vault --version 2>&1 | head -n1)"

if [[ -n "${current_version}" ]]; then
  final_message="${APP_NAME} updated: ${current_version:-unknown} -> ${new_version:-unknown}"
  spinner_title="${APP_NAME} updated"
else
  final_message="${APP_NAME} installed: ${new_version:-unknown}"
  spinner_title="${APP_NAME} installed"
fi

log_message "INFO" "$final_message" "$LOG_FILE"

gum spin --spinner globe --title "$spinner_title" -- sleep 2

log_message "INFO" "${APP_NAME} installation flow finished" "$LOG_FILE"

gum confirm "Go back to the menu?"

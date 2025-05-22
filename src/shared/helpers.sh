#!/usr/bin/env bash

# Shared helper functions for Omakub installation scripts
# This file contains common utilities used across multiple scripts

# Define colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
BOLD="\033[1m"
RESET="\033[0m"

# Setup logging for scripts
# Usage: setup_log "app-name"
setup_log() {
  local app_name="$1"
  local timestamp=$(date '+%Y%m%d_%H%M%S')
  local log_dir="/home/joel/.local/share/omakub/logs"
  
  # Create logs directory if it doesn't exist
  mkdir -p "$log_dir"
  
  # Create log file with timestamp
  local log_file="${log_dir}/${app_name}_install_${timestamp}.log"
  
  # Return the log file path
  echo "$log_file"
}

# Print a formatted message with timestamp
# Usage: log_message "INFO" "Message to log" "$log_file"
log_message() {
  local level="$1"
  local message="$2"
  local log_file="$3"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  case "$level" in
    "INFO")
      level_color="$BLUE"
      ;;
    "SUCCESS")
      level_color="$GREEN"
      ;;
    "WARNING")
      level_color="$YELLOW"
      ;;
    "ERROR")
      level_color="$RED"
      ;;
    *)
      level_color="$RESET"
      ;;
  esac
  
  # Print to console with color
  echo -e "${level_color}${timestamp} [${level}]${RESET} ${message}"
  
  # Print to log file without color codes
  echo "${timestamp} [${level}] ${message}" >> "$log_file"
}

# Check if a command exists
# Usage: if command_exists "curl"; then ...
command_exists() {
  command -v "$1" &> /dev/null
}

# Check if a package is installed via apt
# Usage: if package_installed "package-name"; then ...
package_installed() {
  dpkg -s "$1" &> /dev/null
}

# Download a file with progress indication
# Usage: download_file "https://example.com/file.deb" "/tmp/file.deb" "$log_file"
download_file() {
  local url="$1"
  local output_path="$2"
  local log_file="$3"
  
  log_message "INFO" "Downloading ${url}" "$log_file"
  
  if command_exists curl; then
    if curl -L --progress-bar "$url" -o "$output_path"; then
      log_message "SUCCESS" "Download completed: $output_path" "$log_file"
      return 0
    else
      log_message "ERROR" "Download failed" "$log_file"
      return 1
    fi
  elif command_exists wget; then
    if wget --show-progress -q "$url" -O "$output_path"; then
      log_message "SUCCESS" "Download completed: $output_path" "$log_file"
      return 0
    else
      log_message "ERROR" "Download failed" "$log_file"
      return 1
    fi
  else
    log_message "ERROR" "Neither curl nor wget are installed" "$log_file"
    return 1
  fi
}

# Create a temporary directory and ensure it's cleaned up on exit
# Usage: tmp_dir=$(create_temp_dir)
create_temp_dir() {
  local tmp_dir=$(mktemp -d)
#   trap "rm -rf $tmp_dir" EXIT
  echo "$tmp_dir"
}

# Install a .deb package and handle errors
# Usage: install_deb_package "/path/to/package.deb" "$log_file"
install_deb_package() {
  local deb_path="$1"
  local log_file="$2"
  
  log_message "INFO" "Installing package from: $deb_path" "$log_file"
  
  if sudo dpkg -i "$deb_path" >> "$log_file" 2>&1; then
    log_message "SUCCESS" "Package installed successfully" "$log_file"
    return 0
  else
    log_message "WARNING" "Dependencies may be missing, attempting to fix..." "$log_file"
    if sudo apt-get -f install -y >> "$log_file" 2>&1; then
      log_message "SUCCESS" "Dependencies resolved and package installed" "$log_file"
      return 0
    else
      log_message "ERROR" "Failed to install package" "$log_file"
      return 1
    fi
  fi
}

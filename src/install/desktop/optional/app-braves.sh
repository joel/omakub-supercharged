#!/usr/bin/env bash
# filepath: /home/joel/.local/share/omakub/install/desktop/opt  # Install Brave Browser versions
# Script to install Brave Browser Stable, Beta, and Nightly
# This script is idempotent - it can be run multiple times without side effects.
# Sudo privileges will be requested only for commands that require it.

# Source the shared helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMAKUB_ROOT="/home/joel/.local/share/omakub"
HELPERS_PATH="${OMAKUB_ROOT}/shared/helpers.sh"

# Source helper functions
if [ -f "$HELPERS_PATH" ]; then
  source "$HELPERS_PATH"
else
  echo "Error: Helper functions not found at $HELPERS_PATH"
  echo "Please ensure the shared directory is properly set up."
  return 1 2>/dev/null || { echo "Script cannot continue."; return 1; }
fi

# Define the main function to allow both sourcing and direct execution
install_brave_browsers() {
  # --- Configuration ---
  APP_NAME="brave-browsers"
  TEMP_DIR=$(create_temp_dir)
  
  # Set up logging
  LOG_FILE=$(setup_log "$APP_NAME")
  
  # --- Main Script ---
  
  log_message "INFO" "Starting Brave Browser installation script..." "$LOG_FILE"
  log_message "INFO" "Current time: $(date)" "$LOG_FILE"
  log_message "INFO" "Temporary directory: ${TEMP_DIR}" "$LOG_FILE"
  
  # 1. Install prerequisites (gum is assumed to be already installed)
  log_message "INFO" "Checking and installing prerequisites..." "$LOG_FILE"
  
  # Use gum with proper syntax
  gum spin --spinner dot --title "Updating package lists..." -- bash -c "sudo apt-get update 2>&1 | tee '${TEMP_DIR}/apt_update_output.txt'"
  cat "${TEMP_DIR}/apt_update_output.txt" >> "$LOG_FILE"
  
  # Install required packages with gum
  gum spin --spinner dot --title "Installing dependencies..." -- bash -c "sudo apt-get install -y curl gpg apt-transport-https 2>&1 | tee '${TEMP_DIR}/apt_install_output.txt'"
  cat "${TEMP_DIR}/apt_install_output.txt" >> "$LOG_FILE"
  log_message "INFO" "Prerequisites installed successfully" "$LOG_FILE"

  # 2. Add repositories for all Brave channels
  log_message "INFO" "Setting up Brave Browser repositories for all channels..." "$LOG_FILE"
  
  # Follow the official Brave browser installation instructions for each channel
  log_message "INFO" "Setting up GPG keys and repositories for all Brave Browser channels..." "$LOG_FILE"
  
  # Function to set up GPG key and repository for a Brave channel
  setup_brave_channel() {
    local channel="$1"       # release, beta, or nightly
    local display_name="$2"  # Release, Beta, or Nightly
    
    # Define paths based on channel
    local key_file=""
    local key_path=""
    local repo_path="/etc/apt/sources.list.d/brave-browser-${channel}.list"
    
    # The release channel has a different key naming pattern than beta and nightly
    if [ "$channel" = "release" ]; then
      key_path="/usr/share/keyrings/brave-browser-archive-keyring.gpg"
      key_file="brave-browser-archive-keyring.gpg"
    else
      key_path="/usr/share/keyrings/brave-browser-${channel}-archive-keyring.gpg"
      key_file="brave-browser-${channel}-archive-keyring.gpg"
    fi
    
    # Download and install GPG key
    log_message "INFO" "Setting up GPG key for Brave Browser ${display_name}..." "$LOG_FILE"
    
    gum spin --spinner dot --title "Downloading Brave Browser ${display_name} key..." -- \
      bash -c "sudo curl -fsSLo '${key_path}' https://brave-browser-apt-${channel}.s3.brave.com/${key_file} 2>&1"
    
    # Check if key was properly installed
    if [ -f "$key_path" ] && [ -s "$key_path" ]; then
      log_message "SUCCESS" "GPG key for Brave Browser ${display_name} installed successfully" "$LOG_FILE"
      gum style --foreground 10 -- "✓ GPG key for Brave Browser ${display_name} installed"
      
      # Set up repository
      gum spin --spinner dot --title "Setting up Brave ${display_name} repository..." -- \
        bash -c "echo 'deb [signed-by=${key_path}] https://brave-browser-apt-${channel}.s3.brave.com/ stable main' | sudo tee ${repo_path} > /dev/null"
      
      log_message "SUCCESS" "Brave ${display_name} repository set up at ${repo_path}" "$LOG_FILE"
      gum style --foreground 10 -- "✓ Brave ${display_name} repository set up"
      
      return 0
    else
      log_message "ERROR" "Failed to install GPG key for Brave Browser ${display_name}" "$LOG_FILE"
      gum style --foreground 9 -- "✗ Failed to install GPG key for Brave Browser ${display_name}"
      
      return 1
    fi
  }
  
  # Set up each Brave channel
  setup_brave_channel "release" "Release"
  setup_brave_channel "beta" "Beta"
  setup_brave_channel "nightly" "Nightly"
  
  log_message "INFO" "All Brave repositories setup completed" "$LOG_FILE"
  
  # Force apt update after key import to refresh the repositories
  log_message "INFO" "Updating package lists after key import..." "$LOG_FILE"
  gum spin --spinner dot --title "Updating package lists..." -- bash -c "sudo apt-get update -y 2>&1 | tee '${TEMP_DIR}/apt_update_after_key.txt'"
  cat "${TEMP_DIR}/apt_update_after_key.txt" >> "$LOG_FILE"

  # 3. Install Brave Browser versions

  # Function to install a specific Brave Browser variant
  install_brave_variant() {
    local package_name="$1"   # Package name: brave-browser, brave-browser-beta, brave-browser-nightly
    local display_name="$2"   # Display name: Stable, Beta, Nightly
    
    log_message "INFO" "Installing Brave Browser ${display_name}..." "$LOG_FILE"
    
    if package_installed "$package_name"; then
      log_message "INFO" "Brave Browser ${display_name} is already installed" "$LOG_FILE"
      gum style --foreground 10 -- "✓ Brave Browser ${display_name} is already installed"
      return 0
    fi
    
    # Install the package
    gum spin --spinner line --title "Installing Brave Browser ${display_name}..." -- \
      bash -c "sudo apt-get install -y ${package_name} 2>&1 | tee '${TEMP_DIR}/${package_name}-install.txt'"
      
    # Check if installation was successful
    if package_installed "$package_name"; then
      log_message "SUCCESS" "Brave Browser ${display_name} installed successfully" "$LOG_FILE"
      gum style --foreground 10 -- "✓ Brave Browser ${display_name} installed successfully"
      return 0
    else
      log_message "ERROR" "Failed to install Brave Browser ${display_name}" "$LOG_FILE"
      gum style --foreground 9 -- "✗ Failed to install Brave Browser ${display_name}"
      return 1
    fi
  }
  
  # Install all Brave Browser variants
  install_brave_variant "brave-browser" "Stable"
  install_brave_variant "brave-browser-beta" "Beta"
  install_brave_variant "brave-browser-nightly" "Nightly"
  
  # Print success message
  gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 60 --margin "1 2" --padding "1 2" \
    -- "✨ Brave Browser Installation Complete! ✨"
  
  log_message "INFO" "You should find Brave Stable, Beta, and Nightly in your application menu" "$LOG_FILE"
  log_message "INFO" "Commands to run them from the terminal:" "$LOG_FILE"
  log_message "INFO" "  Stable:   brave-browser" "$LOG_FILE"
  log_message "INFO" "  Beta:     brave-browser-beta" "$LOG_FILE"
  log_message "INFO" "  Nightly:  brave-browser-nightly" "$LOG_FILE"
  log_message "INFO" "To set a version as default browser:" "$LOG_FILE"
  log_message "INFO" "  xdg-settings set default-web-browser brave-browser.desktop" "$LOG_FILE"
  log_message "INFO" "  xdg-settings set default-web-browser brave-browser-beta.desktop" "$LOG_FILE"
  log_message "INFO" "  xdg-settings set default-web-browser brave-browser-nightly.desktop" "$LOG_FILE"
  
  log_message "INFO" "Complete installation log saved to $LOG_FILE" "$LOG_FILE"
  
  # Show instructions with gum
  gum style --foreground 45 -- "Brave Browser versions installed:"
  gum style --foreground 45 -- "- Stable: brave-browser"
  gum style --foreground 45 -- "- Beta: brave-browser-beta"
  gum style --foreground 45 -- "- Nightly: brave-browser-nightly"
  gum style --foreground 45 -- "Installation logs saved to: $LOG_FILE"
  
  # Copy log to system-wide location for admin reference
  sudo cp "$LOG_FILE" "/usr/local/share/brave-browsers-install-log-$(date +%Y%m%d_%H%M%S).log"
  
  return 0
}

# Execute the function
install_brave_browsers
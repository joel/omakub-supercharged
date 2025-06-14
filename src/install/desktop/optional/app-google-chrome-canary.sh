
#!/usr/bin/env bash

# Browse the web with the Canary version of the most popular browser.
# See https://www.google.com/chrome/canary/


# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

tmp_dir="$(create_temp_dir)"
cd "$tmp_dir" || exit 1

deb_url="https://dl.google.com/linux/direct/google-chrome-canary_current_amd64.deb"
deb_file="$tmp_dir/google-chrome-canary_current_amd64.deb"

download_file "$deb_url" "$deb_file" "$log_file"
if install_deb_package "$deb_file" "$log_file"; then
  log_message "SUCCESS" "Google Chrome Canary installed successfully." "$log_file"
else
  log_message "ERROR" "Failed to install Google Chrome Canary." "$log_file"
  exit 1
fi

rm -f "$deb_file"
log_message "INFO" "Cleaned up the downloaded package." "$log_file"

xdg-settings set default-web-browser google-chrome-canary.desktop
log_message "INFO" "Set Google Chrome Canary as the default web browser." "$log_file"

log_message "SUCCESS" "Google Chrome Canary installation script finished." "$log_file"
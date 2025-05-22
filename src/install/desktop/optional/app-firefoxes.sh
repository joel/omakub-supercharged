#!/bin/bash

# Script to install Firefox Stable, Beta, Developer Edition, and Nightly
# Ensure you run this script with sudo: sudo ./install_firefox_versions.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---
download_and_extract() {
    local product_name="$1" # e.g., "Firefox Beta"
    local download_url="$2"
    local install_dir_name="$3" # e.g., "firefox-beta"
    local symlink_name="$4" # e.g., "firefox-beta"
    local desktop_entry_name="$5" # e.g., "Firefox Beta"
    local generic_name="$6" # e.g., "Web Browser (Beta)"
    local icon_path="/opt/$install_dir_name/browser/chrome/icons/default/default128.png" # Standard icon path
    local actual_downloaded_filename # Variable to store the actual filename determined by wget

    echo "--- Installing $product_name ---"

    cd /tmp

    echo "Downloading $product_name..."
    # Use --trust-server-names to get the actual filename, or parse it
    # For simplicity, we'll assume .tar.xz for now as per the log
    # and save with the correct extension.
    local temp_tar_filename="$install_dir_name.tar.xz"
    wget -O "$temp_tar_filename" "$download_url" -U "Mozilla/5.0 (X11; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0"

    echo "Removing existing installation directory if present: /opt/$install_dir_name"
    sudo rm -rf "/opt/$install_dir_name"

    echo "Extracting $product_name to /opt/..."
    # Use -J for .tar.xz files
    sudo tar -xJf "$temp_tar_filename" -C /opt/
    # Ensure the extracted directory has the expected name; Mozilla often extracts to just 'firefox'
    if [ -d "/opt/firefox" ] && [ ! -d "/opt/$install_dir_name" ]; then
        sudo mv "/opt/firefox" "/opt/$install_dir_name"
    elif [ ! -d "/opt/$install_dir_name" ]; then
        echo "Error: Extraction did not result in the expected directory: /opt/$install_dir_name or /opt/firefox"
        # Attempt to find what it *was* extracted as, if it's just 'firefox'
        if [ -d "/opt/firefox" ]; then
            echo "Found '/opt/firefox'. Renaming it to '/opt/$install_dir_name'."
            sudo mv "/opt/firefox" "/opt/$install_dir_name"
        else
            echo "Could not find the extracted 'firefox' directory to rename."
            # Try to list contents of /opt to help debug if something unexpected happened
            echo "Current contents of /opt/:"
            ls -lah /opt/
            return 1
        fi
    fi


    echo "Creating symbolic link: /usr/local/bin/$symlink_name"
    sudo ln -sf "/opt/$install_dir_name/firefox" "/usr/local/bin/$symlink_name"

    echo "Creating .desktop file: /usr/share/applications/$symlink_name.desktop"
    sudo bash -c "cat > /usr/share/applications/$symlink_name.desktop <<EOL
[Desktop Entry]
Name=$desktop_entry_name
GenericName=$generic_name
Comment=Browse the World Wide Web
Exec=/usr/local/bin/$symlink_name %u
Icon=$icon_path
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupWMClass=$(echo "$desktop_entry_name" | sed 's/ Edition//' | sed 's/ //g') # Guess WMClass
EOL"

    echo "Cleaning up downloaded archive..."
    rm "$temp_tar_filename"

    echo "$product_name installation complete."
    echo "You can run it using the command: $symlink_name"
    echo "Or find it in your application menu as '$desktop_entry_name'."
    echo "-------------------------------------"
}

# --- Stable Firefox (from APT) ---
install_firefox_stable() {
    echo "--- Installing Firefox Stable (from APT) ---"
    sudo apt update
    sudo apt install -y firefox
    echo "Firefox Stable installation complete."
    echo "It should be available in your application menu and as 'firefox' in the terminal."
    echo "-------------------------------------"
}

# --- Main Installation ---

# 1. Install Firefox Stable
install_firefox_stable

# 2. Install Firefox Beta
# URLs are for the latest 64-bit Linux, English-US version.
# Mozilla often updates the exact path structure for "latest" links.
# These product codes are standard:
# firefox-beta-latest-ssl
# firefox-devedition-latest-ssl (Developer Edition)
# firefox-nightly-latest-ssl

BETA_URL="https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux64&lang=en-US"
DEVELOPER_URL="https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"
NIGHTLY_URL="https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"

download_and_extract "Firefox Beta" "$BETA_URL" "firefox-beta" "firefox-beta" "Firefox Beta" "Web Browser (Beta)"
download_and_extract "Firefox Developer Edition" "$DEVELOPER_URL" "firefox-developer" "firefox-developer" "Firefox Developer Edition" "Web Browser (Developer)"
download_and_extract "Firefox Nightly" "$NIGHTLY_URL" "firefox-nightly" "firefox-nightly" "Firefox Nightly" "Web Browser (Nightly)"

echo "--- All Firefox installations complete! ---"
echo "To set a version as default, use your system settings or:"
echo "sudo xdg-settings set default-web-browser <desktop-file-name>.desktop"
echo "Examples:"
echo "  xdg-settings set default-web-browser firefox.desktop (for stable, if that's its .desktop name)"
echo "  xdg-settings set default-web-browser firefox-beta.desktop"
echo "  xdg-settings set default-web-browser firefox-developer.desktop"
echo "  xdg-settings set default-web-browser firefox-nightly.desktop"

exit 0
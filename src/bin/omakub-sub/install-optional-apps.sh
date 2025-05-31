normalize() {
  echo "$1" | sed 's/^✖ *//;s/^✔ *//;s/  \{2,\}.*$//' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g'
}

# Helper to get status and tick using the new helper
icon_status() {
  local item="$1"

  app_name=$(normalize "$item")

  if [[ "$app_name" == gnome-extension-* ]]; then
    extension_name="${app_name#gnome-extension-}"
    if gnome-extensions list | grep -q "$extension_name"; then
      echo "✔ $item"
      return
    else
      echo "✖ $item"
      return
    fi
  fi

  if command -v "$app_name" &> /dev/null; then
    echo "✔ $item"
  else
    echo "✖ $item"
  fi
}

CHOICES=(
  "$(icon_status 'Code Insiders                     Code editor for developers')"
  "$(icon_status 'Linkquisition                   Browser-picker')"
  "$(icon_status 'Brave Browser                   Brave Browser Stable')"
  "$(icon_status 'Brave Browser Beta              Brave Browser Beta')"
  "$(icon_status 'Brave Browser Nightly           Brave Browser Nightly')"
  "$(icon_status 'Firefox                         Firefox Stable')"
  "$(icon_status 'Firefox Beta                    Firefox Beta Channel')"
  "$(icon_status 'Firefox Developer               Firefox Developer Edition')"
  "$(icon_status 'Firefox Nightly                 Firefox Nightly Channel')"
  "$(icon_status 'Google Chrome                   Google Chrome Stable')"
  "$(icon_status 'Google Chrome Beta              Google Chrome Beta Channel')"
  "$(icon_status 'Google Chrome Unstable          Google Chrome Developer (Dev) Channel')"
  "$(icon_status 'Google Chrome Canary            Google Chrome Canary Channel')"
  "$(icon_status 'Gnome Extension pano@elhan.io   Next-gen Clipboard Manager')"
  "<< Back                   "
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 15 --header "Install optional applications")

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # Don't install anything
  echo ""
else
  INSTALLER=$(normalize "$CHOICE")
  INSTALLER_FILE="$OMAKUB_PATH/install/desktop/optional/app-$INSTALLER.sh"
  source $INSTALLER_FILE && gum spin --spinner globe --title "Install completed!" -- sleep 3
fi

clear
source $OMAKUB_PATH/bin/omakub-sub/header.sh
source $OMAKUB_PATH/bin/omakub-sub/install.sh

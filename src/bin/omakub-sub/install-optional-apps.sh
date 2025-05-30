sanitize_input() {
  echo "$1" | sed 's/^✖ *//;s/^✔ *//;s/^ *//;s/ /-/g' | tr '[:upper:]' '[:lower:]'
}

# Helper to get status and tick using the new helper
get_status_tick() {
  local item="$1"

  app_name=$(sanitize_input "$item")

  if command -v "$app_name" &> /dev/null; then
    echo "✔ $item"
  else
    echo "✖ $item"
  fi
}

CHOICES=(
  "$(get_status_tick 'Code Insiders')          Code editor for developers"
  "$(get_status_tick 'Linkquisition')          Browser-picker"
  "$(get_status_tick 'Brave Browser')          Brave Browser Stable"
  "$(get_status_tick 'Brave Browser Beta')     Brave Browser Beta"
  "$(get_status_tick 'Brave Browser Nightly')  Brave Browser Nightly"
  "$(get_status_tick 'Firefox')                Firefox Stable"
  "$(get_status_tick 'Firefox Beta')           Firefox Beta Channel"
  "$(get_status_tick 'Firefox Developer')      Firefox Developer Edition"
  "$(get_status_tick 'Firefox Nightly')        Firefox Nightly Channel"
  "$(get_status_tick 'Google Chrome')          Google Chrome Stable"
  "$(get_status_tick 'Google Chrome Beta')     Google Chrome Beta Channel"
  "$(get_status_tick 'Google Chrome Unstable') Google Chrome Developer (Dev) Channel"
  "$(get_status_tick 'Google Chrome Canary')   Google Chrome Canary Channel"
  "$(get_status_tick 'Pano')                   Next-gen Clipboard Manager"
  "<< Back           "
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 15 --header "Install optional applications")

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # Don't install anything
  echo ""
else
  # echo "Choice [$CHOICE]..." && sleep 2

  # INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/^✖ *//;s/^✔ *//;s/ /-/g')
  # INSTALLER=$(echo "$CHOICE" | sed 's/  \{2,\}[^ ]*$//' | tr '[:upper:]' '[:lower:]' | sed 's/^✖ *//;s/^✔ *//;s/ /-/g')
  INSTALLER=$(echo "$CHOICE" | sed 's/  \{2,\}.*$//' | tr '[:upper:]' '[:lower:]' | sed 's/^✖ *//;s/^✔ *//;s/ /-/g')
  INSTALLER_FILE="$OMAKUB_PATH/install/desktop/optional/app-$INSTALLER.sh"

  echo "Installing [$INSTALLER]..." && sleep 2

  source $INSTALLER_FILE && gum spin --spinner globe --title "Install completed!" -- sleep 3
fi

clear
source $OMAKUB_PATH/bin/omakub-sub/header.sh
source $OMAKUB_PATH/bin/omakub-sub/install.sh

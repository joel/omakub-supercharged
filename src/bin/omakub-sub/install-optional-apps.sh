CHOICES=(
  "Visual Studio Code Insiders      Code editor for developers"
  "Linkquisition                    Browser-picker"
  "Braves                           All versions of Brave"
  "Firefox                          Firefox Stable"
  "Firefox Beta                     Firefox Beta Channel"
  "Firefox Developer                Firefox Developer Edition"
  "Firefox Nightly                  Firefox Nightly Channel"
  "Pano                             Next-gen Clipboard Manager"
  "<< Back           "
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 10 --header "Install optional applications")

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # Don't install anything
  echo ""
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
  INSTALLER_FILE="$OMAKUB_PATH/install/desktop/optional/app-$INSTALLER.sh"

echo "Installing $INSTALLER..." && sleep 2
  source $INSTALLER_FILE && gum spin --spinner globe --title "Install completed!" -- sleep 3
fi

clear
source $OMAKUB_PATH/bin/omakub-sub/header.sh
source $OMAKUB_PATH/bin/omakub-sub/install.sh

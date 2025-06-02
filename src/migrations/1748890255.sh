# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
KEY_SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH"
CHROME_CMD="google-chrome --new-window"

# Check current value
current_cmd=$(gsettings get $KEY_SCHEMA command 2>/dev/null | tr -d "'")
if [ "$current_cmd" = "$CHROME_CMD" ]; then
  log_message "INFO" "Custom keybinding for Chrome already set: $CHROME_CMD" "$LOG_FILE"
else
  gsettings set $KEY_SCHEMA command "$CHROME_CMD"
  if [ $? -eq 0 ]; then
    log_message "SUCCESS" "Set custom keybinding for Chrome: $CHROME_CMD" "$LOG_FILE"
  else
    log_message "ERROR" "Failed to set custom keybinding for Chrome: $CHROME_CMD" "$LOG_FILE"
    exit 1
  fi
fi

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

# Idempotent setting for switch-to-workspace-right
RIGHT_KEY="['<Control><Alt>Right']"
CURRENT_RIGHT=$(gsettings get org.gnome.desktop.wm.keybindings switch-to-workspace-right 2>/dev/null)
if [ "$CURRENT_RIGHT" = "$RIGHT_KEY" ]; then
  log_message "INFO" "Right workspace hotkey already set: $RIGHT_KEY" "$LOG_FILE"
else
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "$RIGHT_KEY"
  if [ $? -eq 0 ]; then
    log_message "SUCCESS" "Set right workspace hotkey: $RIGHT_KEY" "$LOG_FILE"
  else
    log_message "ERROR" "Failed to set right workspace hotkey: $RIGHT_KEY" "$LOG_FILE"
    exit 1
  fi
fi

# Idempotent setting for switch-to-workspace-left
LEFT_KEY="['<Control><Alt>Left']"
CURRENT_LEFT=$(gsettings get org.gnome.desktop.wm.keybindings switch-to-workspace-left 2>/dev/null)
if [ "$CURRENT_LEFT" = "$LEFT_KEY" ]; then
  log_message "INFO" "Left workspace hotkey already set: $LEFT_KEY" "$LOG_FILE"
else
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "$LEFT_KEY"
  if [ $? -eq 0 ]; then
    log_message "SUCCESS" "Set left workspace hotkey: $LEFT_KEY" "$LOG_FILE"
  else
    log_message "ERROR" "Failed to set left workspace hotkey: $LEFT_KEY" "$LOG_FILE"
    exit 1
  fi
fi

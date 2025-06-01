# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

# Add VSCode settings and keybindings

vscode_variants=("Code" "Code - Insiders")

for variant in "${vscode_variants[@]}"; do
  user_dir="$HOME/.config/$variant/User"
  settings_file="$user_dir/settings.json"
  keybindings_file="$user_dir/keybindings.json"
  backup_dir="$user_dir/backup_$(date +%Y%m%d_%H%M%S)"

  if [ -d "$user_dir" ]; then
    mkdir -p "$backup_dir"
    if [ -f "$settings_file" ]; then
      cp "$settings_file" "$backup_dir/settings.json.bak"
      log_message "INFO" "Backed up existing settings.json for $variant to $backup_dir/settings.json.bak" "$LOG_FILE"
    fi
    if [ -f "$keybindings_file" ]; then
      cp "$keybindings_file" "$backup_dir/keybindings.json.bak"
      log_message "INFO" "Backed up existing keybindings.json for $variant to $backup_dir/keybindings.json.bak" "$LOG_FILE"
    fi

    cp ~/.local/share/omakub/configs/vscode.json "$settings_file"
    cp ~/.local/share/omakub/configs/vscode-joel-keybindings.json "$keybindings_file"
    
    log_message "SUCCESS" "Copied VSCode settings and keybindings for $variant" "$LOG_FILE"
  else
    log_message "WARNING" "Directory $user_dir does not exist, skipping." "$LOG_FILE"
  fi
done

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

log_message "INFO" "Overriding Alacritty configuration" "$LOG_FILE"

log_message "INFO" "Backing up existing shared.toml" "$LOG_FILE"
cp -fv "${HOME}/.config/alacritty/shared.toml" "${HOME}/.config/alacritty/shared.toml.bak"

log_message "INFO" "Copying new shared.toml" "$LOG_FILE"
cp -fv "${OMAKUB_PATH}/configs/alacritty/shared.toml" "${HOME}/.config/alacritty/shared.toml"

log_message "SUCCESS" "Alacritty configuration overridden successfully" "$LOG_FILE"

sleep 3

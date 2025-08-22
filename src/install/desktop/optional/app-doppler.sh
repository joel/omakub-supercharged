
#!/usr/bin/env bash

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

# Debian 11+ / Ubuntu 22.04+
log_message "INFO" "Updating package lists..." "$LOG_FILE"
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list

log_message "INFO" "Installing Doppler..." "$LOG_FILE"
sudo apt-get update && sudo apt-get install doppler

log_message "SUCCESS" "Doppler installation script finished." "$LOG_FILE"

sleep 3
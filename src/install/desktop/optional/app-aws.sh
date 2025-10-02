# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

set -euo pipefail

tmp_dir="$(create_temp_dir)"
cd "$tmp_dir" || {
  log_message "ERROR" "Failed to cd to temp dir $tmp_dir" "$LOG_FILE"
  exit 1
}

sudo snap install aws-cli --classic

aws --version

gum spin --spinner globe --title "aws-cli install completed" -- sleep 2

log_message "INFO" "aws-cli installation flow finished" "$LOG_FILE"

gum confirm "Go back to the menu?"
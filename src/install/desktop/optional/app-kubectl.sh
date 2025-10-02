# Source shared log initialization
source "${OMAKUB_PATH}/shared/log-init"

tmp_dir="$(create_temp_dir)"
cd "$tmp_dir" || exit 1

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

log_message "INFO" "Starting kubectl installation..." "$LOG_FILE"
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# Note:
# In releases older than Debian 12 and Ubuntu 22.04, folder /etc/apt/keyrings does not exist by default, and it should be created before the curl command.

if [[ ! -d /etc/apt/keyrings ]]; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
fi

sudo apt-get update
sudo apt-get install -y kubectl

kubectl version --client

gum spin --spinner globe --title "Install completed!" -- sleep 3

gum confirm "Go back to the menu?"
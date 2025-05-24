# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Omakub installation failed! You can retry by running: source ~/.local/share/omakub-supercharged/install.sh"' ERR

# Install dependencies
source ~/.local/share/omakub-supercharged/src/install/terminal/required/app-gum.sh >/dev/null

# Check if the user has already installed Omakub
echo "[DEBUG] gum binary: $(which gum)"
echo "[DEBUG] gum version: $(gum --version)"

if [ -d ~/.local/share/omakub ]; then
  echo "Omakub is installed ✅"
  echo "Do you want to patch the official Omakub?"
  if gum confirm
  then
    # Patching the official Omakub
    source ~/.local/share/omakub-supercharged/patching.sh
  else
    echo "Skipping patching of the official Omakub."
    echo "Bye 👋"
    exit 0
  fi
else 
  echo "Omakub is not installed. Proceeding with installation first."
fi

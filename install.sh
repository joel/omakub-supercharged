# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Omakub installation failed! You can retry by running: source ~/.local/share/omakub-patch/install.sh"' ERR

# Install dependencies
source ~/.local/share/omakub-patch/install/terminal/required/app-gum.sh >/dev/null

# Check if the user has already installed Omakub
if [ -d ~/.local/share/omakub ]; then
  echo "Omakub is installed ✅"
  if gum confirm --default y --prompt "Do you want to patch the official Omakub?" ; then
    # Patching the official Omakub
    source ~/.local/share/omakub-patch/patching.sh
  else
    echo "Skipping patching of the official Omakub."
    echo "Bye 👋"
    exit 0
  fi
else 
  echo "Omakub is not installed. Proceeding with installation first."
fi

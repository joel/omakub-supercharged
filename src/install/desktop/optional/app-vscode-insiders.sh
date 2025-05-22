cd /tmp
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code-insiders stable main" | sudo tee /etc/apt/sources.list.d/vscode-insiders.list >/dev/null
rm -f packages.microsoft.gpg
cd -

sudo apt update -y
sudo apt install -y code-insiders

mkdir -p "${HOME}/.config/Code - Insiders/User"
cp ~/.local/share/omakub/configs/vscode.json "${HOME}/.config/Code - Insiders/User/settings.json"

# Install default supported themes
code-insiders --install-extension enkia.tokyo-night

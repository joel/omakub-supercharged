# Add VSCode settings and keybindings

vscode_variants=("Code" "Code - Insiders")

for variant in "${vscode_variants[@]}"; do
  if [ -d "$HOME/.config/$variant/User" ]; then
    echo "Copying VSCode settings and keybindings for $variant"
    cp ~/.local/share/omakub/configs/vscode.json "$HOME/.config/$variant/User/settings.json"
    cp ~/.local/share/omakub/configs/vscode-joel-keybindings.json "$HOME/.config/$variant/User/keybindings.json"
  else
    echo "Directory $HOME/.config/$variant/User does not exist, skipping."
  fi
done

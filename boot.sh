set -e

ascii_art='
 ▗▄▖ ▗▖  ▗▖ ▗▄▖ ▗▖ ▗▖▗▖ ▗▖▗▄▄▖     ▗▄▄▖  ▗▄▖▗▄▄▄▖▗▄▄▖▗▖ ▗▖
▐▌ ▐▌▐▛▚▞▜▌▐▌ ▐▌▐▌▗▞▘▐▌ ▐▌▐▌ ▐▌    ▐▌ ▐▌▐▌ ▐▌ █ ▐▌   ▐▌ ▐▌
▐▌ ▐▌▐▌  ▐▌▐▛▀▜▌▐▛▚▖ ▐▌ ▐▌▐▛▀▚▖    ▐▛▀▘ ▐▛▀▜▌ █ ▐▌   ▐▛▀▜▌
▝▚▄▞▘▐▌  ▐▌▐▌ ▐▌▐▌ ▐▌▝▚▄▞▘▐▙▄▞▘    ▐▌   ▐▌ ▐▌ █ ▝▚▄▄▖▐▌ ▐▌
'

echo -e "$ascii_art"
echo "=> Omakub patching script for Omakub"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Omakub..."
rm -rf ~/.local/share/omakub-patch >/dev/null
git clone https://github.com/joel/omakub-patch.git ~/.local/share/omakub-patch >/dev/null
if [[ $OMAKUB_REF != "master" ]]; then
	cd ~/.local/share/omakub-patch
	git fetch origin "${OMAKUB_REF:-stable}" && git checkout "${OMAKUB_REF:-stable}"
	cd -
fi

echo "Installation starting..."
source ~/.local/share/omakub-patch/install.sh

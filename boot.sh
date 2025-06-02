set -e

# https://patorjk.com/software/taag/#p=display&f=DiamFont&t=OMAKUB%20SUPERCHARGED!
ascii_art='
 ▗▄▖ ▗▖  ▗▖ ▗▄▖ ▗▖ ▗▖▗▖ ▗▖▗▄▄▖      ▗▄▄▖▗▖ ▗▖▗▄▄▖ ▗▄▄▄▖▗▄▄▖  ▗▄▄▖▗▖ ▗▖ ▗▄▖ ▗▄▄▖  ▗▄▄▖▗▄▄▄▖▗▄▄▄  
▐▌ ▐▌▐▛▚▞▜▌▐▌ ▐▌▐▌▗▞▘▐▌ ▐▌▐▌ ▐▌    ▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌  █ 
▐▌ ▐▌▐▌  ▐▌▐▛▀▜▌▐▛▚▖ ▐▌ ▐▌▐▛▀▚▖     ▝▀▚▖▐▌ ▐▌▐▛▀▘ ▐▛▀▀▘▐▛▀▚▖▐▌   ▐▛▀▜▌▐▛▀▜▌▐▛▀▚▖▐▌▝▜▌▐▛▀▀▘▐▌  █ 
▝▚▄▞▘▐▌  ▐▌▐▌ ▐▌▐▌ ▐▌▝▚▄▞▘▐▙▄▞▘    ▗▄▄▞▘▝▚▄▞▘▐▌   ▐▙▄▄▖▐▌ ▐▌▝▚▄▄▖▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▝▚▄▞▘▐▙▄▄▖▐▙▄▄▀ 

'

echo -e "$ascii_art"
echo "=> Omakub patching script for Omakub"
echo -e "\nBegin installation (or abort with ctrl+c)..."

if ! command -v git >/dev/null 2>&1; then
	sudo apt-get update >/dev/null
	sudo apt-get install -y git >/dev/null
fi

echo "Cloning or updating Omakub..."
if [ -d ~/.local/share/omakub-supercharged/.git ]; then
	cd ~/.local/share/omakub-supercharged
	git fetch origin "${OMAKUB_REF:-main}"
	git checkout "${OMAKUB_REF:-main}"
	git pull origin "${OMAKUB_REF:-main}"
	cd -
else
	git clone https://github.com/joel/omakub-supercharged.git ~/.local/share/omakub-supercharged >/dev/null
	if [[ $OMAKUB_REF != "master" ]]; then
		cd ~/.local/share/omakub-supercharged
		git fetch origin "${OMAKUB_REF:-main}" && git checkout "${OMAKUB_REF:-main}"
		cd -
	fi
fi

echo "Installation starting..."
source ~/.local/share/omakub-supercharged/install.sh

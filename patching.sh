export OMAKUB_DIRECTORY="${OMAKUB_DIRECTORY:-$HOME/.local/share/omakub}"

echo "OMAKUB_DIRECTORY: $OMAKUB_DIRECTORY"

echo "Add Helper functions to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/shared $OMAKUB_DIRECTORY/shared

echo "Add Utilities to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/utils $OMAKUB_DIRECTORY/utils

echo "Add Optional Applications to Omakub"
cp -f ~/.local/share/omakub-supercharged/src/install/desktop/optional/* $OMAKUB_DIRECTORY/install/desktop/optional/
cp ~/.local/share/omakub-supercharged/src/bin/omakub-sub/install-optional-apps.sh $OMAKUB_DIRECTORY/bin/omakub-sub/install-optional-apps.sh

echo "Overwrite Migrate script"
cp -f ~/.local/share/omakub-supercharged/src/bin/omakub-sub/migrate.sh $OMAKUB_DIRECTORY/bin/omakub-sub/migrate.sh

echo "Add optional app entry to Install menu"
ruby ~/.local/share/omakub-supercharged/bin/install-update.rb setup_action
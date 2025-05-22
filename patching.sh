OMAKUB_DIRECTORY="${OMAKUB_DIRECTORY:-$HOME/.local/share/omakub}"

echo "Add Helper functions to Omakub"
cp -r ~/.local/share/omakub-patch/src/shared $OMAKUB_DIRECTORY/shared

echo "Add Optional Applications to Omakub"
cp -r ~/.local/share/omakub-patch/src/install/desktop/optional $OMAKUB_DIRECTORY/install/desktop/optional
cp ~/.local/share/omakub-patch/src/bin/omakub-sub/install-optional-apps.sh $OMAKUB_DIRECTORY/bin/omakub-sub/install-optional-apps.sh

echo "Overwrite Migrate script"
cp ~/.local/share/omakub-patch/src/bin/omakub-sub/migrate.sh $OMAKUB_DIRECTORY/bin/omakub-sub/migrate.sh

echo "Add optional app entry to Install menu"
ruby ~/.local/share/omakub-patch/bin/install-update.rb setup_action
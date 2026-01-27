export OMAKUB_DIRECTORY="${OMAKUB_DIRECTORY:-$HOME/.local/share/omakub}"

echo "OMAKUB_DIRECTORY: $OMAKUB_DIRECTORY"

echo "Add Helper functions to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/shared $OMAKUB_DIRECTORY/

echo "Add Utilities to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/utils $OMAKUB_DIRECTORY/

echo "Add Config scripts to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/configs/* $OMAKUB_DIRECTORY/configs

echo "Add Defaults scripts to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/defaults/* $OMAKUB_DIRECTORY/defaults

echo "Update Omakub themes"
for theme in ~/.local/share/omakub-supercharged/src/themes/*; do
  [ -d "$theme" ] || continue
  theme_name=$(basename "$theme")
  cp -fvr "$theme"/* "$OMAKUB_DIRECTORY/themes/$theme_name/"
done

echo "Add Optional Applications to Omakub"
cp -fr ~/.local/share/omakub-supercharged/src/install/desktop/optional/* $OMAKUB_DIRECTORY/install/desktop/optional/
cp -fr ~/.local/share/omakub-supercharged/src/install/desktop/* $OMAKUB_DIRECTORY/install/desktop/
cp ~/.local/share/omakub-supercharged/src/bin/omakub-sub/install-optional-apps.sh $OMAKUB_DIRECTORY/bin/omakub-sub/install-optional-apps.sh

echo "Overwrite Migrate script"
cp -f ~/.local/share/omakub-supercharged/src/bin/omakub-sub/migrate.sh $OMAKUB_DIRECTORY/bin/omakub-sub/migrate.sh

echo "Copy the migrations"
cp -fr ~/.local/share/omakub-supercharged/src/migrations/* $OMAKUB_DIRECTORY/migrations

echo "Add optional app entry to Install menu"
ruby ~/.local/share/omakub-supercharged/bin/install-update.rb setup_action

echo "Set XDG_CONFIG_HOME in shell defaults"
echo "export XDG_CONFIG_HOME=\"$HOME/.config\"" >> $OMAKUB_DIRECTORY/defaults/bash/shell

echo "Patching complete!"
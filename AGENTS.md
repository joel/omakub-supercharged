# AGENTS.md

## Adding a new optional desktop app
- Create `src/install/desktop/optional/app-<name>.sh` with a shebang and `source "${OMAKUB_PATH}/shared/log-init"`.
- Reuse helpers from `src/shared/helpers.sh` (`log_message`, `create_temp_dir`, `download_file`, `install_deb_package`) instead of duplicating logic.
- Log start/end, handle failures, clean up temp files, and add a short `sleep 3` at the end for output review.
- Ensure the script is executable (`chmod +x src/install/desktop/optional/app-<name>.sh`).
- Add a menu entry in `src/bin/omakub-sub/install-optional-apps.sh` and adjust `gum choose --height` if the list grows.
- The menu label is normalized (lowercase, spaces → `-`) to resolve `app-<name>.sh`; keep the label aligned with the script name.

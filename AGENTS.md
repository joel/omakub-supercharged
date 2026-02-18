# AGENTS.md

## Adding a new optional desktop app
- Create `src/install/desktop/optional/app-<name>.sh` with a shebang and `source "${OMAKUB_PATH}/shared/log-init"`.
- Reuse helpers from `src/shared/helpers.sh` (`log_message`, `create_temp_dir`, `download_file`, `install_deb_package`) instead of duplicating logic.
- Log start/end, handle failures, clean up temp files, and add a short `sleep 3` at the end for output review.
- For apt-repository based installers, install prerequisites (`ca-certificates`, `curl`, `gnupg`) before repository setup.
- Ensure `/etc/apt/keyrings` exists, then import repository keys with `gpg --dearmor`.
- Add repository entries in `/etc/apt/sources.list.d/` idempotently (avoid duplicate lines on re-runs).
- Run `apt-get update` after adding/updating apt repository entries and before package installation.
- Verify package installation status when possible (for example with `package_installed`) and log the outcome.
- If the installer changes group membership or needs a session restart, log a clear warning with the required action (e.g., reboot).
- Ensure the script is executable (`chmod +x src/install/desktop/optional/app-<name>.sh`).
- Add a menu entry in `src/bin/omakub-sub/install-optional-apps.sh` and adjust `gum choose --height` if the list grows.
- The menu label is normalized (lowercase, spaces → `-`) to resolve `app-<name>.sh`; keep the label aligned with the script name.

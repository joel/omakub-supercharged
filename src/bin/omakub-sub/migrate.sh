
# Source shared log initialization for migration tracking
source "${OMAKUB_PATH}/shared/log-init"

cd $OMAKUB_PATH

# Path to the local migrations tracking file
MIGRATIONS_FILE=~/.config/omakub/migrations.txt

# Path to the migration status log (CSV for detailed tracking)
MIGRATION_STATUS_FILE=~/.config/omakub/migrations_status.log

# Ensure the status file exists
touch "$MIGRATION_STATUS_FILE"

# Check if the migrations file exists
if [ ! -f "$MIGRATIONS_FILE" ]; then
  if gum confirm "It appears you don't have a migrations file. Do you want to create it?"; then
    echo "Running utils/dump-migrations.sh..."
    # Assuming utils/dump-migrations.sh is in the same directory or in PATH
    # Adjust the path if necessary, e.g., "$OMAKUB_PATH/utils/dump-migrations.sh"
    if [ -f "$OMAKUB_PATH/utils/dump-migrations.sh" ]; then
      sh "$OMAKUB_PATH/utils/dump-migrations.sh"
    else
      echo "Error: utils/dump-migrations.sh not found."
      return 1
    fi
  fi
fi

# Create the migrations tracking file if it doesn't exist
touch "$MIGRATIONS_FILE"

# Load the list of already executed migrations
EXECUTED_MIGRATIONS=()
while IFS= read -r line; do
  EXECUTED_MIGRATIONS+=("$line")
done < "$MIGRATIONS_FILE"

# Update the local repository with the latest changes from the remote repository
git pull > /dev/null

# Initialize an array to track failed migrations
FAILED_MIGRATIONS=()

# Iterate through all shell script files in the migrations directory
for file in $OMAKUB_PATH/migrations/*.sh; do
  # Extract just the filename without the directory path
  filename=$(basename "$file")
  
  # Remove the .sh extension to get the migration timestamp
  # Migration files are named with Unix timestamps (e.g., 1747474348.sh)
  migrate_at="${filename%.sh}"

  # Check if this migration has already been executed by looking for its timestamp
  # in the EXECUTED_MIGRATIONS array
  already_executed=false
  for executed in "${EXECUTED_MIGRATIONS[@]}"; do
    if [[ "$executed" == "$migrate_at" ]]; then
      already_executed=true
      break
    fi
  done

  # Check if we should run this migration
  should_run=false
  migration_reason=""

  # Only use the recorded migrations file to determine if migration should run
  if $already_executed; then
    should_run=false
    migration_reason="already executed (recorded in migrations file)"
  else
    should_run=true
    migration_reason="not found in migrations record"
  fi

  # Skip this migration if we shouldn't run it
  if ! $should_run; then
    # echo "Migration $migrate_at skipped: $migration_reason"
    continue
  fi

  # Display which migration is being executed
  log_message "INFO" "Running migration $migrate_at ($filename)" "$LOG_FILE"

  # Track execution status
  migration_status="failed"
  migration_time="$(date '+%Y-%m-%d %H:%M:%S')"

  if source "$file"; then
    # Record this migration as executed by adding its timestamp to the migrations file
    echo "$migrate_at" >> "$MIGRATIONS_FILE"
    migration_status="success"
    log_message "SUCCESS" "Migration $migrate_at executed successfully and recorded." "$LOG_FILE"
  else
    log_message "WARNING" "Migration $migrate_at failed. Will retry after all migrations." "$LOG_FILE"
  fi

  # Record status (CSV: migration_id,date_time,status)
  echo "$migrate_at,$migration_time,$migration_status" >> "$MIGRATION_STATUS_FILE"

  # Track failed migrations for retry
  if [ "$migration_status" = "failed" ]; then
    FAILED_MIGRATIONS+=("$file")
  fi
done

# Retry failed migrations
if [ "${#FAILED_MIGRATIONS[@]}" -gt 0 ]; then
  log_message "WARNING" "Retrying failed migrations: ${#FAILED_MIGRATIONS[@]} found." "$LOG_FILE"
  for file in "${FAILED_MIGRATIONS[@]}"; do
    filename=$(basename "$file")
    migrate_at="${filename%.sh}"
    migration_time="$(date '+%Y-%m-%d %H:%M:%S')"
    log_message "WARNING" "Retrying migration $migrate_at ($filename)" "$LOG_FILE"
    if source "$file"; then
      echo "$migrate_at" >> "$MIGRATIONS_FILE"
      log_message "SUCCESS" "Migration $migrate_at succeeded on retry and recorded." "$LOG_FILE"
      echo "$migrate_at,$migration_time,success" >> "$MIGRATION_STATUS_FILE"
    else
      log_message "ERROR" "Migration $migrate_at failed again. Manual intervention may be required." "$LOG_FILE"
      echo "$migrate_at,$migration_time,failed" >> "$MIGRATION_STATUS_FILE"
    fi
  done
fi
done

# Clear the shell messages (clear the terminal)
clear

cd -
# End of script
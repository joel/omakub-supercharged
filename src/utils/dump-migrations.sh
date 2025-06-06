#!/usr/bin/env bash
# filepath: /home/joel/.local/share/omakub/bin/omakub-sub/dump-migrations.sh
# This script initializes ~/.config/omakub/migrations.txt with the migration timestamps
# from all migration scripts in $OMAKUB_PATH/migrations/*.sh, sorted in ascending order.

# set -e

# Ensure ~/.config/omakub exists
mkdir -p ~/.config/omakub

# Path to the migrations tracking file
MIGRATIONS_FILE=~/.config/omakub/migrations.txt
# Path to the migration status log (CSV for detailed tracking)
MIGRATION_STATUS_FILE=~/.config/omakub/migrations_status.log

# Clear the migrations file if it exists
> "$MIGRATIONS_FILE"
# Clear the migration status file if it exists
> "$MIGRATION_STATUS_FILE"

# Find all migration scripts, extract their timestamps, sort, and write to the files
for file in $OMAKUB_PATH/migrations/*.sh; do
  filename=$(basename "$file")

  migrate_at="${filename%.sh}"

  # Only add if it's a valid number (timestamp)
  if [[ "$migrate_at" =~ ^[0-9]+$ ]]; then
    echo "$migrate_at"
  fi
done | sort -n > "$MIGRATIONS_FILE"

cat "$MIGRATIONS_FILE"

# Also initialize the status log with all migrations as 'pending'
while IFS= read -r migration_id; do
  migration_time="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "$migration_id,$migration_time,done" >> "$MIGRATION_STATUS_FILE"
done < "$MIGRATIONS_FILE"

echo "Migrations dumped to $MIGRATIONS_FILE and status initialized in $MIGRATION_STATUS_FILE"

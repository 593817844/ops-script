#!/bin/bash

# Set variables
BACKUP_DIR="/data/gitlab/data/backups" # Change this to your backup directory
LOG_DIR="/opt/backup_log"       # Change this to your log directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/gitlab_backup_$TIMESTAMP.log"
# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log start time
echo "Starting GitLab backup at $(date)-----------------------" >> "$LOG_FILE"

# Run GitLab backup command and append output to log file
docker exec gitlab gitlab-rake gitlab:backup:create SKIP=registry >> "$LOG_FILE" 2>&1

# Check if the backup command was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)" >> "$LOG_FILE"
else
    echo "Backup failed at $(date)" >> "$LOG_FILE"
    exit 1
fi

# Optional: Clean up old log files (e.g., older than 30 days)
find "$LOG_DIR" -name "gitlab_backup_*.log" -mtime +7 -delete
find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -mtime +7 -delete

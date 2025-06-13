#!/bin/bash

# This script clears session files older than TIME_LIMIT_MINUTES
# and logs disk usage before and after cleanup.

# Time limits
TIME_LIMIT_MINUTES=30

# Directories and log file
LOG_DIR="/var"
SESSION_DIR="/var/sentora/sessions"
LOG_FILE="/var/session_clear_log.txt"

# Get current date for logs
current_date=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log current disk space and inodes
get_current_disk_space() {
    log_type=$1
    date=$2

    echo "====== $log_type Inodes and Storage on $date ======= " >> "$LOG_FILE"
    df -i "$LOG_DIR" >> "$LOG_FILE"
    echo "----------------------------------------------------" >> "$LOG_FILE"
    df -h "$LOG_DIR" >> "$LOG_FILE"
    echo "----------------------------------------------------" >> "$LOG_FILE"
}

# Function to delete session files safely
delete_session_files() {
    # Find session files older than TIME_LIMIT_MINUTES
    session_files=$(sudo find "$SESSION_DIR" -type f -name "sess_*" -mmin +$TIME_LIMIT_MINUTES)
    file_count=$(echo "$session_files" | grep -c '^')

    echo "$current_date - Found $file_count session files older than $TIME_LIMIT_MINUTES minutes" >> "$LOG_FILE"
    echo "Clearing Files started:" >> "$LOG_FILE"

    if [ "$file_count" -gt 0 ]; then
        # Delete using find -exec safely
        sudo find "$SESSION_DIR" -type f -name "sess_*" -mmin +$TIME_LIMIT_MINUTES -exec rm -f {} +

        echo "$current_date - Successfully cleared $file_count session files" >> "$LOG_FILE"
    else
        echo "$current_date - No session files older than $TIME_LIMIT_MINUTES minutes found" >> "$LOG_FILE"
    fi

    echo "-----------------------------------" >> "$LOG_FILE"
}

# Run cleanup process
get_current_disk_space "Before Cleanup" "$current_date"
delete_session_files
update_date=$(date '+%Y-%m-%d %H:%M:%S')
get_current_disk_space "After Cleanup" "$update_date"

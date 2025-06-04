#!/bin/bash

# This script clears log files older than 1 minutes and session files older than 1 minutes

current_date=$(date '+%Y-%m-%d %H:%M:%S')
# Define the log directory and log file
TIME_LIMIT_MINUTES=60
LOG_DIR="/var"  
LOG_FILE="/var/auto_clean_log_hrs.txt"
# Define the session directory
SESSION_DIR="/var/sentora/sessions"

# Get the current disk space and file count
get_current_disk_space() {
    log_type=$1 # Before Cleanup or After Cleanup
    date=$2
    # Inodes used
    echo "====== $log_type Inodes and Storage on $date ======= " >> "$LOG_FILE"
    df -i "$LOG_DIR" >> "$LOG_FILE"
    echo "----------------------------------------------------" >> "$LOG_FILE"
    df -h "$LOG_DIR" >> "$LOG_FILE"
    echo "----------------------------------------------------" >> "$LOG_FILE"
}

# Before cleanup disk space
get_current_disk_space "Before Cleanup" "$current_date"


# Clear Log Files older than 1
clear_old_logs() {

    # Find log files older than $TIME_LIMIT_MINUTES minutes
    log_files=$(sudo find "$LOG_DIR" -type f -name "*.log")
    gz_files=$(sudo find "$LOG_DIR" -type f -name "*.log.*.gz")

    # Count the files
    file_count=$(echo "$log_files" | grep -v '^$' | wc -l)
    gz_file_count=$(echo "$gz_files" | grep -v '^$' | wc -l)

    # Log the count and files
    echo "$current_date - Found $file_count log files older than $TIME_LIMIT_MINUTES minutes" >> "$LOG_FILE"
    echo "Files to be cleared:" >> "$LOG_FILE"
    echo "$log_files" >> "$LOG_FILE"
    echo "Files to be deleted:" >> "$LOG_FILE"
    echo "$gz_files" >> "$LOG_FILE"

    # Clear files if any exist
    if [ "$file_count" -gt 0 ]; then
        # Clear .log files
        echo "$log_files" | xargs -I {} sudo sh -c ': > "{}"'
        echo "$current_date - Successfully cleared $file_count log files" >> "$LOG_FILE"
    else
        echo "$current_date - No log files older than $TIME_LIMIT_MINUTES minutes found" >> "$LOG_FILE"
    fi

    if [ "$gz_file_count" -gt 0 ]; then
        # Delete .gz files
        echo "$gz_files" | xargs sudo rm -f

        echo "$current_date - Successfully deleted $gz_file_count log files" >> "$LOG_FILE"
    else
        echo "$current_date - No compressed log files older than $TIME_LIMIT_MINUTES minutes found" >> "$LOG_FILE"
    fi

    echo "-----------------------------------" >> "$LOG_FILE"
}

# Delete Sessions files older than $TIME_LIMIT_MINUTES minutes

delete_session_files(){
    # Find session files older than $TIME_LIMIT_MINUTES minutes
    session_files=$(sudo find "$SESSION_DIR" -type f -name "sess_*" -mmin +$TIME_LIMIT_MINUTES)

    # Count the files
    file_count=$(echo "$session_files" | wc -l)

    # Log the count and files
    echo "$current_date - Found $file_count session files older than $TIME_LIMIT_MINUTES minutes" >> "$LOG_FILE"
    echo "Clearing Files started:" >> "$LOG_FILE"

    # Clear files if any exist
    if [ "$file_count" -gt 0 ]; then
        # Clear session files
        echo "$session_files" | xargs sudo rm -f

        echo "$current_date - Successfully cleared $file_count session files" >> "$LOG_FILE"
    else
        echo "$current_date - No session files older than $TIME_LIMIT_MINUTES minutes found" >> "$LOG_FILE"
    fi

    echo "-----------------------------------" >> "$LOG_FILE"
}

# Clear Log Files
clear_old_logs

# Delete Session Files
delete_session_files

update_date=$(date '+%Y-%m-%d %H:%M:%S')
# After cleanup disk space
get_current_disk_space "After Cleanup" "$update_date"
# Auto Clean Log and Session Files Script
This Bash script automates the cleanup of log and session files in Sentora Panel that are older than a specified number of days. It logs disk usage before and after the cleanup, clears out old log files (both plain and compressed), and deletes outdated session files. The script can be run manually or scheduled via crontab.

There are 2 approaches for running this script:
- Manual Execution
- Automated via Crontab

## Manual Execution
You can run the script manually to perform a cleanup operation and review the log file for details.

### How to Use
Ensure the script has execute permissions:
`chmod +x cleanup.sh`

Run the script:
`./cleanup.sh`

## Automated via Crontab
To schedule the script to run every day at 12:01 AM, add the following entry to your crontab:

`1 0 * * * /path/to/cleanup.sh`

Replace /path/to/cleanup.sh with the absolute path to your script. To edit your crontab, run:

`crontab -e`

## Configuration
- `TIME_LIMIT`: Number of days after which files are considered old (default: 2 days).
- `LOG_DIR`: Directory where log files are located (default: /var).
- `LOG_FILE`: File where cleanup logs are stored (default: /var/auto_clean_log.txt).
- `SESSION_DIR`: Directory containing session files (default: /var/sentora/sessions).

If a .env file is present in the same directory as the script, it will be sourced to allow overriding these default values.

## Script Details
The script performs the following tasks:

- Logs current disk space and inode usage before cleanup.
- Searches for log files (with a .log extension) and compressed log files (matching .log.*.gz) older than the specified time limit.
- Truncates old .log files and deletes the compressed log files.
- Finds and deletes session files (named with the prefix sess_) older than the time limit.
- Logs disk space and inode usage after cleanup.

## Prerequisites
A Unix-like operating system with Bash.
Sudo privileges for executing file operations.
#!/bin/bash

# This script configures the monitoring script to start on system reboot using cron.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
START_SCRIPT_PATH="$SCRIPT_DIR/start.sh"

# Check if start.sh exists and is executable
if [ ! -x "$START_SCRIPT_PATH" ]; then
    echo "ERROR: start.sh not found or not executable at $START_SCRIPT_PATH" >&2
    echo "Please run setup.sh first or make it executable (chmod +x)." >&2
    exit 1
fi

CRON_JOB="@reboot $START_SCRIPT_PATH"

# Check if the cron job already exists
if crontab -l 2>/dev/null | grep -q -F "$CRON_JOB"; then
    echo "Cron job already exists. No changes made."
    echo "To edit, run 'crontab -e'"
else
    # Add the new cron job
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    if [ $? -eq 0 ]; then
        echo "✅ Successfully added cron job to run on system reboot."
        echo "The monitor will now start automatically."
    else
        echo "❌ ERROR: Failed to add cron job." >&2
        echo "Please check your permissions or try running 'crontab -e' manually." >&2
    fi
fi

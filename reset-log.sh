#!/bin/bash

# This script resets the log file specified in the config.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Please install it to parse the config file." >&2
    exit 1
fi

LOG_FILE_CONFIG=$(jq -r '.log_file' "$CONFIG_FILE")

# Resolve LOG_FILE to an absolute path
if [[ "$LOG_FILE_CONFIG" != /* ]]; then
    LOG_FILE="$SCRIPT_DIR/$LOG_FILE_CONFIG"
else
    LOG_FILE="$LOG_FILE_CONFIG"
fi

# Truncate the log file
> "$LOG_FILE"

echo "Log file has been reset: $LOG_FILE"

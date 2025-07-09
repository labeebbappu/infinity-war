#!/bin/bash

# This script checks for dependencies and sets up the initial environment.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.json"

echo "Running Infinity War Setup..."

# 1. Check for dependencies
command -v jq >/dev/null 2>&1 || { echo >&2 "Dependency 'jq' is not installed. Please install it. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "Dependency 'curl' is not installed. Please install it. Aborting."; exit 1; }
echo "✅ Dependencies (jq, curl) are installed."

# 2. Check for config file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ ERROR: Configuration file not found at $CONFIG_FILE" >&2
    exit 1
fi
echo "✅ Config file found."

# 3. Read file paths from config
LOG_FILE_CONFIG=$(jq -r '.log_file' "$CONFIG_FILE")
STATE_FILE_CONFIG=$(jq -r '.state_file' "$CONFIG_FILE")

# Resolve to absolute paths
if [[ "$LOG_FILE_CONFIG" != /* ]]; then LOG_FILE="$SCRIPT_DIR/$LOG_FILE_CONFIG"; else LOG_FILE="$LOG_FILE_CONFIG"; fi
if [[ "$STATE_FILE_CONFIG" != /* ]]; then STATE_FILE="$SCRIPT_DIR/$STATE_FILE_CONFIG"; else STATE_FILE="$STATE_FILE_CONFIG"; fi

# 4. Create log and state files if they don't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    echo "✅ Log file created at: $LOG_FILE"
else
    echo "✅ Log file already exists."
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "{}" > "$STATE_FILE"
    echo "✅ State file created at: $STATE_FILE"
else
    echo "✅ State file already exists."
fi

# 5. Final instructions
echo -e "\n🎉 Setup complete!"
echo "IMPORTANT: Please make sure you have correctly filled in your details in '$CONFIG_FILE', especially the 'smtp_settings'."

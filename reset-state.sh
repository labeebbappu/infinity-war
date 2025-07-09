#!/bin/bash

# This script resets the state file specified in the config.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Please install it to parse the config file." >&2
    exit 1
fi

STATE_FILE_CONFIG=$(jq -r '.state_file' "$CONFIG_FILE")

# Resolve STATE_FILE to an absolute path
if [[ "$STATE_FILE_CONFIG" != /* ]]; then
    STATE_FILE="$SCRIPT_DIR/$STATE_FILE_CONFIG"
else
    STATE_FILE="$STATE_FILE_CONFIG"
fi

# Reset the state file to an empty JSON object
echo "{}" > "$STATE_FILE"

echo "State file has been reset: $STATE_FILE"

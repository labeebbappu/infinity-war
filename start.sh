#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Please install it to parse the config file." >&2
    exit 1
fi

LOG_FILE_CONFIG=$(jq -r '.log_file' "$CONFIG_FILE")

# Resolve LOG_FILE to an absolute path, similar to infinity-war.sh
if [[ "$LOG_FILE_CONFIG" != /* ]]; then
    LOG_FILE="$SCRIPT_DIR/$LOG_FILE_CONFIG"
else
    LOG_FILE="$LOG_FILE_CONFIG"
fi

nohup "$SCRIPT_DIR/infinity-war.sh" > "$LOG_FILE" 2>&1 &

PID=$!

echo "Infinity War script started with PID: $PID"

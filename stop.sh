#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PID=$(pgrep -f "$SCRIPT_DIR/infinity-war.sh")

if [ -z "$PID" ]; then
    echo "Infinity War script is not running."
else
    echo "Stopping Infinity War script (PID: $PID)..."
    kill "$PID"
    echo "Infinity War script stopped."
fi

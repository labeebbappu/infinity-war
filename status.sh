#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PID=$(pgrep -f "$SCRIPT_DIR/infinity-war.sh")

if [ -z "$PID" ]; then
    echo "Infinity War is not running."
else
    echo "Infinity War is running (PID: $PID)."
fi

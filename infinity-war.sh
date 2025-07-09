#!/bin/bash

# Infinity War: System Health Monitoring and Recovery Script

# --- Configuration ---
# The script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# --- Functions ---

# Logs a message to the log file
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Loads configuration from the JSON file
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: Configuration file not found: $CONFIG_FILE"
        exit 1
    fi

    # Check for jq
    if ! command -v jq &> /dev/null; then
        echo "ERROR: jq is not installed. Please install it to parse the config file."
        exit 1
    fi

    LOG_FILE_CONFIG=$(jq -r '.log_file' "$CONFIG_FILE")
    STATE_FILE_CONFIG=$(jq -r '.state_file' "$CONFIG_FILE")

    # Use SCRIPT_DIR if log_file or state_file are not absolute paths
    if [[ "$LOG_FILE_CONFIG" != /* ]]; then
        LOG_FILE="$SCRIPT_DIR/$LOG_FILE_CONFIG"
    else
        LOG_FILE="$LOG_FILE_CONFIG"
    fi

    if [[ "$STATE_FILE_CONFIG" != /* ]]; then
        STATE_FILE="$SCRIPT_DIR/$STATE_FILE_CONFIG"
    else
        STATE_FILE="$STATE_FILE_CONFIG"
    fi
    CHECK_INTERVAL=$(jq -r '.check_interval_seconds' "$CONFIG_FILE")
    FAILURE_THRESHOLD=$(jq -r '.failure_threshold' "$CONFIG_FILE")
    REBOOT_ON_TOTAL_FAILURE=$(jq -r '.reboot_on_total_failure' "$CONFIG_FILE")

    SMTP_HOST=$(jq -r '.smtp_settings.host' "$CONFIG_FILE")
    SMTP_PORT=$(jq -r '.smtp_settings.port' "$CONFIG_FILE")
    SMTP_USER=$(jq -r '.smtp_settings.user' "$CONFIG_FILE")
    SMTP_PASSWORD=$(jq -r '.smtp_settings.password' "$CONFIG_FILE")
}

# Checks the status of a single API
check_api() {
    local api_name="$1"
    local api_url="$2"
    
    http_status=$(curl -o /dev/null -s -w "%{\http_code}" --connect-timeout 10 "$api_url")
    
    if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 300 ]; then
        log_message "SUCCESS: $api_name is UP (Status: $http_status)."
        update_state "$api_name" "UP"
        return 0
    else
        log_message "FAILURE: $api_name is DOWN (Status: $http_status)."
        update_state "$api_name" "DOWN"
        return 1
    fi
}

# Sends an email alert
send_email_alert() {
    local api_name="$1"
    local subject="Infinity War Alert: $api_name is DOWN!"
    local body="API: $api_name has been down for $FAILURE_THRESHOLD consecutive checks.\n\nPlease investigate immediately."

    log_message "ALERT: $api_name has been down for $FAILURE_THRESHOLD consecutive checks. Attempting to send email."

    # Using sendmail command for sending email. Requires sendmail to be configured on the system.
    # This is a basic example and might need adjustments based on your sendmail configuration.
    (echo "From: $SMTP_USER"
     echo "To: $SMTP_USER"
     echo "Subject: $subject"
     echo ""
     echo "$body") | sendmail -t

    if [ $? -eq 0 ]; then
        log_message "Email alert sent successfully for $api_name."
    else
        log_message "ERROR: Failed to send email alert for $api_name. Check sendmail configuration."
    fi
}

# Reboots the system
reboot_system() {
    log_message "CRITICAL: All APIs are down. Rebooting system as per configuration."
    # For safety, this is commented out. Uncomment to enable.
    # sudo reboot
}

# Updates the state of API failures
update_state() {
    local api_name="$1"
    local status="$2"
    
    # Create state file if it doesn't exist
    [ -f "$STATE_FILE" ] || echo "{}" > "$STATE_FILE"
    
    failure_count=$(jq -r --arg name "$api_name" '.[$name] // 0' "$STATE_FILE")
    
    if [ "$status" == "UP" ]; then
        new_state=$(jq --arg name "$api_name" 'del(.[$name])' "$STATE_FILE")
    else # DOWN
        new_count=$((failure_count + 1))
        new_state=$(jq --arg name "$api_name" --argjson count "$new_count" '.[$name] = $count' "$STATE_FILE")
        
        if [ "$new_count" -ge "$FAILURE_THRESHOLD" ]; then
            send_email_alert "$api_name"
        fi
    fi
    echo "$new_state" > "$STATE_FILE"
}

# --- Main Script ---

main() {
    load_config
    # Ensure log and state files exist
    touch "$LOG_FILE"
    touch "$STATE_FILE"

    log_message "Infinity War script started."

    while true; do
        total_apis=0
        down_apis=0

        api_count=$(jq '.apis | length' "$CONFIG_FILE")

        for i in $(seq 0 $((api_count - 1))); do
            total_apis=$((total_apis + 1))
            api_object=$(jq -c ".apis[$i]" "$CONFIG_FILE")
            api_name=$(echo "$api_object" | jq -r '.name')
            api_url=$(echo "$api_object" | jq -r '.url')
            
            if ! check_api "$api_name" "$api_url"; then
                down_apis=$((down_apis + 1))
            fi
        done

        if [ "$REBOOT_ON_TOTAL_FAILURE" == "true" ] && [ "$total_apis" -gt 0 ] && [ "$down_apis" -eq "$total_apis" ]; then
            reboot_system
        fi

        log_message "Health check cycle completed. Waiting for $CHECK_INTERVAL seconds."
        sleep "$CHECK_INTERVAL"
    done
}

# --- Entry Point ---
main

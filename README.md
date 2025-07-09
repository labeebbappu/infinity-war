# Infinity War: System Health Monitoring and Recovery Script

## Overview

"Infinity War" is a lightweight bash script designed to monitor the health of critical APIs. It periodically checks a list of configured APIs, logs their status, tracks consecutive failures, and can send email alerts or even trigger a system reboot if all monitored services become unavailable.

## Features

*   API Health Checking (HTTP/HTTPS)
*   Configurable check intervals and failure thresholds
*   Email alerts on prolonged API downtime
*   Optional system reboot if all APIs are down
*   Logging of all activities
*   State management for tracking consecutive failures

## Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **`bash`**: The script is written in Bash.
*   **`curl`**: Used for making HTTP requests to check API health.
*   **`jq`**: A lightweight and flexible command-line JSON processor. Used for parsing the configuration file and state file.
    *   **Installation (Debian/Ubuntu):** `sudo apt-get install jq`
    *   **Installation (macOS):** `brew install jq`
*   **`sendmail` (or compatible MTA)**: Required for sending email alerts. Ensure it's configured on your system to send emails.

## Setup Instructions

1.  **Navigate to the Script Directory:**
    ```bash
    cd /Users/labeeb/drive/ct-projects/greenbin/greenbin-server-production/infra/infinity-war/
    ```
    You can get the absolute path to this directory by running `pwd`.

2.  **Make the Script Executable:**
    ```bash
    chmod +x infinity-war.sh start.sh stop.sh
    ```

3.  **Configure `config.json`:**
    Open `config.json` in your preferred text editor and modify the settings according to your needs.

    ```json
    {
      "apis": [
        {"name": "My Backend API", "url": "http://your-backend-api.com/health"},
        {"name": "External Service", "url": "https://api.external.com/status"}
      ],
      "check_interval_seconds": 60,
      "failure_threshold": 3,
      "reboot_on_total_failure": true,
      "smtp_settings": {
        "host": "smtp.your-email-provider.com",
        "port": 587,
        "user": "your-email@example.com",
        "password": "YOUR_SMTP_PASSWORD" 
      },
      "log_file": "infinity-war.log",
      "state_file": "infinity-war.state"
    }
    ```

    *   **`apis`**: An array of JSON objects, each representing an API to monitor. Provide a `name` and `url` for each.
    *   **`check_interval_seconds`**: How often (in seconds) the script checks the APIs.
    *   **`failure_threshold`**: The number of consecutive failures before an email alert is sent.
    *   **`reboot_on_total_failure`**: Set to `true` to enable system reboot if *all* configured APIs are down. **Use with caution!** The `sudo reboot` command in the script is commented out by default for safety.
    *   **`smtp_settings`**: Your SMTP server details for sending email alerts.
        *   **`password`**: Your SMTP password. **SECURITY WARNING:** Storing passwords in plaintext in configuration files is generally not recommended for production environments. Consider using more secure methods (e.g., environment variables, secret management tools) for sensitive credentials.
    *   **`log_file`**: The name of the log file. It will be created in the same directory as the script.
    *   **`state_file`**: The name of the state file. It will be created in the same directory as the script.

## Running the Script

For continuous monitoring, it's recommended to run the script as a daemon. We've provided simple `start.sh` and `stop.sh` scripts for convenience.

1.  **Start the script as a daemon:**
    ```bash
    ./start.sh
    ```
    This will run `infinity-war.sh` in the background using `nohup`, redirecting its output to the `log_file` specified in `config.json`.

2.  **Check if the script is running:**
    ```bash
    pgrep -f infinity-war.sh
    ```
    If a PID (Process ID) is returned, the script is running.

3.  **Stop the script:**
    ```bash
    ./stop.sh
    ```
    This will find and terminate the running `infinity-war.sh` process.

Alternatively, for simple background execution (not recommended for continuous monitoring as it might terminate if your terminal session closes):

```bash
./infinity-war.sh &
```

To stop a script started with `&`, you'll need to find its process ID (PID) and kill it:

```bash
pgrep -f infinity-war.sh
# Then, kill the process (replace <PID> with the actual PID)
kill <PID>
# Or, to kill the process group (if started with `&` in a new process group):
kill -- -<PGID> # Replace <PGID> with the process group ID
```

### Autostart After Reboot (using Cron)

To ensure the `infinity-war.sh` script automatically starts after a system reboot, you can add an entry to your user's crontab. This is a simple and effective way to achieve continuous monitoring.

1.  **Get the absolute path to the script directory:**
    ```bash
    cd /Users/labeeb/drive/ct-projects/greenbin/greenbin-server-production/infra/infinity-war/
    SCRIPT_PATH=$(pwd)
    ```

2.  **Open your crontab for editing:**
    ```bash
    crontab -e
    ```

3.  **Add the following line to the end of the file:**
    Replace `/path/to/your/project/infra/infinity-war` with the `SCRIPT_PATH` you obtained in step 1.

    ```cron
    @reboot $SCRIPT_PATH/start.sh
    ```

    *   `@reboot`: This special cron keyword executes the command once, at system startup.
    *   `$SCRIPT_PATH/start.sh`: This is the absolute path to the `start.sh` script, which will launch `infinity-war.sh` as a daemon.

4.  **Save and exit** the crontab editor. The cron job will be installed.

Now, the `infinity-war.sh` script will automatically start monitoring your APIs every time your system reboots.

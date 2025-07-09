# Infinity War: System Health Monitoring and Recovery Script

## 1. Overview

"Infinity War" is a bash script designed to monitor the health of critical APIs and take automated actions to ensure system stability. It periodically checks a list of APIs, sends email alerts on prolonged failures, and can reboot the system as a last resort if all services are unavailable.

## 2. Features

*   **API Health Checking:** Periodically checks the status of a list of APIs.
*   **Automated Reboot:** Reboots the system if all monitored APIs are down. (**Use with extreme caution.**)
*   **SMTP Email Alerts:** Sends email notifications via an SMTP server if an API remains down for a configurable number of checks.
*   **Configuration Driven:** All settings are managed through the `config.json` file.
*   **Full Suite of Utility Scripts:** Includes scripts for easy setup, start, stop, status checks, and maintenance.
*   **Startup on Reboot:** Can be easily configured to start automatically on system boot.
*   **Detailed Logging:** Maintains a log file for diagnostics and auditing.

## 3. Prerequisites

Ensure you have the following command-line tools installed on your system:
*   `jq`: For parsing JSON configuration.
*   `curl`: For checking API health and sending emails.

## 4. Installation and Setup

1.  **Clone the Repository**
    ```bash
    git clone <your-repo-url>
    cd infinity-war
    ```

2.  **Configure `config.json`**
    Open `config.json` and fill in your details. Pay close attention to the `apis` and `smtp_settings` sections.

3.  **Run the Setup Script**
    This will check for dependencies, create the necessary log/state files, and make all scripts executable.
    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

## 5. Usage

All scripts are designed to be run from the project's root directory.

| Script                 | Description                                             |
| ---------------------- | ------------------------------------------------------- |
| `./start.sh`           | Starts the monitoring script in the background.         |
| `./stop.sh`            | Stops the running monitoring script.                    |
| `./status.sh`          | Checks if the monitoring script is currently running.   |
| `./reset-log.sh`       | Clears all content from the log file.                   |
| `./reset-state.sh`     | Resets the API failure state tracker.                   |
| `./start-on-reboot.sh` | Installs a cron job to start the monitor on system boot.|


## 6. Configuration Details (`config.json`)

```json
{
  "apis": [
    {"name": "Service A", "url": "https://api.service-a.com/health"},
    {"name": "Service B", "url": "http://localhost:8080/status"}
  ],
  "check_interval_seconds": 60,
  "failure_threshold": 3,
  "reboot_on_total_failure": true,
  "smtp_settings": {
    "host": "smtp.example.com",
    "port": 587,
    "user": "user@example.com",
    "password": "YOUR_SMTP_PASSWORD"
  },
  "log_file": "/Users/labeeb/drive/labeebdev/infinity-war/infinity-war.log",
  "state_file": "/Users/labeeb/drive/labeebdev/infinity-war/infinity-war.state"
}
```
*   **`apis`**: A list of APIs to monitor.
*   **`check_interval_seconds`**: Time in seconds between each health check.
*   **`failure_threshold`**: Number of consecutive failures before sending an email alert.
*   **`reboot_on_total_failure`**: A boolean to enable or disable the reboot feature.
*   **`smtp_settings`**: Configuration for sending email alerts. **Warning:** Storing passwords in plaintext is a security risk. Secure this file appropriately.
*   **`log_file`**: The absolute path to the log file.
*   **`state_file`**: The absolute path to the state file.
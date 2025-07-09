# Infinity War: System Health Monitoring and Recovery Script

## 1. Overview

"Infinity War" is a bash script designed to monitor the health of critical APIs and take automated actions to ensure system stability. It will periodically check a list of APIs, send alerts on prolonged failures, and reboot the system as a last resort if all services are unavailable.

## 2. Core Features

*   **API Health Checking:** Periodically checks the status of a list of APIs.
*   **Automated Reboot:** Reboots the system if all monitored APIs are down.
*   **Email Alerts:** Sends email notifications via SMTP if an API remains down for a configurable number of consecutive checks.
*   **Configuration Driven:** All settings, including the API list and email configurations, are managed through an external JSON file.
*   **Status Check:** Provides a mechanism to verify that the monitoring script is running.
*   **Startup Execution:** Automatically starts at system boot.
*   **Logging:** Maintains a log file for diagnostics and auditing.

## 3. Configuration (`config.json`)

The script will use a `config.json` file for all its settings.

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
  "log_file": "/var/log/infinity-war.log",
  "state_file": "/tmp/infinity-war.state"
}
```

*   **`apis`**: A list of APIs to monitor. Each object contains a `name` for identification and a `url` to check.
*   **`check_interval_seconds`**: The time in seconds between each health check.
*   **`failure_threshold`**: The number of consecutive failures before sending an email alert.
*   **`reboot_on_total_failure`**: A boolean to enable or disable the reboot feature.
*   **`smtp_settings`**: Configuration for sending email alerts.
*   **`log_file`**: The path to the log file.
*   **`state_file`**: The path to the file used for storing the state of API failures.


## 4. Logging

All actions and errors will be logged to the specified `log_file`. Log entries will be timestamped and will include:
*   API health check results (success or failure).
*   Email alert notifications.
*   System reboot triggers.
*   Script startup and shutdown events.
*   Configuration or runtime errors.

## 5. Usage

*   setup.sh - to setup the config
*   start.sh - to start the script
*   stop.sh - to stop the script
*   status.sh - to check the status of the script
*   start-on-reboot.sh - start on system reboot
*   reset-log.sh - to reset the log file
*   reset-state.sh - to reset the state file

## 6. installation 

clone git repo then run setup.sh to check all dependancy and packages are installed.
then start.sh to start app in deamon mode.

start-on-reboot.sh to eazy configure startup on reboot just like pm2




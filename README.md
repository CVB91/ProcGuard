
# ProcGuard - Malicious Process Detector

## Explanation of the Script

### Thresholds:
- **CPU_THRESHOLD**: The percentage of CPU usage that, if exceeded, triggers an alert.
- **MEM_THRESHOLD**: The percentage of memory usage that, if exceeded, triggers an alert.

### Log Alerts:
- The `log_alert` function logs alerts to `/var/log/procguard.log`. You can also send emails or log to system logs using `mail` or `logger`.

### Process Checks:
The script checks all processes for:
- **High CPU and memory usage**.
- **Suspicious process names** (e.g., processes with random-looking names).
- **Unusual parent-child relationships** (e.g., web server spawning a shell).
- **Processes running from non-standard directories** (e.g., `/tmp` or `/dev/shm`).

### Real-Time Monitoring:
- The script continuously monitors processes and checks them every 30 seconds. You can adjust this interval as needed.

## Making the Script Executable

To make the script executable, follow these steps:

### 1. Save the Script:
- Save the script to a file, e.g., `procguard.sh`.

### 2. Make the Script Executable:
Run the following command to give the script execute permissions:
```bash
chmod +x procguard.sh
```

### 3. Run the Script:
You can now run the script by executing:
```bash
./procguard.sh
```

## Running the Script Automatically (Optional):

To make **ProcGuard** run automatically at system startup, you can create a cron job or add it to system services.

### Add to Cron:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add the following line to run **ProcGuard** at startup:
   ```bash
   @reboot /path/to/procguard.sh
   ```

### Create a Systemd Service:

1. Create a new service file in `/etc/systemd/system/procguard.service`:
   ```bash
   sudo nano /etc/systemd/system/procguard.service
   ```
2. Add the following content:
   ```ini
   [Unit]
   Description=ProcGuard - Malicious Process Detector

   [Service]
   ExecStart=/path/to/procguard.sh
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. Reload the systemd daemon and enable the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable procguard.service
   ```

4. Start the service:
   ```bash
   sudo systemctl start procguard.service
   ```


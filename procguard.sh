#!/bin/bash

# Set thresholds for CPU and memory usage
CPU_THRESHOLD=80  # 80% CPU usage
MEM_THRESHOLD=70  # 70% Memory usage

# Log file for malicious process detection
LOG_FILE="/var/log/procguard.log"

# Function to log alerts
log_alert() {
    local message=$1
    echo "[ALERT] $(date): $message" >> $LOG_FILE
    logger "ProcGuard Alert: $message"
}

# Function to check for suspicious process behavior
check_process() {
    local pid=$1
    local process_info=$(ps -p $pid -o %cpu,%mem,comm,ppid,uid,cmd --no-headers)

    cpu_usage=$(echo $process_info | awk '{print $1}')
    mem_usage=$(echo $process_info | awk '{print $2}')
    proc_name=$(echo $process_info | awk '{print $3}')
    parent_pid=$(echo $process_info | awk '{print $4}')
    uid=$(echo $process_info | awk '{print $5}')
    full_cmd=$(echo $process_info | awk '{print $6}')

    # Check for high CPU or memory usage
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        log_alert "High CPU usage detected: Process $proc_name (PID: $pid) is using $cpu_usage% CPU"
    fi

    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        log_alert "High memory usage detected: Process $proc_name (PID: $pid) is using $mem_usage% memory"
    fi

    # Check for non-standard names (example: cr0n instead of cron)
    if [[ "$proc_name" =~ ^[a-z0-9]{4,10}$ ]] && ! command -v "$proc_name" > /dev/null; then
        log_alert "Suspicious process name detected: $proc_name (PID: $pid)"
    fi

    # Check for unusual parent-child relationships (e.g., web server starting a shell)
    parent_name=$(ps -p $parent_pid -o comm=)
    if [[ "$parent_name" == "nginx" || "$parent_name" == "apache2" ]] && [[ "$proc_name" == "bash" ]]; then
        log_alert "Unusual process hierarchy detected: $proc_name (PID: $pid) started by $parent_name"
    fi

    # Check for processes running from non-standard directories (e.g., /tmp, /dev/shm)
    if [[ "$full_cmd" =~ /tmp/ || "$full_cmd" =~ /dev/shm/ ]]; then
        log_alert "Process running from suspicious directory: $full_cmd (PID: $pid)"
    fi
}

# Monitor processes
while true; do
    # Get list of running process IDs (ignoring processes owned by root)
    ps -u $(whoami) -o pid= | while read pid; do
        check_process "$pid"
    done

    # Sleep for 30 seconds before the next check
    sleep 30
done

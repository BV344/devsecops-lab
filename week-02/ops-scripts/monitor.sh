#!/bin/bash

# --- Config ---
LOGFILE="$HOME/logs/monitor.log"
THRESHOLD=80

# --- Setup ---
mkdir -p "$HOME/logs"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# --- Disk Check ---
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

# --- Memory Check ---
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')
MEM_PERCENT=$(awk "BEGIN {printf \"%d\", ($MEM_USED/$MEM_TOTAL)*100}")

# --- Log Results ---
echo "[$TIMESTAMP] DISK: ${DISK_USAGE}% used | MEM: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PERCENT}%)"  >> "$LOGFILE"

# --- Alerts ---
if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
  echo "[$TIMESTAMP] WARNING: Disk usage above ${THRESHOLD}%!" >> "$LOGFILE"
fi

if [ "$MEM_PERCENT" -gt "$THRESHOLD" ]; then
  echo "[$TIMESTAMP] WARNING: Memory usage above ${THRESHOLD}%!" >> "$LOGFILE"
fi


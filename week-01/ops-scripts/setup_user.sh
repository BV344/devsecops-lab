#!/bin/bash

# --- Config ---
USERNAME=$1
LOG_FILE="/tmp/setup_log.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# --- Functions ---
log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# --- Main ---
log "Script started by: $USER"
log "Starting user setup script"

if id "$USERNAME" &>/dev/null; then
    log "User $USERNAME already exists. Skipping creation."
else
    sudo useradd -m -s /bin/bash "$USERNAME"
    log "Created user: $USERNAME"
fi

# Create a projects directory in their home
sudo mkdir -p /home/$USERNAME/projects
sudo chown $USERNAME:$USERNAME /home/$USERNAME/projects
log "Created /home/$USERNAME/projects"

log "Setup complete. Log written to $LOG_FILE"

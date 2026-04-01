# Week 2 Notes - Server Administration

## SSH
- Connected to bv344server on Linux Ubuntu with command 
	```ssh bv344@bv344server```
- My server is my 2018 MacBookPro

## systemctl
- Similar to Windows' Services.msc GUI 
- Manages the Server's Services
- Key commands: start, stop, restart, status, is-enabled, is-active
- ssh.service is triggered by ssh.socket (socket activation)

## journalctl
- Similar to Windows' Event Viewer
- Manages the Server's Logs
- Key Flags: -u (unit), -b (boot), -p (priority), -f (follow), -n (lines)
- Triaged T2 Mac Kernel Errors - all hardware noise, not actionable

## Environment Variables
- Variables you can call with terminal commands or shell scripts
- Temporary: export VAR=value
- Persistent: append to ~/.bashrc, then source ~/.bashrc
- Full list: env | key ones: $HOME, $USER, $PATH, $SHELL

## Cron
- Similar to Windows' Task Scheduler
- Schedules commands automatically
- Edit with: crontab -e | List with: crontab -l
- */5 * * * * runs every 5 min
- ALWAYS use full paths in cron jobs

## Monitoring Script
- Check Disk and Memory usage
- Logs timestamped entries to ~/logs/monitor.log
- Alerts if either exceeds 80%
- Runs every 5 min via cron on bv344server

# Week 18 Notes — Incident Response

## What is Incident Response?
Incident Response (IR) is the structured process of detecting, 
containing, and recovering from a security breach or attack. 
Having a plan before an incident happens is critical — 
panicking during a breach leads to mistakes that make things worse.

## The 6 Phases of Incident Response

1. **Preparation** — having tools, runbooks, and procedures ready 
   before an incident happens. Monitoring, logging, and alerting 
   all set up in advance.

2. **Detection** — identifying that something is wrong. 
   Using logs, monitoring alerts, and anomaly detection to spot 
   suspicious activity.

3. **Containment** — stopping the bleeding. Isolating affected 
   systems, blocking attacker access, preventing further damage 
   without destroying evidence.

4. **Eradication** — removing everything the attacker left behind. 
   Deleting malicious files, removing backdoor accounts, cleaning 
   persistence mechanisms like cron jobs.

5. **Recovery** — restoring systems to normal operation. 
   Verifying the system is clean before bringing it back online.

6. **Lessons Learned** — documenting what happened, what worked, 
   what didn't, and how to prevent it next time. The incident 
   report is the output of this phase.

## IOCs — Indicators of Compromise
IOCs are artifacts left behind by an attacker that indicate a 
system has been compromised. Common IOCs include:

- Suspicious files in `/tmp` with world-writable permissions (777)
- Unknown cron jobs in `/etc/cron.d/` — especially ones that 
  download and execute remote scripts
- Unknown user accounts in `/etc/passwd`
- Unexpected network connections
- Unusual sudo usage or login times

## What We Detected This Week
Three IOCs planted as a simulation:

| IOC | Location | Significance |
|---|---|---|
| World-writable script | `/tmp/suspicious-script.sh` | Attacker staging area |
| Malicious cron job | `/etc/cron.d/malicious` | Persistence mechanism — runs every minute |
| Backdoor user | `suspicious-user` UID 1001 | Maintains access after initial entry closed |

## Containment vs Eradication

**Containment** — stopping further damage while preserving evidence:
- Lock the suspicious user account (`usermod -L`)
- Block network access if needed
- Do NOT delete anything yet — preserve evidence first

**Eradication** — removing all attacker artifacts:
- Delete malicious cron jobs
- Remove suspicious files
- Delete backdoor user accounts (`userdel -r`)
- Verify system is completely clean

## What auth.log Tells You
`/var/log/auth.log` is your most important forensic file during 
an incident. It records:

- Every SSH login attempt (successful and failed)
- Every sudo command executed — who ran what and when
- User account creation and deletion
- PAM authentication events

Key commands for investigation:
```bash
sudo grep "Failed password" /var/log/auth.log   # Brute force attempts
sudo grep "Accepted" /var/log/auth.log           # Successful logins
sudo grep "sudo" /var/log/auth.log               # Privilege escalation
sudo grep "useradd\|adduser" /var/log/auth.log   # New accounts
last | head -20                                   # Login history
who && w                                          # Currently logged in
```

## Incident Reports
Documentation is a critical part of incident response because:
- Creates a legal record of what happened
- Helps leadership understand the impact
- Required by compliance frameworks like SOC2 and PCI-DSS
- Enables lessons learned to prevent future incidents
- Provides timeline evidence if law enforcement is involved

A good incident report includes:
- Timeline of events with exact timestamps
- All IOCs discovered
- Every action taken and by whom
- Root cause analysis
- Lessons learned and prevention recommendations

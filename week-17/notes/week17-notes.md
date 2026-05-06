# Week 17 Notes — Infrastructure Security & Compliance

## Lynis
Lynis is an open source security auditing tool for Linux systems. 
It performs hundreds of automated checks across your entire system — 
SSH configuration, file permissions, installed packages, network 
settings, authentication policies, and more. It then produces a 
prioritized list of warnings and suggestions to improve security.

Run with:
```bash
sudo lynis audit system
```

Results are saved to `/var/log/lynis.log` for detailed review.

## Hardening Index
A score out of 100 that represents how well your server follows 
security best practices. Higher is better — but 100 is practically 
impossible on a real server because some suggestions require 
infrastructure changes like separate disk partitions or are 
irrelevant to your specific use case.

Our score progression this week:

- Starting score:  59/100  (2 warnings, 52 suggestions)
- After SSH fixes: 69/100  (1 warning, 45 suggestions)
- After all fixes: 71/100  (1 warning, 43 suggestions)
- Total improvement: +12 points

## SSH Hardening Applied
Changed these settings in `/etc/ssh/sshd_config`:

| Setting | Before | After | Why |
|---|---|---|---|
| `MaxAuthTries` | 6 | 3 | Limits brute force attempts |
| `MaxSessions` | 10 | 2 | Reduces attack surface |
| `X11Forwarding` | yes | no | Disables unnecessary GUI forwarding |
| `AllowTcpForwarding` | yes | no | Prevents tunneling abuse |
| `AllowAgentForwarding` | yes | no | Prevents credential forwarding |
| `TCPKeepAlive` | yes | no | Prevents session hijacking |
| `LogLevel` | INFO | VERBOSE | More detailed audit logging |
| `ClientAliveCountMax` | 3 | 2 | Faster idle session cleanup |

## fail2ban
fail2ban monitors log files for repeated failed authentication 
attempts and automatically bans the offending IP address using 
firewall rules. Essential protection against brute force attacks 
on SSH and other services.

- Installed via `apt install fail2ban`
- Config copied to `jail.local` so updates don't overwrite settings
- Works alongside UFW to automatically block attackers

## rkhunter (Rootkit Hunter)
A malware scanner that checks your system for rootkits, backdoors, 
and suspicious files. Scans against a database of known malware 
signatures and checks file integrity.

Results from our scan:
- Files checked: 142 — Suspect files: 0 ✅
- Rootkits checked: 498 — Possible rootkits: 0 ✅

Run periodically with:
```bash
sudo rkhunter --check --skip-keypress
```

## auditd
The Linux audit daemon tracks system calls and security-relevant 
events — who ran what command, who accessed which file, who changed 
which configuration. Creates a tamper-evident audit trail required 
by compliance frameworks like SOC2 and PCI-DSS.

## Legal Banners
Added warning messages to `/etc/issue` and `/etc/issue.net`:

"Authorized access only. All activity is monitored."

These display before login and serve as legal notice — important 
for compliance and prosecution if unauthorized access occurs.

## CIS Benchmarks
CIS (Center for Internet Security) publishes detailed hardening 
guides for every major OS and platform. They define specific 
configuration settings that constitute a secure baseline.

Lynis checks your system against these benchmarks and flags 
deviations. In regulated industries (healthcare, finance, 
government) passing CIS benchmarks is often a compliance requirement.

Key compliance frameworks that use security baselines:
- **SOC2** — Service Organization Control, common for SaaS companies
- **PCI-DSS** — Payment Card Industry, required for handling payments
- **HIPAA** — Healthcare data protection
- **ISO 27001** — International security management standard

## Key Takeaway
Security hardening is never "done" — it's an ongoing process of 
running audits, fixing findings, and re-auditing. Lynis gives you 
a repeatable baseline to measure progress over time.

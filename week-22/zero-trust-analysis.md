# Week 22 Notes — Zero Trust Architecture

## What is Zero Trust?
Traditional security followed a "castle and moat" model — build 
a strong perimeter and trust everything inside it. Once inside 
the network you could move freely. Modern attacks broke this model 
by getting inside through phishing, stolen credentials, or 
compromised devices and then moving laterally without resistance.

Zero Trust flips this completely:

- Old Model --> Trust but verify
- New Model --> Never trust, ALWAYS verify

No user, device, or service is trusted by default — even if 
they're already inside your network. Every request must be 
authenticated, authorized, and continuously verified.

## The 3 Core Pillars

### 1. Verify Explicitly
Never assume a user or service is who they claim to be. Always 
authenticate and authorize every request regardless of where it 
comes from — inside or outside the network.

**Implemented in our lab:**
- MFA on AWS root account, bv344-admin, and bv344-readonly — 
  a stolen password alone is not enough to get in
- MFA on GitHub account — prevents unauthorized code pushes
- Vault requires a token for every secret access — no token, 
  no secret, even from inside the server
- IMDSv2 requires a session token before any process can query 
  EC2 instance metadata — prevents SSRF attacks
- SSH hardened with MaxAuthTries 3 and LogLevel VERBOSE — 
  every authentication attempt is logged and verified

**Why it matters:** In 2019 Capital One was breached because 
an attacker could query EC2 metadata without any authentication. 
IMDSv2 would have prevented it.

### 2. Use Least Privilege
Every user, service, and process should have only the minimum 
access needed to do its job — nothing more. If credentials are 
compromised the blast radius is limited.

**Implemented in our lab:**
- Kubernetes RBAC — `developer-readonly` role can only `get`, 
  `list`, and `watch` pods and services — cannot create or delete
- AWS IAM — `bv344-readonly` in `readonly-users` group can view 
  EC2 but cannot launch, modify, or terminate instances
- AWS IAM — `bv344-admin` gets admin access through a group, 
  not directly attached to the user
- Docker containers run as `appuser` (UID 100) not root — if 
  the container is compromised the attacker has no privileges
- Kubernetes security context — `capabilities: drop: ALL` removes 
  every Linux capability from containers
- Vault policy `myapp-policy` — read-only access to specific 
  secret paths, cannot read other secrets or modify anything

**Why it matters:** When `bv344-readonly` was compromised in our 
Week 13 simulation, the attacker could only view EC2 instances — 
they couldn't launch new ones, delete anything, or access other 
AWS services.

### 3. Assume Breach
Design and operate your systems as if attackers are already inside. 
Don't rely solely on prevention — invest heavily in detection, 
monitoring, and response so you can find and contain breaches 
quickly.

**Implemented in our lab:**
- Prometheus + Grafana monitors server CPU, memory, and disk 
  in real time — abnormal resource usage is immediately visible
- Loki + Promtail ships logs off the server in real time — 
  even if an attacker deletes local logs, Loki retains them
- auditd tracks every system call and file change on bv344server 
  — creates a tamper-evident audit trail
- fail2ban automatically bans IPs that fail authentication 
  repeatedly — contains brute force attempts
- rkhunter scans for rootkits and malware weekly
- Vault is sealed by default and requires manual unsealing — 
  even if someone gets into the server, Vault secrets are 
  inaccessible without the unseal key
- Incident response plan from Week 18 — documented runbook 
  for detecting, containing, and eradicating threats
- Prowler continuously audits AWS for misconfigurations — 
  catches drift from secure baseline

**Why it matters:** The Vault sealing is a perfect example of 
Assume Breach thinking — we assume someone might get into the 
server, so we design Vault to be useless without the unseal key 
even with full server access.

## Zero Trust vs Traditional Security

| Traditional | Zero Trust |
|---|---|
| Trust the internal network | Trust nothing by default |
| VPN = full access | Verify every request |
| Perimeter focused | Identity focused |
| React after breach | Assume breach, detect fast |
| One big flat network | Micro-segmented workloads |

## Micro-Segmentation in Our Lab
Zero Trust also requires isolating workloads so a breach in one 
area can't spread to everything else:

- UFW restricts monitoring ports (3000, 9090, 9100, 8200) to 
  `10.0.0.0/24` only — not accessible from the internet
- Docker containers bound to `127.0.0.1` — not directly 
  accessible even from the local network
- AWS Security Groups restrict EC2 access by port and source
- Kubernetes namespaces isolate workloads from each other
- Vault policies isolate which secrets each app can access

## Key Takeaway
Zero Trust is not a product you buy — it's a philosophy you 
apply. Looking back at 22 weeks of work, Zero Trust principles 
were woven into every layer: identity verification, least 
privilege access, continuous monitoring, and assuming attackers 
are already inside. The goal is to make every breach contained, 
detectable, and recoverable.

# Threat Model — DevSecOps Lab
**Author:** BV344
**Date:** 2026-05-21
**Methodology:** STRIDE

## System Overview
This threat model covers the DevSecOps home lab built over 20 weeks.
The system consists of three main attack surfaces:
- GitHub CI/CD pipeline (code, secrets, Docker images)
- bv344server (Ubuntu 24.04, monitoring stack, Vault)
- AWS account (EC2, IAM, EBS, networking)

## Architecture Diagram
1. Internet
2. GitHub (source code + CI/CD)
3. GitHub Actions (gitleaks → Trivy → Docker push)
4. Docker Hub (container registry)
5. Home Network (10.0.0.x)
- Ubuntu Desktop (10.0.0.15) — Terraform, kubectl, Prowler
- bv344server (10.0.0.50)

- Nginx (HTTPS reverse proxy)
- Grafana + Prometheus + Node Exporter
- Loki + Promtail
- Vault (secrets management)

5. AWS Cloud (us-east-2)
- EC2 (bv344-server, stopped)
- IAM (bv344-admin, bv344-readonly)
- EBS (encrypted volume)
- Security Group (bv344-sg)

---

## Component 1 — GitHub CI/CD Pipeline

### Threat Surface
Source code, GitHub Actions workflows, Docker Hub credentials,
secrets stored as GitHub Secrets, pipeline configuration files.

### STRIDE Analysis

**S — Spoofing**
An attacker compromises GitHub credentials and pushes code
pretending to be the legitimate developer. They could modify
the pipeline workflow or inject malicious commits.

*Mitigations:* MFA on GitHub account, branch protection rules,
gitleaks scanning on every push.

**T — Tampering**
An attacker modifies the Dockerfile or application code to
inject malware into the Docker image. The image gets pushed
to Docker Hub and anyone who pulls it gets infected — a
classic supply chain attack similar to SolarWinds 2021.

*Mitigations:* Trivy image scanning with `exit-code: 1` as
a hard gate, gitleaks secret scanning, image signing.

**R — Repudiation**
An attacker injects code that disables or encrypts pipeline
logs, removing evidence of the compromise. Without logs
you can't prove what happened or when.

*Mitigations:* GitHub Actions logs are stored by GitHub and
can't be deleted by pipeline code, auditd on server.

**I — Information Disclosure**
Hardcoded secrets accidentally committed to the repo expose
Docker Hub tokens, AWS credentials, or API keys to anyone
who can read the repository.

*Mitigations:* Gitleaks scans every commit and full git
history, `.gitleaks.toml` allowlist for known false positives,
secrets stored as GitHub Secrets never in code.

**D — Denial of Service**
A malicious Docker image consumes all CPU and memory on
any host that runs it, effectively taking down the server.

*Mitigations:* Container resource limits (`--memory=128m`,
`--cpus=0.5`) from Week 14, Kubernetes resource limits from
Week 15.

**E — Elevation of Privilege**
A container running as root escapes to the host system,
giving the attacker full root access on any machine that
pulls and runs the compromised image.

*Mitigations:* Non-root container user (`appuser` UID 100),
`runAsNonRoot: true` in Kubernetes security context,
`allowPrivilegeEscalation: false`, `capabilities: drop: ALL`.

---

## Component 2 — bv344server

### Threat Surface
SSH access, Nginx reverse proxy, Grafana dashboard, Prometheus
metrics, Loki logs, Vault secrets, all running on home network.

### STRIDE Analysis

**S — Spoofing**
An attacker brute forces SSH credentials and logs in as
`bv344`, gaining access to the server and pivoting to other
devices on the `10.0.0.x` home network.

*Mitigations:* fail2ban auto-bans brute force attempts,
SSH hardening (MaxAuthTries 3, key-based auth), UFW firewall
restricts SSH to local network only.

**T — Tampering**
An attacker with server access modifies monitoring configs,
Nginx SSL certificates, or Vault data. They could replace
the self-signed cert with a malicious one to intercept
HTTPS traffic.

*Mitigations:* File integrity monitoring with rkhunter,
auditd tracks all file changes, Lynis hardening score 71/100.

**R — Repudiation**
An attacker deletes or modifies `/var/log/auth.log` and
system logs to erase evidence of their intrusion, making
incident response impossible.

*Mitigations:* Loki + Promtail ships logs off the server
in real time — even if local logs are deleted, Loki retains
them. Auditd creates tamper-evident audit trails.

**I — Information Disclosure**
Grafana dashboards expose server metrics, Loki exposes
system logs, and Vault contains secrets. If any service
is misconfigured to be publicly accessible, sensitive
infrastructure data leaks.

*Mitigations:* All services bound to `127.0.0.1` (Week 12),
Nginx reverse proxy with HTTPS only, UFW restricts all
monitoring ports to `10.0.0.0/24` local network only.

**D — Denial of Service**
An attacker floods the server with traffic or exploits a
vulnerability to consume 100% CPU/memory, taking down
Grafana, Prometheus, and Vault simultaneously.

*Mitigations:* UFW rate limiting, Docker resource limits,
fail2ban blocks repeat offenders, server monitoring alerts
via Grafana if CPU/memory spikes.

**E — Elevation of Privilege**
An attacker exploits a vulnerability in Nginx or Grafana
to escape to the host system, then escalates to root to
gain full server control and access to Vault secrets.

*Mitigations:* Non-root service accounts where possible,
regular `apt upgrade` for security patches, Lynis auditing,
rkhunter malware scanning, SSH hardening.

---

## Component 3 — AWS Account

### Threat Surface
IAM credentials, EC2 instances, EBS volumes, security groups,
network ACLs, AWS CLI access keys.

### STRIDE Analysis

**S — Spoofing**
An attacker obtains `bv344-admin` IAM credentials (via
phishing, credential stuffing, or a leaked access key)
and authenticates to AWS as the legitimate admin user,
gaining full account access.

*Mitigations:* MFA on all IAM users, access keys rotated
within 90 days, no root access keys, IAM credential report
audited regularly.

**T — Tampering**
An attacker with AWS access modifies Terraform state,
changes security group rules to open ports, or alters
EC2 instance configurations to create backdoors.

*Mitigations:* Terraform IaC means infrastructure is
version controlled — unauthorized changes can be detected
by comparing state. Prowler continuously audits for
misconfigurations.

**R — Repudiation**
An attacker disables CloudTrail or deletes CloudTrail logs
to erase evidence of API calls made during a compromise.
Without logs you can't reconstruct the attack timeline.

*Mitigations:* CloudTrail should be enabled (noted as
future improvement), Prowler flags missing audit logging,
AWS Config tracks configuration changes over time.

**I — Information Disclosure**
Hardcoded AWS credentials accidentally committed to GitHub
expose the account to anyone who finds them. Unencrypted
EBS volumes expose data if AWS infrastructure is accessed.

*Mitigations:* Gitleaks scans git history for credentials,
EBS default encryption enabled (Week 20), IMDSv2 enforced
to prevent SSRF-based credential theft.

**D — Denial of Service**
An attacker with AWS credentials spins up hundreds of
expensive EC2 instances for cryptocurrency mining, causing
massive unexpected bills — effectively a financial DoS.
This is one of the most common AWS attack scenarios.

*Mitigations:* Billing alerts ($5 threshold), IAM least
privilege limits what each user can launch, Prowler audits
for overly permissive policies, MFA on admin accounts.

**E — Elevation of Privilege**
An attacker compromises the `bv344-readonly` user then
exploits an IAM misconfiguration to escalate to admin
privileges, gaining full AWS account control.

*Mitigations:* Strict separation between readonly-users
and devsecops-admin groups, no privilege escalation paths
in IAM policies, IAM Policy Simulator used to verify
permissions (Week 13).

---

## Risk Summary

| Component | Highest Risk | Likelihood | Impact | Status |
|---|---|---|---|---|
| GitHub Pipeline | Supply chain attack | Medium | Critical | Mitigated |
| bv344server | SSH brute force | Low | High | Mitigated |
| AWS Account | Credential theft + crypto mining | Medium | Critical | Mitigated |

## Remaining Gaps
- CloudTrail not enabled — no AWS API audit log
- No hardware MFA on root or admin (virtual only)
- bv344-readonly has no MFA (Prowler false positive confirmed)
- EBS snapshot backups not configured
- No automated alerting for Prowler findings

## Key Takeaway
Threat modeling forces you to think like an attacker before
building systems. By applying STRIDE systematically you can
identify gaps early — when they're cheap to fix — rather
than after a breach when they're expensive. Every mitigation
in this document maps directly to work done in Weeks 1-20.

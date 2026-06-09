# DevSecOps Lab

> My structured 24-week self-study journey into DevSecOps — built from the ground up on real hardware and cloud infrastructure.

---

## 📋 Progress

| Week | Topic | Status |
|:----:|-------|:------:|
| 01 | Linux Fundamentals — users, permissions, processes, shell scripting | ✅ |
| 02 | Linux Server Administration — systemctl, journalctl, cron jobs, monitoring script | ✅ |
| 03 | Docker — images, containers, Dockerfile, Docker Hub | ✅ |
| 04 | AWS — IAM, EC2, security groups, SSM Session Manager | ✅ |
| 05 | Terraform — Infrastructure as Code, EC2 provisioning, tfsec | ✅ |
| 06 | Security Scanning — Trivy image scanning, tfsec Terraform scanning | ✅ |
| 07 | CI/CD — GitHub Actions pipeline, automated build, scan, and push | ✅ |
| 08 | Monitoring — Prometheus, Grafana, Node Exporter, Docker Compose | ✅ |
| 09 | Log Management — Loki, Promtail, Grafana log exploration | ✅ |
| 10 | Secrets Management — HashiCorp Vault, KV secrets engine, policies | ✅ |
| 11 | Network Security — UFW firewall, Docker network hardening, nmap | ✅ |
| 12 | SSL/TLS — Self-signed certificates, Nginx HTTPS reverse proxy | ✅ |
| 13 | IAM Deep Dive — Users, groups, least privilege, Policy Simulator, credential audit | ✅ |
| 14 | Container Security — Non-root user, resource limits, Trivy hard gate | ✅ |
| 15 | Kubernetes — Pods, deployments, services, self-healing, Minikube | ✅ |
| 16 | Kubernetes Security — RBAC, security contexts, non-root pods, capability dropping | ✅ |
| 17 | Infrastructure Security — Lynis auditing, SSH hardening, fail2ban, rkhunter, auditd | ✅ |
| 18 | Incident Response — IOC detection, containment, eradication, incident report | ✅ |
| 19 | Pipeline Security — Gitleaks secret scanning, trivyignore, supply chain hardening | ✅ |
| 20 | CSPM — Prowler AWS audit, EBS encryption, IMDSv2, IAM password policy | ✅ |
| 21 | Threat Modeling — STRIDE framework, attack surface analysis, risk assessment | ✅ |
| 22 | Zero Trust Architecture — Verify explicitly, least privilege, assume breach | ✅ |
| 23 | DevSecOps Capstone — secure-cloud-deployment-pipeline, Tailscale VPN deployment | ✅ |
| 24 | Portfolio & Career Prep — resume, LinkedIn, GitHub cleanup, interview prep | ✅ |

---

## 🏆 Key Achievements

- **Capstone project** — fully automated DevSecOps pipeline deploying a hardened Flask container to a self-hosted Ubuntu Server via Tailscale WireGuard VPN with Gitleaks and Trivy hard gates — [secure-cloud-deployment-pipeline](https://github.com/BV344/secure-cloud-deployment-pipeline)
- **Automated CI/CD security pipeline** — Gitleaks blocks secret commits, Trivy blocks vulnerable images, nothing ships without passing both gates
- **Hardened monitoring stack** — Prometheus, Grafana, and Loki all bound to localhost behind Nginx HTTPS with UFW firewall rules
- **Linux server hardening** — Lynis score improved from 59 → 71/100 with SSH hardening, fail2ban, rkhunter, and auditd
- **AWS CSPM audit** — Prowler found and fixed 10+ findings including EBS encryption, IMDSv2 enforcement, IAM password policy, and MFA gaps
- **Kubernetes security** — Non-root pods with full security contexts, RBAC roles, and capability dropping
- **Container hardening** — Non-root Docker image (`appuser` UID 100) with resource limits running on port 8080
- **STRIDE threat model** — Full attack surface analysis covering CI/CD pipeline, home server, and AWS account
- **Zero Trust implementation** — Verified explicitly, least privilege, and assume breach mapped across all 22 weeks

---

## 🎯 Goals

- [x] Build real Linux sysadmin and server administration skills
- [x] Learn Docker, Kubernetes, CI/CD, AWS, and Terraform
- [x] Integrate security scanning at every layer of the pipeline
- [x] Apply Zero Trust principles across infrastructure
- [x] Build a production-quality capstone project
- [x] Polish resume, LinkedIn, and GitHub for job search
- [ ] Land a DevSecOps role

---

## 🖥️ Environment

| Component | Details |
|-----------|---------|
| **Ubuntu Server** | MacBook Pro 2018 (T2 chip, t2linux kernel), Ubuntu 24.04 LTS, hostname `bv344server`, IP `10.0.0.50` |
| **Ubuntu Desktop** | Ubuntu 24.04 LTS, hostname `LINUX-BV344`, IP `10.0.0.15` |
| **Cloud** | AWS us-east-2 — IAM, EC2, EBS, SSM Session Manager |
| **Version Control** | GitHub — [BV344/devsecops-lab](https://github.com/BV344/devsecops-lab) |
| **Container Registry** | Docker Hub — [bv344/my-webserver](https://hub.docker.com/r/bv344/my-webserver) |

---

## 🛠️ Tools Used

### Infrastructure & Cloud
| Tool | Version | Purpose |
|------|---------|---------|
| Docker | 29.3.1 | Container runtime |
| Docker Compose | Latest | Multi-container orchestration |
| Terraform | v1.14.8 | Infrastructure as Code |
| AWS CLI | v2 | AWS management |
| SSM Session Manager | Latest | Secure EC2 access (no SSH needed) |
| Minikube | v1.38.1 | Local Kubernetes cluster |
| kubectl | v1.36.0 | Kubernetes CLI |

### Security Tools
| Tool | Version | Purpose |
|------|---------|---------|
| Trivy | v0.70.0 | Container image vulnerability scanning |
| tfsec | Latest | Terraform security scanning |
| Gitleaks | v8.18.2 | Secret scanning in git history |
| Lynis | 3.0.9 | Linux security auditing |
| rkhunter | Latest | Rootkit and malware detection |
| fail2ban | Latest | Brute force protection |
| auditd | Latest | System call auditing |
| Prowler | v5.26.1 | AWS Cloud Security Posture Management |

### Monitoring & Observability
| Tool | Version | Purpose |
|------|---------|---------|
| Prometheus | Latest | Metrics collection |
| Grafana | Latest | Dashboards and visualization |
| Node Exporter | Latest | Linux system metrics |
| Loki | Latest | Log aggregation |
| Promtail | Latest | Log shipping agent |

### Other
| Tool | Version | Purpose |
|------|---------|---------|
| GitHub Actions | Latest | CI/CD pipelines |
| HashiCorp Vault | v2.0.0 | Secrets management |
| Nginx | Latest | HTTPS reverse proxy |
| UFW | Latest | Linux firewall |
| Tailscale | Latest | WireGuard VPN for private server access |

---

## 📁 Repository Structure

```
devsecops-lab/
├── .github/
│   └── workflows/
│       └── docker-build-scan.yml   # CI/CD pipeline
├── .gitleaks.toml                  # Secret scanning config
├── week-03/
│   └── docker-projects/
│       └── my-webserver/           # Hardened nginx container
│           ├── Dockerfile
│           ├── index.html
│           └── .trivyignore
├── week-05/
│   └── terraform/
│       └── main.tf                 # AWS infrastructure as code
├── week-15/
│   ├── webserver-deployment.yml    # Kubernetes deployment
│   └── webserver-service.yml       # Kubernetes service
├── week-16/
│   ├── readonly-role.yml           # Kubernetes RBAC role
│   ├── readonly-rolebinding.yml    # Kubernetes RBAC binding
│   └── secure-pod.yml              # Hardened pod spec
├── week-18/
│   └── incident-report.md          # Simulated incident response
├── week-21/
│   └── threat-model.md             # STRIDE threat model
├── week-22/
│   └── zero-trust-analysis.md      # Zero Trust mapping
├── week-23/
│   └── notes/
│       └── week23-notes.md         # Capstone project notes
├── week-24/
│   └── notes/
│       └── week24-notes.md         # Portfolio and career prep notes
└── week-XX/
    └── notes/
        └── weekXX-notes.md         # Weekly learning notes
```

---

## 🚀 Capstone Project

**[secure-cloud-deployment-pipeline](https://github.com/BV344/secure-cloud-deployment-pipeline)** — A fully automated DevSecOps pipeline that containerizes a Flask web application and deploys it to a self-hosted Ubuntu Server with zero public internet exposure. Features Gitleaks secret scanning, Trivy vulnerability scanning, and Tailscale WireGuard VPN for private network deployment via GitHub Actions.

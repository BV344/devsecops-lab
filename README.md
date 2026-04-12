# DevSecOps Lab
My structured 24-week self-study journey into DevSecOps — built from the ground up.

## Structure
Each week has its own folder containing scripts, configs, and notes.

| Week | Topic | Status |
|------|-------|--------|
| Week 01 | Linux Fundamentals — users, permissions, processes, shell scripting | ✅ Complete |
| Week 02 | Linux Server Administration — systemctl, journalctl, cron jobs, monitoring script | ✅ Complete |
| Week 03 | Docker — images, containers, Dockerfile, Docker Hub | ✅ Complete |
| Week 04 | AWS — IAM, EC2, security groups, SSM Session Manager | ✅ Complete |
| Week 05 | Terraform — Infrastructure as Code, EC2 provisioning, tfsec | ✅ Complete |
| Week 06 | Security Scanning — Trivy image scanning, tfsec Terraform scanning | ✅ Complete |
| Week 07 | CI/CD — GitHub Actions pipeline, automated build, scan, and push | ✅ Complete |
| Week 08 | Monitoring — Prometheus, Grafana, Node Exporter, Docker Compose | ✅ Complete |
| Week 09 | | ⏳ Up Next |

## Goals
- Build real Linux sysadmin skills
- Learn Docker, CI/CD, AWS, and Terraform
- Integrate security scanning into pipelines
- Land a DevSecOps role

## Environment
- Ubuntu Server 24.04 (MacBook Pro 2018 with T2 chip, t2linux kernel)
- Ubuntu 24.04 Desktop
- AWS (us-east-2) with IAM, EC2, SSM Session Manager
- GitHub for version control — Docker Hub for container registry

## Tools Used
- Docker 29.3.1 / Docker Compose
- Terraform v1.14.8
- AWS CLI v2 + SSM Session Manager plugin
- Trivy v0.69.3 — container image scanning
- tfsec — Terraform security scanning
- GitHub Actions — CI/CD pipelines
- Prometheus + Grafana + Node Exporter — monitoring stack

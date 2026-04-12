# Week 6 Notes — Security Scanning & Automation

## What is DevSecOps Security Scanning?
Traditional development treated security as an afterthought — build first, 
audit later. DevSecOps "shifts security left" meaning you catch vulnerabilities 
early in development before anything reaches production. Two tools from 
Aqua Security help automate this process.

## Trivy — Container Image Scanning
Trivy scans Docker images layer by layer checking every installed package 
against a database of known vulnerabilities called CVEs 
(Common Vulnerabilities and Exposures). Each CVE has a severity rating:
CRITICAL, HIGH, MEDIUM, LOW, or UNKNOWN.

### Key lesson — base image matters enormously
- `nginx:latest` (Debian-based) → 208 vulnerabilities, 17 HIGH
- `nginx:alpine` (Alpine-based) → 22 vulnerabilities, 3 HIGH

One line change in the Dockerfile reduced vulnerabilities by 89%. 
Alpine Linux is a minimal base image with ~20 packages vs Debian's 150+. 
Fewer packages = smaller attack surface.

### How to prioritize findings
- Focus on CRITICAL and HIGH first
- Check the Fixed Version column — if blank, no fix exists yet
- If a fix exists, update the base image or package
- Document accepted risks rather than ignoring them

### Commands
```bash
trivy image <image-name>          # Scan a Docker image
trivy image --severity HIGH,CRITICAL <image>  # Filter by severity
```

## tfsec — Terraform Security Scanning
tfsec analyzes Terraform configuration files for security misconfigurations 
before you ever apply them to real infrastructure. It catches issues like 
open security groups, unencrypted disks, and missing security settings.

### Findings from our main.tf scan
| Severity | Finding | Action |
|---|---|---|
| CRITICAL | Port 80 open to internet | Accepted risk — intentional for public web server |
| CRITICAL | Egress open to internet | Accepted risk — needed for SSM, Docker Hub, apt |
| HIGH | IMDSv2 token not required | Fixed — added `http_tokens = "required"` |
| HIGH | Root disk not encrypted | Fixed — added `encrypted = true` |
| LOW | Missing rule descriptions | Fixed — added description fields |

### Accepted risks should be documented in code
```hcl
# tfsec:ignore:aws-ec2-no-public-ingress-sgr
# Reason: Public web server — HTTP access from internet is intentional
```

### Commands
```bash
tfsec /path/to/terraform/   # Scan a Terraform directory
```

## The Security Scanning Workflow

1. Write Code
2. Scan with Trivy/tfsec
3. Fix Hight & Critical findings
4. Document Accept risks
5. Commit
6. Deploy

## Note on tfsec
tfsec is being merged into Trivy by Aqua Security. 
Going forward `trivy config` will replace tfsec for Terraform scanning. 
Both tools work the same way for now.

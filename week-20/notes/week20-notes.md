# Week 20 Notes — Cloud Security Posture Management (CSPM)

## What is CSPM?
Cloud Security Posture Management is the practice of continuously 
monitoring your cloud infrastructure for security misconfigurations. 
Just like you can misconfigure a Linux server, you can misconfigure 
AWS services — leaving S3 buckets public, skipping encryption, 
not enforcing MFA, or using overly permissive IAM policies.

CSPM tools automate the audit process, scanning hundreds of checks 
against security benchmarks like CIS, SOC2, PCI-DSS, and HIPAA, 
then reporting what passes and what fails.

## Prowler
Prowler is an open source CSPM tool for AWS (and other clouds). 
It's essentially Lynis for AWS — just like Lynis audited our Linux 
server against security best practices and gave us a hardening score, 
Prowler audits our AWS account against industry benchmarks and 
produces a detailed PASS/FAIL report.

Installed via:
```bash
pip3 install prowler --break-system-packages
prowler aws --service iam ec2 --region us-east-2
```

## Initial Scan Results
- **118 checks** completed in 1:40
- **82 passed** (72.57%) ✅
- **31 failed** (27.43%) ❌

**EC2 failures:** 11 (0 Critical, 6 High, 4 Medium, 1 Low)
**IAM failures:** 20 (2 Critical, 6 High, 8 Medium, 4 Low)

## What We Fixed

### IAM Password Policy
AWS had no password policy set at all — any password length and 
complexity was accepted. Fixed by setting:
- Minimum length: 14 characters
- Require uppercase, lowercase, numbers, and symbols
- Password expiration: 90 days
- Prevent reuse of last 24 passwords

### MFA for bv344-readonly
The readonly user had a console password but no MFA — a stolen 
password would give full read access to EC2. Fixed by assigning 
a virtual MFA device via Microsoft Authenticator.

### EBS Default Encryption
EBS (Elastic Block Store) is the virtual hard drive attached to 
EC2 instances. Without encryption, data sits on disk in plain text. 
If someone physically accessed the drive in the AWS data center they 
could read everything.

Enabling default encryption means all new EBS volumes are 
automatically encrypted using AWS KMS — no application changes 
needed, no performance impact, and it satisfies compliance 
requirements like HIPAA and PCI-DSS.

### IMDSv2 at Account Level
Every EC2 instance has an internal metadata endpoint at 
`http://169.254.169.254` that returns IAM credentials, region, 
instance ID, and other sensitive data.

**IMDSv1** allowed any process on the instance to query this 
endpoint without authentication — including malware. This was 
exploited in the 2019 Capital One breach via an SSRF attack.

**IMDSv2** requires a session token before querying the endpoint, 
making SSRF attacks much harder. We enforced this at the account 
level so all future EC2 instances require IMDSv2 by default.

## Accepted Risks (Not Fixed)
Some findings were accepted as known risks for our lab:

- **AdministratorAccess policy** — required for our admin group, 
  flagged by Prowler but intentional
- **Hardware MFA for root** — requires a physical hardware token 
  (~$50), virtual MFA is sufficient for a home lab
- **Default VPC Network ACL** — AWS default, not worth changing 
  for a lab environment

## False Positives in Security Tools
After assigning MFA to `bv344-readonly`, Prowler continued to flag 
it as having MFA disabled even though:
- The AWS console showed the MFA device assigned
- Logging in as `bv344-readonly` prompted for MFA code successfully
- `aws iam list-mfa-devices --user-name bv344-readonly` confirmed 
  the device was active

This was a Prowler caching issue — it captured IAM state at scan 
start and didn't reflect changes made during the scan window.

**Key lesson:** Security tool findings must always be verified 
against the actual system before acting on them. Never blindly 
trust a scanner — always validate with the source of truth, 
which in this case was the AWS CLI and the console itself.

## Key Commands
```bash
prowler --version                          # Check version
prowler aws --service iam ec2             # Scan IAM and EC2
prowler aws --check <check_id>            # Run specific check
aws iam list-mfa-devices --user-name <u>  # Verify MFA status
```

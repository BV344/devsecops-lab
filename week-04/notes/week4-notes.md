# Week 4 Notes — AWS & Cloud Deployment

## Creating an AWS Account
- Created a personal AWS account with a free tier plan
- Enabled MFA on the root account immediately — root should never 
  be used for day to day work
- Set up a billing alert at $5 via AWS Budgets — 
  prevents surprise charges
- Created an IAM admin user `bv344-admin` with AdministratorAccess 
  policy — all work done as this user, not root

## Key Concepts
**IAM (Identity and Access Management)** — AWS's system for controlling 
who can do what. Users, roles, and policies are the building blocks.
- **User** — a person or service that interacts with AWS (e.g. bv344-admin)
- **Role** — an identity attached to an AWS resource like EC2 
  (e.g. ec2-ssm-role)
- **Policy** — a document that defines what actions are allowed 
  (e.g. AmazonSSMManagedInstanceCore)

**EC2 (Elastic Compute Cloud)** — a virtual machine running in AWS's 
data centers. Same concept as bv344server at home, just hosted in the cloud.
- Launched a t3.micro instance (free tier eligible) running Ubuntu 24.04
- Security groups act as a firewall — controlling inbound and outbound 
  traffic by port and source IP

**Reboot vs Stop & Start**
- Reboot: OS restarts, stays on same hardware, keeps same public IP
- Stop & Start: fully powers off, may move to different hardware, 
  public IP changes unless an Elastic IP is attached

## Connecting to EC2 — SSM Session Manager
- Port 22 (SSH) was blocked by ISP — a common issue on residential networks
- SSM Session Manager bypasses port 22 entirely, connecting over 
  port 443 (HTTPS) through AWS's internal network
- Industry standard for secure EC2 access — no open inbound ports, 
  full audit logging, no SSH keys to manage
- Required setup:
  - Attach IAM role with `AmazonSSMManagedInstanceCore` policy to instance
  - Install AWS CLI on local machine
  - Install SSM Session Manager plugin
  - Connect with: `aws ssm start-session --target <instance-id>`

## Deploying Docker on EC2
- Installed Docker on the EC2 instance via SSM terminal
- Pulled `bv344/my-webserver:v1` from Docker Hub
- Ran container on port 80 (standard HTTP port for public web traffic)
- Opened port 80 in the security group for IPv4 and IPv6
- Webpage was publicly accessible at `http://18.223.119.18` 
  from anywhere in the world

## Full Deployment Pipeline
Local HTML → Dockerfile → Docker image → Docker Hub → 
EC2 instance → Running container → Public internet

## Cost Management Rules
- Always STOP instances when done — compute charges only apply 
  to running instances
- Stopped instances still accrue small EBS storage charges — 
  free tier covers 30GB
- TERMINATE instances you no longer need at all to avoid 
  any storage charges
- Billing alert at $5 provides early warning before 
  real charges accumulate

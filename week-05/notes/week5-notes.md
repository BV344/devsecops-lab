# Week 5 Notes — Terraform & Infrastructure as Code

## What is Terraform?
Terraform is a CLI tool that enables Infrastructure as Code (IaC). 
Instead of manually clicking through the AWS console to create servers, 
you describe your infrastructure in code and Terraform builds it automatically.

This is extremely powerful because you can:
- Launch multiple servers across different regions or continents instantly
- Reproduce identical environments (dev, staging, production) from the same code
- Tear down everything cleanly with one command — no hunting around the console
- Track infrastructure changes in Git just like application code

## Core Concepts

**Provider** — a plugin that teaches Terraform how to talk to a specific 
platform (AWS, Google Cloud, Azure, Docker, etc). Declared in the 
`terraform {}` block and downloaded automatically by `terraform init`.

**Resource** — a piece of infrastructure to create. 
Each resource has a type (`aws_instance`) and a local name (`bv344_server`).
AWS never sees the local name — only tags do.

**State file (`terraform.tfstate`)** — Terraform's memory. 
Tracks everything it has created so it knows what to change or destroy. 
Never delete or edit this manually.

**AMI (Amazon Machine Image)** — the OS blueprint for an EC2 instance. 
Like a Docker image but for virtual machines. 
AMI IDs are region-specific — the same OS has a different ID in each region.

## Core Commands

| Command | What it does |
|---|---|
| `terraform init` | Downloads required providers |
| `terraform plan` | Preview changes without applying them |
| `terraform apply` | Create/update infrastructure |
| `terraform destroy` | Tear down everything Terraform created |

## What We Built
Created 5 resources entirely from code:
- `aws_instance` — EC2 t3.micro running Ubuntu 24.04
- `aws_security_group` — allowed HTTP inbound on port 80
- `aws_iam_role` — identity for the EC2 instance
- `aws_iam_role_policy_attachment` — attached SSM policy to the role
- `aws_iam_instance_profile` — linked the role to the instance

Connected via SSM Session Manager, deployed `bv344/my-webserver:v1` 
Docker container, and confirmed the webpage was publicly accessible 
from a Verizon cellular network on an iPhone.

## .gitignore for Terraform
These files should never be committed to Git:
- `.terraform/` — downloaded provider plugins, large and machine-specific
- `terraform.tfstate` — contains sensitive infrastructure details and IDs
- `terraform.tfstate.backup` — backup of previous state
- `*.tfvars` — often contains secrets like API keys

## Key Insight
What took 30+ minutes of manual clicking in Week 4 was reproduced 
in seconds with 50 lines of Terraform code. That's the power of IaC.



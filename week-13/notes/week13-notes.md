# Week 13 Notes — Identity & Access Management (IAM) Deep Dive

## What is IAM?
IAM (Identity and Access Management) is AWS's system for controlling 
who can do what inside your AWS account. It covers users, groups, 
roles, and policies — the building blocks of cloud security.

## IAM Users
An IAM user is an identity that represents a person or application 
interacting with AWS. Each user has their own credentials 
(password, access keys) and permissions.

**Best practice:** Never use the root account for day-to-day work. 
Always use IAM users with only the permissions they need.

## IAM Groups
A group is a collection of users that share the same permissions. 
Instead of attaching policies directly to individual users, you 
attach policies to groups and add users to groups.

**Why groups matter:**
- When someone joins → add them to the right group, they instantly 
  get correct permissions
- When someone leaves → remove them from the group, access revoked
- Change a policy once → affects all users in the group automatically
- Much easier to audit and manage at scale

**What we fixed this week:**
- `bv344-admin` had `AdministratorAccess` attached directly to the user
- Created `devsecops-admin` group with `AdministratorAccess`
- Added `bv344-admin` to the group and removed the direct attachment
- This is the correct production pattern

## Least Privilege
Every user should have only the minimum permissions needed to do 
their job — nothing more.

**Demonstrated this week:**
- Created `bv344-readonly` user in `readonly-users` group
- Group only has `AmazonEC2ReadOnlyAccess`
- `DescribeInstances` → allowed (can view)
- `RunInstances` → denied (can't launch)
- `TerminateInstances` → denied (can't delete)
- If `bv344-readonly` were compromised, attacker can only view — 
  cannot create, modify, or destroy anything

## IAM Policy Simulator
A free AWS tool at `policysim.aws.amazon.com` that lets you test 
what a user can and cannot do without actually performing the action.

**Why it's critical:**
- Verify permissions before giving someone access
- Audit existing users for over-provisioning
- Test policy changes before applying them
- No risk — simulation only, nothing actually happens

**"Implicitly denied"** means the action isn't mentioned in any 
policy — in AWS if something isn't explicitly allowed, it's denied 
by default. This is the secure default.

## Credential Report
A CSV report downloadable from IAM that audits every user's 
security hygiene:
- Password last used and last changed
- MFA status
- Access key status and last rotation
- Last service accessed

**Findings from our audit this week:**
- Root used today — should be used rarely ⚠️
- `bv344-admin` had no MFA — fixed immediately 🔴→✅
- `bv344-readonly` has no access keys — correct ✅

## MFA — Why It Matters for Admin Users
An admin user with no MFA is a critical security risk. If the 
password is compromised the attacker has full AWS access. With MFA 
they also need your phone — dramatically reducing the risk.

**Rule:** Every IAM user with console access should have MFA. 
Admin users absolutely must have MFA.

## IAM Structure After Week 13
```
root account (MFA ✅, used rarely)
├── devsecops-admin group (AdministratorAccess)
│   └── bv344-admin (MFA ✅)
└── readonly-users group (AmazonEC2ReadOnlyAccess)
    └── bv344-readonly
```

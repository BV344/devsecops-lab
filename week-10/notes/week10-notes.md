# Week 10 Notes — Secrets Management with HashiCorp Vault

## Why Secrets Management?
Hardcoding secrets like passwords, API keys, and certificates directly 
in scripts or config files is a critical security risk. If that code 
gets committed to GitHub or someone gains access to the server, 
all your secrets are compromised instantly.

Secrets should always be:
- Encrypted at rest
- Accessed programmatically at runtime
- Audited — who accessed what and when
- Rotated regularly without touching code

## How Vault Works
Vault is a secrets management tool by HashiCorp. It stores secrets 
encrypted on disk and only decrypts them in memory when unsealed.

**Shamir's Secret Sharing** — when initializing Vault you choose:
- **Key shares** — how many unseal key pieces to generate
- **Threshold** — how many pieces are required to unseal

Example: 5 shares, threshold of 3 means 3 of 5 key holders must 
provide their piece to unlock Vault. No single person can unseal it alone.

Important distinction:
- **Unseal key** — only unlocks Vault, does not grant access to secrets
- **Root token** — admin credential, used once to set up Vault then revoked

## Sealing and Unsealing
Vault always starts in a **sealed** state — everything is encrypted 
and no secrets can be read or written. It must be unsealed before 
any applications can use it.

Vault gets sealed when:
- Server reboots
- Container restarts
- Manually sealed during an emergency
- Crash recovery

To unseal you provide the required number of unseal key shares.

## KV Secrets Engine
The Key-Value (KV) secrets engine is the most common way to store 
secrets in Vault. Secrets are stored as key-value pairs at a path:

```bash
# Store a secret
vault kv put secret/myapp db_password="YOUR_PASSWORD_HERE" api_key="abc123"

# Retrieve a secret
vault kv get secret/myapp

# Retrieve a single field (for use in scripts)
vault kv get -field=db_password secret/myapp
```

## Versioning
Every time a secret is updated Vault creates a new version automatically. 
Previous versions are retained and can be retrieved:

```bash
vault kv get -version=1 secret/myapp  # previous version
vault kv get secret/myapp              # current version
```

This enables instant rollback if a password rotation breaks something 
and provides a complete history of every secret change.

## Policies and Least Privilege
Instead of giving every application the root token, you create policies 
that limit access to only what each app needs:

```hcl
path "secret/data/myapp" {
  capabilities = ["read"]
}
```

This token can only read from `secret/myapp` — nothing else. 
It cannot write, delete, or access any other secrets. 
Demonstrated this week — read succeeded, write returned 403 permission denied.

## Auto-Unseal with AWS KMS
Manual unsealing is operationally painful — if Vault restarts at 3am 
everything breaks until a human manually unseals it.

Auto-unseal solves this by storing the unseal key in AWS KMS instead 
of with a human. When Vault starts it automatically calls AWS KMS, 
proves its identity via IAM role, retrieves the key, and unseals itself 
— no human intervention needed.

Auto-unseal triggers on ANY sealed state — reboot, container restart, 
crash, or manual seal.

## Key Commands
```bash
vault status                           # Check sealed/unsealed state
vault kv put secret/path key=value     # Store a secret
vault kv get secret/path               # Retrieve a secret
vault kv get -field=key secret/path    # Retrieve single field
vault kv get -version=N secret/path    # Retrieve specific version
vault policy write name - <<EOF        # Create a policy
vault policy list                      # List all policies
vault token create -policy=name        # Create a restricted token
```

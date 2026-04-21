# Week 11 Notes — Network Security & Firewalls

## UFW (Uncomplicated Firewall)
UFW is Ubuntu's built-in firewall tool. It controls which network 
traffic is allowed into and out of your server by port and source IP. 
Without a firewall every open port on your server is reachable by 
anyone on the network — including attackers doing reconnaissance.

## Default Deny Policy
When UFW is enabled it sets:
- **Incoming: deny** — all inbound traffic blocked by default
- **Outgoing: allow** — server can still make outbound connections
- **Routed: deny** — no traffic forwarding

This means you explicitly whitelist only what you need. Everything 
else is silently dropped. This is the correct secure default — 
least privilege applied at the network level.

## Rules We Set Up

| Port | Allowed From | Reason |
|---|---|---|
| 22 (SSH) | Anywhere | Remote access from any machine |
| 3000 (Grafana) | 10.0.0.0/24 | Local network only |
| 9090 (Prometheus) | 10.0.0.0/24 | Local network only |
| 9100 (Node Exporter) | 10.0.0.0/24 | Local network only |
| 8200 (Vault) | 10.0.0.0/24 | Local network only — secrets must never be public |

Outbound traffic is allowed by default so the server can still reach 
Docker Hub, apt repositories, AWS SSM, and other external services.

## nmap — Network Scanner
nmap is a network scanning tool that shows every open port on a target 
machine — exactly what an attacker would see during reconnaissance. 
Running it against your own server is a good security habit to verify 
your firewall rules are working correctly.

```bash
nmap 10.0.0.50          # Standard scan
nmap -Pn 10.0.0.50      # Skip ping check, scan anyway
```

## Port States

| State | Meaning |
|---|---|
| Open | Port is reachable and a service is listening |
| Closed | Port is reachable but nothing is listening |
| Filtered | Firewall is blocking — no response at all |

Before UFW: 5 open ports, 995 closed
After UFW: 5 open ports (from local network), 995 **filtered**

The change from `closed` to `filtered` confirms UFW is actively 
blocking connection attempts rather than just rejecting them.

## CRITICAL — Add SSH Rule BEFORE Enabling UFW
Always add the SSH rule before enabling UFW:

```bash
sudo ufw allow 22/tcp   # Do this FIRST
sudo ufw enable         # Then enable
```

If you enable UFW without allowing SSH first you lock yourself out 
of your own server — you'd need physical access to fix it.

## ICMP Ping Blocking
UFW's default deny policy blocks ICMP ping packets. This makes your 
server invisible to basic network scans — nmap assumes the host is 
down and skips it entirely.

This is a useful security technique called **ping blocking**:
- Attackers scanning `nmap 10.0.0.0/24` skip your server entirely
- Professional penetration testers use `nmap -Pn` to bypass this
- Real security means not relying on ping blocking alone — 
  proper firewall rules are the real protection

## Key Commands
```bash
sudo ufw status verbose              # Show all rules
sudo ufw allow 22/tcp                # Allow SSH
sudo ufw allow from 10.0.0.0/24 to any port 3000  # Local network only
sudo ufw enable                      # Enable firewall
sudo ufw disable                     # Disable firewall
sudo ufw delete allow 22/tcp         # Remove a rule
nmap 10.0.0.50                       # Scan a host
nmap -Pn 10.0.0.50                   # Scan without ping
```

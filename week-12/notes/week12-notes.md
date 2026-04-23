# Week 12 Notes — SSL/TLS & HTTPS with Nginx

## What is SSL/TLS?
SSL/TLS encrypts network traffic so that anyone who intercepts it 
cannot read the contents. It's the difference between HTTP 
(plain text) and HTTPS (encrypted).

Every service we built previously communicated over HTTP — 
Grafana passwords, Vault tokens, Prometheus data — all sent 
in plain text across the network. Week 12 fixes that.

## Nginx as a Reverse Proxy
Nginx sits in front of your services and handles all SSL/TLS 
encryption. This is called **SSL termination** — Nginx decrypts 
incoming traffic and forwards it to the internal service as plain HTTP.

1. Browser(HTTPS)
2. Nginx (decrypts)
3. Grafana/Vault (plain HTTP internally)

This means your internal services don't need to handle SSL themselves — 
Nginx handles it for all of them.

## Self-Signed Certificates
Generated with OpenSSL — free and instant but not trusted by browsers 
by default. Browsers show a security warning that you click through.

In production you'd use **Let's Encrypt** (free, trusted, requires 
a public domain) or a company-purchased certificate. The underlying 
concepts are identical.

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt \
  -subj "/C=US/ST=California/L=SonomaCounty/O=bv344lab/CN=10.0.0.50"
```

Key flags:
- `-x509` — self-signed certificate
- `-nodes` — no passphrase so Nginx can read it automatically
- `-days 365` — valid for 1 year
- `-newkey rsa:2048` — 2048-bit RSA key pair
- `CN=10.0.0.50` — Common Name, what the cert is valid for

## HTTP → HTTPS Redirect
The second Nginx server block redirects all HTTP traffic to HTTPS 
automatically — users never need to type `https://` manually:

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

`301` is a permanent redirect status code — browsers follow it automatically.

## Docker + UFW Quirk
UFW alone cannot protect Docker-exposed ports because Docker writes 
directly to iptables, bypassing UFW rules entirely.

The correct fix is binding containers to `127.0.0.1` (localhost) 
instead of `0.0.0.0` (all interfaces):

```yaml
# Before — accessible from network
ports:
  - "3000:3000"

# After — localhost only, hidden from network
ports:
  - "127.0.0.1:3000:3000"
```

This prevents Docker from exposing the port externally regardless 
of UFW rules.

## Final Attack Surface After Week 12

| Port | State | Service |
|---|---|---|
| 22 | open | SSH |
| 80 | open | HTTP → redirects to HTTPS |
| 443 | open | HTTPS — Grafana via Nginx |
| 8201 | open | HTTPS — Vault via Nginx |
| 3000 | hidden | Grafana — localhost only |
| 8200 | closed | Vault — localhost only |
| 9090 | closed | Prometheus — localhost only |
| 9100 | closed | Node Exporter — localhost only |

Every service is now either encrypted or completely hidden from 
the network. This is a properly hardened server.

## Key Commands
```bash
# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt

# Test Nginx config before restarting
sudo nginx -t

# Enable a site
sudo ln -s /etc/nginx/sites-available/name /etc/nginx/sites-enabled/

# Restart Nginx
sudo systemctl restart nginx
```

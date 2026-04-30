# Week 14 Notes — Container Security

## Why Running Containers as Root is Dangerous
By default Docker containers run as root. If an attacker exploits 
a vulnerability in your application (like Nginx) and breaks out of 
the container, they land on your host system as root — with full 
control of your server. This is called a container escape.

## Container Escape
A container escape is when an attacker exploits a vulnerability to 
break out of the container's isolated environment and gain access 
to the host system. Running as a non-root user means even if they 
escape, they land as an unprivileged system user with no shell, 
no home directory, and no sudo access — dramatically limiting 
what they can do.

## Non-Root User Fix
Created a system user and group in the Dockerfile:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

The `-S` flag creates a system account — no login shell, 
no password, no home directory. Purely for running services.

Verified with:
```bash
docker exec my-webserver whoami  # returns: appuser
```

## Resource Limits
Containers have no resource limits by default — a buggy app or 
DDoS attack could consume 100% of your server's CPU and memory, 
taking down everything else running on it.

Fixed with:
```bash
docker run --memory="128m" --cpus="0.5" ...
```

- `--memory="128m"` — hard cap at 128MB RAM
- `--cpus="0.5"` — maximum half a CPU core

Verified with `docker stats` showing `5.96MiB / 128MiB`.

## Why Ports Below 1024 Require Root
On Linux, ports 0-1023 are called **privileged ports** or 
**well-known ports**. The OS restricts binding to these ports 
to root only — this is a security feature dating back to Unix. 
The idea is that if a service is on port 80 or 443 you can 
trust it's run by a privileged administrator, not a random user.

Since our container now runs as non-root, Nginx can't bind to 
port 80. The fix is to configure Nginx to listen on port 8080 
instead — a non-privileged port any user can bind to.

## Trivy as a Hard Gate
Changed `exit-code` from `'0'` to `'1'` in the GitHub Actions 
workflow:

```yaml
exit-code: '1'
severity: CRITICAL,HIGH
```

This means if Trivy finds any CRITICAL or HIGH vulnerabilities 
the pipeline fails and the image never gets pushed to Docker Hub. 
Security is enforced automatically on every commit — no human 
review required.

## Docker Blobs
A blob is a layer in a Docker image. Each instruction in a 
Dockerfile creates a new layer (blob). When pushing to Docker Hub:

- `Pushed` — this layer was uploaded fresh
- `Mounted from library/nginx` — this layer already exists on 
  Docker Hub from the base nginx image, reused instead of 
  re-uploading. This is why pushes are fast when sharing a base image.

## Final Hardened Container
- ✅ Runs as `appuser` — not root
- ✅ Limited to 128MB RAM
- ✅ Limited to 0.5 CPUs
- ✅ Listens on port 8080 — non-privileged
- ✅ Trivy hard gate in CI/CD pipeline

# Week 3 Notes — Docker Fundamentals

## Images vs Containers
- **Image** — the blueprint, like a Class in OOP. Read-only and reusable.
- **Container** — a running instance of an image, like an Object created from a Class.
- One image can spawn many containers simultaneously.

## Key Commands
- `docker ps` — shows running containers
- `docker ps -a` — shows all containers including stopped ones
- `docker images` — shows locally stored images
- `docker stats --no-stream` — snapshot of CPU, memory, disk, and network usage per container
- `docker logs <name>` — view output from a container, equivalent to journalctl for services

## Port Mapping
Format is always `host:container` (e.g. `-p 8080:80`)
- The **container port** is internal — isolated inside the container
- The **host port** is what your actual machine exposes to the network
- Two containers can both internally use port 80, but must be mapped to different host ports (8080, 8081, etc.)
- This enables running multiple instances of the same app on one machine — useful for dev/prod isolation, blue/green deployments, and testing

## Docker Group / Permissions
- Docker runs as root through a daemon listening on `/var/run/docker.sock`
- By default only root can talk to it — running docker commands as a regular user gives a permission denied error
- Fix: add your user to the `docker` group with `sudo usermod -aG docker $USER`
- The `-a` flag is critical — it appends the group without removing your existing ones
- Run `newgrp docker` to apply immediately, or log out and back in for a clean reload

## Dockerfile
- A recipe that tells Docker how to build your image
- `FROM` — base image to build on top of
- `LABEL` — metadata like maintainer name
- `COPY` — copies files from your machine into the image

## Docker Hub
- Public registry for Docker images, like GitHub but for containers
- `docker login` — authenticate from the terminal
- `docker push <image>` — upload your image (like git push)
- `docker pull <image>` — download an image (like git pull)
- Public images can be pulled without authentication
- Credentials are stored in `~/.docker/config.json` — unencrypted by default, use a credential helper in production

## Deployment Workflow
Built image on Ubuntu desktop → Pushed to Docker Hub → Pulled on bv344server → Running in production

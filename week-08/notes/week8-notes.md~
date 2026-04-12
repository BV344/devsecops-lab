# Week 8 Notes — Monitoring & Observability

## Monitoring vs Observability
- **Monitoring** — watching known metrics in real time (CPU, RAM, disk, network)
- **Observability** — the ability to understand the internal state of a system 
  from its external outputs. Monitoring is a subset of observability.
- Key principle: "You can't secure what you can't see."

## The Monitoring Stack
All three tools run together in Docker containers on bv344server 
using Docker Compose.

1. bv344server hardware
2. Node Exporter (read system stats, exposes on port 9100
3. Prometheus (scrapes port 9100 every 15s, stores the data on port 9090)
4. Grafana (reads from Prometheus, displays dashboards on port 3000)

## Node Exporter
Runs on the server and reads system-level metrics — CPU usage, RAM, 
disk I/O, network traffic, etc. Linux doesn't natively speak 
Prometheus's format so Node Exporter acts as a translator, 
exposing metrics at `http://node-exporter:9100/metrics`.

## Prometheus
Scrapes metrics from targets (Node Exporter, itself) every 15 seconds 
and stores them as time-series data. Configured via `prometheus.yml` 
which defines what to scrape and how often.
- Web UI available at port 9090
- Status → Targets shows all scrape targets and their health

## Grafana
A visualization platform that connects to Prometheus as a data source 
and displays metrics in dashboards. We imported community dashboard 
ID `1860` (Node Exporter Full) which shows:
- CPU usage and load
- Memory usage (total, used, cache, free)
- Network traffic (Rx/Tx)
- Disk space usage
- Available at port 3000

## Docker Compose
Defines and runs multiple Docker containers together from a single 
`docker-compose.yml` file. Instead of running 3 separate `docker run` 
commands with long flags, one command starts everything:
- `docker compose up -d` — start all containers in background
- `docker compose ps` — check status of all containers
- `docker compose down` — stop and remove all containers

## Volume Types
Two types of volumes used in Docker Compose:

**Bind Mount** — maps a file from your host machine into the container:
```
./prometheus.yml:/etc/prometheus/prometheus.yml
```
Format: `host_path:container_path`
Used for config files you write and control.

**Named Volume** — Docker-managed persistent storage:
```
prometheus_data:/prometheus
```
Format: `volume_name:container_path`
Used for data that must survive container restarts. 
Declared at the bottom of docker-compose.yml under `volumes:`.

## Key Insight
Running a full production-grade monitoring stack used to require 
significant infrastructure setup. With Docker Compose it's a single 
YAML file and one command — `docker compose up -d`.

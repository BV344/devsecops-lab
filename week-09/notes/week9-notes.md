# Week 9 Notes — Log Management & Centralized Logging

## What is Log Management?
Metrics tell you **what** is happening on your server (CPU at 80%, 
memory at 6%). Logs tell you **why** — the actual text output of 
every service, error, and event. Together they give you full 
observability over your infrastructure.

## Loki
Loki is a log aggregation tool by Grafana Labs. It stores and indexes 
logs from multiple sources in a central location. Unlike traditional 
log tools that index the full content of every log line, Loki only 
indexes the **labels** (metadata) — making it much more efficient 
and cheaper to run.

- Listens on port 3100
- Stores logs in chunks on disk via named volume `loki_data`
- Configured via `loki-config.yml`

## Promtail
Promtail is Loki's log collector. It runs alongside your server, 
watches log files, and ships new log lines to Loki in real time.

- Watches `/var/log/*log` on the server
- Labels all logs with `job=varlogs`
- Ships logs to `http://loki:3100/loki/api/v1/push`
- Uses a positions file to track how far it has read each log file
  so it doesn't re-send on restart
- Configured via `promtail-config.yml`

## Prometheus vs Loki

| | Prometheus | Loki |
|---|---|---|
| What it stores | Metrics (numbers over time) | Logs (text events) |
| What it scrapes | Node Exporter endpoints | Log files via Promtail |
| Query language | PromQL | LogQL |
| Use case | CPU/RAM/disk/network usage | Errors, events, audit trails |

## LogQL
LogQL is Loki's query language used in Grafana's Explore view. 
Basic queries use label filters:
```
{job="varlogs"}
```
You can filter further by searching for specific text:
```
{job="varlogs"} |= "error"
{job="varlogs"} |= "monitor.sh"
```

## Full Observability Stack
bv344server

#### Resource Usage
1. Node Exporter
2. Prometheus
3. Grafana(metrics)

#### Logging
1. Promtail
2. Loki
3. Grafana(logs)

One Grafana instance gives both metrics AND logs from the server.
- See resource usage trends over time
- Search logs for specific errors or events
- Correlate a CPU spike with a log event that caused it
- Much easier to troubleshoot issues — no more SSHing in just to 
  read log files

## Bug Fixed This Week
Promtail was configured to push to `loki:3000` (Grafana's port) 
instead of `loki:3100` (Loki's port). Fixed by correcting the URL 
in `promtail-config.yml` — a good reminder to always verify port 
numbers in config files.

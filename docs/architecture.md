# AIOps Architecture

## Overview

This platform is built as a monitoring and intelligent incident response stack.

### Components

- **Node.js App** and **Python App**: emit metrics and JSON logs.
- **Prometheus**: scrapes metrics endpoints and evaluates alert rules.
- **Grafana**: displays dashboards and routes alerts.
- **Loki**: stores application logs and enables log queries.
- **Promtail**: collects logs from app containers and system files.
- **Alertmanager**: receives alerts and forwards them to the AI engine.
- **AI Engine**: enriches alert payloads with AI reasoning and sends Slack/Telegram notifications.

### Data flow

1. Apps produce metrics and logs.
2. Prometheus scrapes `/metrics`.
3. Promtail pushes log events to Loki.
4. Grafana displays metrics/logs.
5. Alertmanager routes alerts to AI engine.
6. AI engine analyzes, then notifies Slack/Telegram.

## Network diagram

```mermaid
flowchart TB
  subgraph vm2[App VM]
    A[Node App]
    B[Python App]
    C[Promtail]
  end
  subgraph vm1[Monitoring VM]
    D[Prometheus]
    E[Grafana]
    F[Loki]
    G[Alertmanager]
    H[AI Engine]
  end
  A -->|metrics| D
  B -->|metrics| D
  C -->|logs| F
  D -->|alerts| G
  G -->|webhook| H
  H -->|notifications| I[Slack/Telegram]
  D --> E
  F --> E
```

# Enterprise AIOps Project

A complete AIOps stack on Rocky Linux VMs using Docker Compose, Prometheus, Grafana, Loki, Alertmanager, and an AI incident analysis engine.

## What is included

- Metrics collection from Node.js and Python applications
- Centralized log collection with Loki and Promtail
- Grafana dashboards and alerting
- Alertmanager webhook to an AI analysis service
- Slack and Telegram intelligent notifications
- Docker Compose deployment
- CI/CD starter workflow

## Folder structure

- `docker-compose.yml`
- `monitoring/`
  - `prometheus/`
  - `loki/`
  - `promtail/`
  - `grafana/`
  - `alertmanager/`
- `app/`
  - `node-app/`
  - `python-app/`
- `ai-engine/`
- `.github/workflows/`

## Setup guide

1. Copy `.env.example` to `.env` and set your Slack/Telegram values.
2. Start Docker Compose:
   ```bash
   docker compose up -d --build
   ```
3. Open services:
   - Grafana: `http://<vm1-ip>:3000`
   - Prometheus: `http://<vm1-ip>:9090`
   - Loki: `http://<vm1-ip>:3100`
   - Alertmanager: `http://<vm1-ip>:9093`
   - Node App: `http://<vm2-ip>:4000`
   - Python App: `http://<vm2-ip>:5000`
   - AI Engine: `http://<vm1-ip>:8080`

## VM roles

- **VM1**: Prometheus, Grafana, Loki, Alertmanager, AI Engine
- **VM2**: Node.js/Python apps and Promtail log collection

## Next steps

- Configure Grafana dashboards and enable provisioning
- Validate Prometheus scraping on `http://<vm1-ip>:9090/targets`
- Use Slack/Telegram for real alerts
- Extend the AI engine with LLM prompts and root cause analysis

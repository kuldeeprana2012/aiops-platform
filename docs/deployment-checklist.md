# AIOps Setup Checklist

Use this checklist to ensure proper setup of your AIOps monitoring stack.

## Pre-Deployment

- [ ] Two Rocky Linux 10 VMs ready
- [ ] Network connectivity between VMs confirmed
- [ ] Firewall access from your workstation to VMs confirmed
- [ ] Git repository cloned to both VMs
- [ ] Admin credentials for Slack/Telegram collected
- [ ] Ollama API endpoint determined (local or remote)

## VM1 Setup (Monitoring)

### System Preparation
- [ ] Run `scripts/setup-vm1.sh` OR follow manual steps
- [ ] Verify Docker installation: `docker --version`
- [ ] Verify Docker Compose: `docker-compose --version`
- [ ] Verify firewall: `sudo firewall-cmd --list-all`

### Environment Configuration
- [ ] Copy `.env.example` to `.env`
- [ ] Set `SLACK_WEBHOOK_URL` (get from Slack app settings)
- [ ] Set `TELEGRAM_TOKEN` (from BotFather)
- [ ] Set `TELEGRAM_CHAT_ID` (forward message from bot to get ID)
- [ ] Set `OLLAMA_URL` (e.g., `http://<VM1_IP>:11434`)

### Service Startup
- [ ] Start services: `docker compose up -d --build prometheus grafana loki alertmanager ai-engine`
- [ ] Verify services running: `docker ps`
- [ ] Check logs: `docker compose logs -f` (no errors)

### Service Health
- [ ] Prometheus accessible: `curl http://localhost:9090/-/healthy`
- [ ] Grafana accessible: `curl http://localhost:3000/api/health`
- [ ] Loki accessible: `curl http://localhost:3100/ready`
- [ ] Alertmanager accessible: `curl http://localhost:9093/-/healthy`
- [ ] AI Engine accessible: `curl http://localhost:8080/health`

### Prometheus Configuration
- [ ] Update targets in `monitoring/prometheus/prometheus.yml` with VM2 IP
- [ ] Reload Prometheus: `curl -X POST http://localhost:9090/-/reload`
- [ ] Check scrape targets: `http://localhost:9090/targets`
- [ ] Verify all jobs are `UP`

## VM2 Setup (Applications)

### System Preparation
- [ ] Run `scripts/setup-vm2.sh` OR follow manual steps
- [ ] Verify Docker installation: `docker --version`
- [ ] Verify firewall: `sudo firewall-cmd --list-all`

### Service Startup
- [ ] Start services: `docker compose up -d --build node-app python-app promtail`
- [ ] Verify services running: `docker ps`
- [ ] Check logs: `docker compose logs -f` (no errors)

### Service Health
- [ ] Node app accessible: `curl http://localhost:4000/api/hello`
- [ ] Python app accessible: `curl http://localhost:5000/api/hello`
- [ ] Node metrics endpoint: `curl http://localhost:4000/metrics`
- [ ] Python metrics endpoint: `curl http://localhost:5000/metrics`
- [ ] Log directories created: `ls -la app/node-app/logs app/python-app/logs`

## Cross-VM Connectivity

### From VM1
- [ ] Test VM2 Node app: `curl http://<VM2_IP>:4000/metrics`
- [ ] Test VM2 Python app: `curl http://<VM2_IP>:5000/metrics`

### From VM2
- [ ] Test VM1 Prometheus: `curl http://<VM1_IP>:9090/targets`
- [ ] Test VM1 AI Engine: `curl http://<VM1_IP>:8080/health`

## Grafana Setup

### Access Grafana
- [ ] Open browser: `http://<vm1-ip>:3000`
- [ ] Login with: `admin` / `admin`
- [ ] Change default password

### Datasources
- [ ] Verify Prometheus datasource is connected
- [ ] Verify Loki datasource is connected
- [ ] Test both datasources (query test data)

### Dashboards
- [ ] Dashboard "AIOps Essentials Dashboard" provisioned
- [ ] Panels show data from Node app
- [ ] Panels show data from Python app

### Alerts
- [ ] Alert rules loaded from `alert-rules.yml`
- [ ] Alerts configured in Alertmanager
- [ ] Alert routing points to AI Engine webhook

## Alertmanager Setup

### Access Alertmanager
- [ ] Open browser: `http://<vm1-ip>:9093`
- [ ] Verify routing configuration
- [ ] Check that AI Engine webhook is configured

### Test Alert Route
- [ ] Trigger test alert: `curl -X POST http://localhost:9093/api/v1/alerts -H 'Content-Type: application/json' -d '[{"labels":{"severity":"test"},"annotations":{"summary":"Test alert"}}]'`
- [ ] Verify webhook was called (check AI Engine logs)

## AI Engine Setup

### Ollama Installation
- [ ] Ollama installed or running in container
- [ ] Ollama accessible at configured `OLLAMA_URL`
- [ ] Model available: `ollama list` or `curl http://ollama-url:11434/api/tags`

### Slack Integration
- [ ] Slack webhook URL valid
- [ ] Test message sent: `curl -X POST $SLACK_WEBHOOK_URL -d '{"text":"Test from AI Engine"}'`
- [ ] Message received in Slack channel

### Telegram Integration
- [ ] Telegram bot created and running
- [ ] Token valid
- [ ] Chat ID correct
- [ ] Test message sent via Telegram API

## Testing & Validation

### Test Incident Generation
- [ ] Run `scripts/simulate-incidents.sh error-spike`
- [ ] Error logs generated in app directories
- [ ] Prometheus alerts triggered (visible in Alertmanager)
- [ ] Grafana dashboard shows increased error rate
- [ ] Slack/Telegram notification received from AI Engine

### Test Log Collection
- [ ] Generate errors: `curl http://<VM2_IP>:4000/api/error`
- [ ] Check Loki for error logs
- [ ] Query in Grafana: `{job="app_logs"} |= "ERROR"`
- [ ] Results visible on dashboard

### Test Metrics Collection
- [ ] Node metrics updated on Prometheus
- [ ] Python metrics updated on Prometheus
- [ ] Grafana dashboard panels show live data
- [ ] Query builder works: `increase(http_requests_total[5m])`

## Hardening & Security

- [ ] Change Grafana admin password
- [ ] Enable HTTPS for Grafana (if production)
- [ ] Restrict firewall to trusted subnets only
- [ ] Set resource limits in Docker Compose
- [ ] Store secrets in secure location
- [ ] Review and test backup procedures

## Documentation

- [ ] Update `docs/vm-setup.md` with your actual VM IPs
- [ ] Create runbook for common operations
- [ ] Document alert response procedures
- [ ] Create incident response playbook

## Go-Live Checklist

- [ ] All health checks passing
- [ ] All integrations tested
- [ ] Dashboards optimized and validated
- [ ] Alert thresholds tuned and tested
- [ ] Team trained on using the platform
- [ ] Backup strategy in place
- [ ] Monitoring of the monitoring stack configured

## Post-Deployment

- [ ] Monitor system resource usage
- [ ] Review and tune alert thresholds
- [ ] Collect feedback from team
- [ ] Document lessons learned
- [ ] Schedule regular training sessions
- [ ] Plan for scaling/upgrades

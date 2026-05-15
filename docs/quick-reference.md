# Quick Reference Guide

Fast reference for common operations on the AIOps stack.

## One-Command Setup

### Single Machine (Development/Testing)
```bash
cd /opt/aiops-project
bash scripts/quick-start.sh
```

### Distributed Setup
```bash
# On client (192.168.112.130)
bash scripts/setup-vm1.sh 192.168.112.135

# On server (192.168.112.135)
bash scripts/setup-vm2.sh 192.168.112.130
```

---

## Common Docker Commands

### View running containers
```bash
docker ps
```

### View all services status
```bash
docker compose ps
```

### View specific service logs
```bash
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f loki
docker compose logs -f promtail
docker compose logs -f ai-engine
docker compose logs -f node-app
docker compose logs -f python-app
```

### Restart all services
```bash
docker compose restart
```

### Restart specific service
```bash
docker compose restart prometheus
```

### Stop all services
```bash
docker compose down
```

### Rebuild and restart
```bash
docker compose up -d --build
```

---

## Service Endpoints

### client (Monitoring)
- Prometheus: `http://<client-ip>:9090`
- Grafana: `http://<client-ip>:3000`
- Loki: `http://<client-ip>:3100`
- Alertmanager: `http://<client-ip>:9093`
- AI Engine: `http://<client-ip>:8080`

### server (Applications)
- Node app: `http://<server-ip>:4000`
- Python app: `http://<server-ip>:5000`

---

## Testing & Incident Simulation

### Generate all test incidents
```bash
cd /opt/aiops-project/scripts
bash simulate-incidents.sh all
```

### Generate specific incidents
```bash
bash simulate-incidents.sh error-spike
bash simulate-incidents.sh high-latency
bash simulate-incidents.sh cpu-spike
bash simulate-incidents.sh memory-spike
bash simulate-incidents.sh log-errors
```

### Generate raw errors
```bash
curl http://localhost:4000/api/error
curl http://localhost:5000/api/error
```

### View generated logs
```bash
tail -f /opt/aiops-project/app/node-app/logs/node-app.log
tail -f /opt/aiops-project/app/python-app/logs/python-app.log
```

---

## Health Checks

### Quick health check
```bash
bash scripts/check-health.sh localhost localhost
```

### Check with specific VMs
```bash
bash scripts/check-health.sh <VM1_IP> <VM2_IP>
```

### Manual endpoint checks

From client:
```bash
curl http://localhost:9090/-/healthy      # Prometheus
curl http://localhost:3000/api/health     # Grafana
curl http://localhost:3100/ready          # Loki
curl http://localhost:9093/-/healthy      # Alertmanager
curl http://localhost:8080/health         # AI Engine
```

From server:
```bash
curl http://localhost:4000/api/hello      # Node app
curl http://localhost:5000/api/hello      # Python app
curl http://localhost:4000/metrics        # Node metrics
curl http://localhost:5000/metrics        # Python metrics
```

---

## Configuration Updates

### Update Prometheus targets
```bash
# Edit the file
vi /opt/aiops-project/monitoring/prometheus/prometheus.yml

# Reload Prometheus
curl -X POST http://localhost:9090/-/reload
```

### Update alert rules
```bash
# Edit the file
vi /opt/aiops-project/monitoring/prometheus/alert-rules.yml

# Reload Prometheus
curl -X POST http://localhost:9090/-/reload
```

### Update .env variables
```bash
# Edit the file
vi /opt/aiops-project/.env

# Restart services that use those variables
docker compose restart ai-engine
```

---

## Viewing Metrics & Logs

### Prometheus queries in browser
```
http://localhost:9090/graph
```

Common queries:
- `http_requests_total` - Total requests by job/status
- `http_request_duration_seconds` - Request duration histogram
- `rate(http_requests_total[5m])` - Request rate over 5 minutes

### Loki queries in Grafana
```
{job="app_logs"}
{job="app_logs"} |= "ERROR"
{job="app_logs"} |= "ERROR" | json
```

---

## Troubleshooting

### Service won't start
```bash
# Check logs
docker compose logs servicename

# Verify port not in use
sudo lsof -i :9090  # Check Prometheus port
sudo firewall-cmd --list-ports
```

### Can't connect between VMs
```bash
# Test connectivity
ping <VM1_IP>
curl http://<VM1_IP>:9090/metrics

# Check firewall
sudo firewall-cmd --list-all
sudo firewall-cmd --list-ports
```

### Prometheus not scraping
```bash
# Check targets
curl http://localhost:9090/api/v1/targets | jq

# Check if targets are UP or DOWN
# Verify Prometheus config for correct IPs
```

### Loki not receiving logs
```bash
# Check promtail status
docker compose logs promtail

# Verify log path configuration
vi monitoring/promtail/promtail-config.yaml

# Check log directory permissions
ls -la app/node-app/logs
ls -la app/python-app/logs
```

### AI Engine not receiving alerts
```bash
# Check Alertmanager webhook config
vi monitoring/alertmanager/alertmanager.yml

# Test webhook manually
curl -X POST http://localhost:8080/alert -H 'Content-Type: application/json' \
  -d '{"status":"firing","commonAnnotations":{"summary":"Test"}}'

# Check AI Engine logs
docker compose logs ai-engine
```

---

## Cleanup & Reset

### Remove all containers and volumes
```bash
docker compose down -v
```

### Remove only containers (keep volumes)
```bash
docker compose down
```

### Clean up old logs
```bash
sudo rm -rf app/*/logs/*
```

### Reset Grafana to defaults
```bash
docker volume rm aiops-platform_grafana-storage
docker compose restart grafana
```

---

## Performance Optimization

### Increase Prometheus retention
```yaml
# In docker-compose.yml, modify prometheus args:
- '--storage.tsdb.retention.time=30d'
```

### Reduce scrape interval for faster updates
```yaml
# In monitoring/prometheus/prometheus.yml:
global:
  scrape_interval: 5s  # Changed from 15s
```

### Enable caching in Promtail
```yaml
# In monitoring/promtail/promtail-config.yaml:
positions:
  filename: /tmp/positions.yaml
  sync_period: 5s  # Cache positions every 5s
```

---

## Production Recommendations

1. Use external persistent storage for Prometheus and Loki
2. Enable HTTPS/TLS for all services
3. Set resource limits on containers
4. Use secrets management for credentials
5. Enable authentication on all web interfaces
6. Configure log rotation
7. Set up monitoring alerts for the monitoring stack itself
8. Use a proper backup solution
9. Document runbooks for common operations
10. Regular security audits and updates

---

## Support & Documentation

- Main docs: `docs/architecture.md`
- Setup guide: `docs/vm-setup.md`
- Deployment checklist: `docs/deployment-checklist.md`
- GitHub repository issues
- Grafana documentation: https://grafana.com/docs/
- Prometheus documentation: https://prometheus.io/docs/

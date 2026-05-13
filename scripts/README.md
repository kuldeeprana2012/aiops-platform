# AIOps Setup Scripts

This directory contains automated shell scripts for deploying the AIOps monitoring stack.

## Scripts Overview

### 1. `setup-vm1.sh` - VM1 Monitoring Stack Setup
**Purpose:** Automate complete setup of monitoring infrastructure on VM1

**Usage:**
```bash
bash setup-vm1.sh [VM2_IP] [REPO_URL]
```

**Parameters:**
- `VM2_IP` (optional): IP address of VM2 where applications run. Default: `192.168.100.11`
- `REPO_URL` (optional): Git repository URL to clone. Default: prompted

**What it does:**
- ✅ Updates system packages
- ✅ Installs Docker and Docker Compose
- ✅ Configures firewall (ports 9090, 3000, 3100, 9093, 8080, 22)
- ✅ Clones the AIOps repository
- ✅ Creates/configures `.env` file
- ✅ Updates Prometheus targets with VM2 IP
- ✅ Starts all monitoring services
- ✅ Provides access URLs

**Expected time:** 5-10 minutes

**Services started:**
- Prometheus
- Grafana
- Loki
- Alertmanager
- AI Engine

---

### 2. `setup-vm2.sh` - VM2 Applications Setup
**Purpose:** Automate setup of application servers and log collection on VM2

**Usage:**
```bash
bash setup-vm2.sh [REPO_URL]
```

**Parameters:**
- `REPO_URL` (optional): Git repository URL to clone

**What it does:**
- ✅ Updates system packages
- ✅ Installs Docker and Docker Compose
- ✅ Configures firewall (ports 4000, 5000, 22)
- ✅ Clones the AIOps repository
- ✅ Creates log directories
- ✅ Starts applications and log collection
- ✅ Displays test endpoints

**Expected time:** 3-5 minutes

**Services started:**
- Node.js application (port 4000)
- Python application (port 5000)
- Promtail (log collector)

---

### 3. `quick-start.sh` - Single Machine Quick Start
**Purpose:** Deploy entire stack on a single machine for development/testing

**Usage:**
```bash
bash quick-start.sh
```

**What it does:**
- ✅ Creates log directories
- ✅ Copies `.env.example` to `.env`
- ✅ Stops any running containers
- ✅ Builds and starts all services
- ✅ Displays all access URLs

**Expected time:** 2-3 minutes

**Best for:**
- Development environments
- Testing and learning
- Desktop/laptop testing
- Single machine demos

---

### 4. `simulate-incidents.sh` - Test Incident Generator
**Purpose:** Generate realistic incidents to test the monitoring and alerting system

**Usage:**
```bash
bash simulate-incidents.sh [INCIDENT_TYPE]
```

**Incident types:**
- `error-spike` - Generate 500 HTTP errors to trigger alerts
- `high-latency` - Simulate slow response times
- `cpu-spike` - CPU stress test (uses `stress-ng`)
- `memory-spike` - Memory pressure test
- `log-errors` - Write error log entries
- `all` - Run all tests sequentially

**What it does (per incident):**
- ✅ Verifies app connectivity
- ✅ Generates specific incident pattern
- ✅ Produces metrics spike
- ✅ Creates log entries
- ✅ Triggers Prometheus alerts
- ✅ Routes alerts to AI Engine
- ✅ Sends Slack/Telegram notification

**Example workflow:**
```bash
# Generate errors
bash simulate-incidents.sh error-spike

# Watch Grafana dashboard
# Open http://localhost:3000 in browser

# Check Alertmanager
# Open http://localhost:9093 in browser

# Verify Slack/Telegram notifications
```

---

### 5. `check-health.sh` - Health Check Utility
**Purpose:** Verify all services are running and responding correctly

**Usage:**
```bash
bash check-health.sh [VM1_IP] [VM2_IP]
```

**Parameters:**
- `VM1_IP` (optional): VM1 IP address. Default: `localhost`
- `VM2_IP` (optional): VM2 IP address. Default: `localhost`

**What it does:**
- ✅ Tests Prometheus endpoint
- ✅ Tests Grafana endpoint
- ✅ Tests Loki endpoint
- ✅ Tests Alertmanager endpoint
- ✅ Tests AI Engine endpoint
- ✅ Tests Node app metrics
- ✅ Tests Python app metrics
- ✅ Lists running Docker containers
- ✅ Shows firewall status

**Example usage:**
```bash
# Local machine
bash check-health.sh

# Two VM setup
bash check-health.sh 192.168.100.10 192.168.100.11

# Just VM1
bash check-health.sh 192.168.100.10
```

---

## Quick Reference

### For Development (Single Machine)
```bash
cd /opt/aiops-project
bash scripts/quick-start.sh
```

### For Production (Two VMs)

**On VM1:**
```bash
bash scripts/setup-vm1.sh 192.168.100.11 https://github.com/kuldeeprana2012/aiops-platform.git
```

**On VM2:**
```bash
bash scripts/setup-vm2.sh https://github.com/kuldeeprana2012/aiops-platform.git
```

### For Testing
```bash
cd /opt/aiops-project/scripts
bash simulate-incidents.sh all
```

### For Health Checks
```bash
bash scripts/check-health.sh 192.168.100.10 192.168.100.11
```

---

## Error Handling

All scripts include:
- ✅ Exit on error (`set -e`)
- ✅ Color-coded output (GREEN for success, RED for errors, YELLOW for info)
- ✅ Progress indicators
- ✅ Clear error messages
- ✅ Next steps guidance

---

## Requirements

### System Requirements
- Rocky Linux 10 (or compatible)
- 2GB+ RAM per machine
- 10GB+ disk space
- Internet connection

### Required Commands
- `bash` - Script interpreter
- `curl` - HTTP testing
- `git` - Repository cloning
- `sudo` - Elevated privileges

### For Incident Simulation
- `stress-ng` - CPU/memory stress testing (installed automatically on VM2)

---

## Troubleshooting

### Script exits early
```bash
# Run with verbose mode
bash -x setup-vm1.sh 2>&1 | tee setup.log

# Check the logs
cat setup.log
```

### Docker not found after script
```bash
# May need to restart shell
newgrp docker

# Or log out and back in
```

### Firewall issues
```bash
# Check firewall status
sudo firewall-cmd --list-all

# Manually open ports
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --reload
```

### Services not starting
```bash
# Check Docker
docker ps

# View logs
docker compose logs -f

# Check available disk space
df -h
```

---

## Additional Resources

- **Main Setup Guide:** `../SETUP.md`
- **Architecture Details:** `../docs/architecture.md`
- **Quick Reference:** `../docs/quick-reference.md`
- **Deployment Checklist:** `../docs/deployment-checklist.md`

---

## Support

For issues or questions:
1. Check `/docs/quick-reference.md` for common commands
2. Review script output and logs
3. Consult `/docs/deployment-checklist.md`
4. Open GitHub issue with script output

---

**Happy Deploying! 🚀**

# 🚀 AIOps Platform - Complete Setup Guide

Enterprise-grade AIOps monitoring stack with AI-powered incident analysis on Rocky Linux 10.

## 📋 Overview

This project automates the deployment of:
- **Prometheus** for metrics collection
- **Grafana** for visualization and alerting
- **Loki** for centralized log aggregation
- **Promtail** for log collection
- **Alertmanager** for alert routing
- **AI Engine** (Python + Ollama LLM) for intelligent incident analysis
- **Node.js & Python apps** for monitoring demonstration

---

## 🎯 Quick Start (5 minutes)

### Option 1: Single Machine Setup (Development)

```bash
# 1. Clone the repository
cd /opt/aiops-project

# 2. Run the all-in-one quick start
bash scripts/quick-start.sh
```

**Access the stack at:**
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Loki: http://localhost:3100
- Alertmanager: http://localhost:9093

### Option 2: Two-VM Setup (Production)

#### VM1 Setup (Monitoring Stack)
```bash
# Download and run setup script
curl -fsSL https://raw.githubusercontent.com/<username>/aiops-platform/main/scripts/setup-vm1.sh | bash

# Or manually:
bash scripts/setup-vm1.sh 192.168.112.132
```

#### VM2 Setup (Applications)
```bash
# Download and run setup script
curl -fsSL https://raw.githubusercontent.com/<username>/aiops-platform/main/scripts/setup-vm2.sh | bash

# Or manually:
bash scripts/setup-vm2.sh
```

---

## 📂 Project Structure

```
aiops-platform/
├── docker-compose.yml              # Main deployment configuration
├── .env.example                    # Environment variables template
├── README.md                       # This file
│
├── scripts/
│   ├── setup-vm1.sh               # Automated setup for VM1 (monitoring)
│   ├── setup-vm2.sh               # Automated setup for VM2 (apps)
│   ├── quick-start.sh             # Single machine quick start
│   ├── simulate-incidents.sh      # Generate test incidents
│   └── check-health.sh            # Health check utility
│
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml         # Metrics collection config
│   │   └── alert-rules.yml        # Alert rules
│   ├── grafana/
│   │   └── provisioning/
│   │       ├── datasources/       # Auto-provision Prometheus/Loki
│   │       └── dashboards/        # Auto-provision dashboards
│   ├── loki/
│   │   └── loki-config.yaml       # Log storage config
│   ├── promtail/
│   │   └── promtail-config.yaml   # Log collection config
│   └── alertmanager/
│       └── alertmanager.yml       # Alert routing config
│
├── app/
│   ├── node-app/                  # Node.js sample app
│   │   ├── Dockerfile
│   │   ├── index.js
│   │   ├── package.json
│   │   └── logs/                  # App logs directory
│   └── python-app/                # Python sample app
│       ├── Dockerfile
│       ├── app.py
│       ├── requirements.txt
│       └── logs/                  # App logs directory
│
├── ai-engine/                      # AI incident analysis service
│   ├── Dockerfile
│   ├── webhook.py                 # Alert webhook handler
│   ├── analysis.py                # Log analysis script
│   └── requirements.txt
│
├── kubernetes/                     # Kubernetes manifests (optional)
│   ├── prometheus-deployment.yaml
│   ├── grafana-deployment.yaml
│   ├── loki-deployment.yaml
│   ├── promtail-daemonset.yaml
│   └── ai-deployment.yaml
│
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI/CD
│
└── docs/
    ├── architecture.md            # System architecture
    ├── vm-setup.md                # VM setup details
    ├── deployment-checklist.md    # Pre-deployment checklist
    └── quick-reference.md         # Common commands reference
```

---

## 🔧 Detailed Setup Instructions

### Prerequisites

- Two Rocky Linux 10 VMs OR one VM for all-in-one setup
- Minimum 4GB RAM per VM
- At least 20GB disk space
- Internet access for package downloads
- Network access between VMs (if using two VMs)

### Step 1: Common Setup (Both VMs or Single Machine)

```bash
# Update system
sudo dnf update -y

# Install essential packages
sudo dnf install -y git curl wget vim firewalld

# Enable firewall
sudo systemctl enable --now firewalld
```

### Step 2: Automated Setup

#### For VM1 (Monitoring + AI) - on first VM
```bash
# Make script executable
chmod +x scripts/setup-vm1.sh

# Run with VM2 IP as parameter
# Usage: setup-vm1.sh [VM2_IP] [REPO_URL]
bash scripts/setup-vm1.sh 192.168.100.11 https://github.com/yourusername/aiops-platform.git
```

This script will:
- ✅ Install Docker and Docker Compose
- ✅ Configure firewall ports (9090, 3000, 3100, 9093, 8080)
- ✅ Clone the repository
- ✅ Update Prometheus targets for VM2
- ✅ Start all monitoring services
- ✅ Display access URLs

#### For VM2 (Applications + Logging) - on second VM
```bash
# Make script executable
chmod +x scripts/setup-vm2.sh

# Run with repo URL as parameter
bash scripts/setup-vm2.sh https://github.com/yourusername/aiops-platform.git
```

This script will:
- ✅ Install Docker and Docker Compose
- ✅ Configure firewall ports (4000, 5000)
- ✅ Clone the repository
- ✅ Create log directories
- ✅ Start application services

### Step 3: Configuration

#### Set Environment Variables (VM1)
```bash
cd /opt/aiops-project

# Edit .env with your credentials
vim .env

# Required variables:
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
# TELEGRAM_TOKEN=123456789:ABCD...
# TELEGRAM_CHAT_ID=123456789
# OLLAMA_URL=http://localhost:11434
```

#### Get Slack Webhook URL
1. Create Slack app: https://api.slack.com/apps
2. Enable Incoming Webhooks
3. Create New Webhook to Workspace
4. Copy the webhook URL

#### Get Telegram Credentials
1. Chat with @BotFather on Telegram
2. Create a new bot: `/newbot`
3. Get the token
4. Get chat ID by sending any message to bot and checking updates: `/api/v1/updates`

### Step 4: Verify Services

#### Check service status
```bash
# List all running containers
docker ps

# View service logs
docker compose logs -f
```

#### Run health check
```bash
cd scripts
bash check-health.sh 192.168.100.10 192.168.100.11
```

#### Test applications (from VM2)
```bash
curl http://localhost:4000/api/hello
curl http://localhost:5000/api/hello
```

#### Verify monitoring (from VM1)
```bash
# Test Prometheus
curl http://localhost:9090/targets

# Test Grafana
curl http://localhost:3000/api/health

# Test AI Engine
curl http://localhost:8080/health
```

---

## 📊 Access Points

### Monitoring Stack (VM1)

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://VM1_IP:3000 | admin/admin |
| Prometheus | http://VM1_IP:9090 | (no auth) |
| Loki | http://VM1_IP:3100 | (no auth) |
| Alertmanager | http://VM1_IP:9093 | (no auth) |
| AI Engine | http://VM1_IP:8080 | (no auth) |

### Applications (VM2)

| Service | Endpoint |
|---------|----------|
| Node App | http://VM2_IP:4000/api/hello |
| Node Metrics | http://VM2_IP:4000/metrics |
| Python App | http://VM2_IP:5000/api/hello |
| Python Metrics | http://VM2_IP:5000/metrics |

---

## 🧪 Testing & Incident Simulation

### Generate Test Incidents

```bash
cd /opt/aiops-project/scripts

# Run all test incidents
bash simulate-incidents.sh all

# Or run specific incident type:
bash simulate-incidents.sh error-spike        # Generate 500 errors
bash simulate-incidents.sh high-latency       # Slow down responses
bash simulate-incidents.sh cpu-spike          # CPU stress test
bash simulate-incidents.sh memory-spike       # Memory stress test
bash simulate-incidents.sh log-errors         # Write error logs
```

### Monitor the Test

1. **Grafana Dashboard**: http://VM1_IP:3000
   - View error rate spike
   - Watch latency increase
   - See resource utilization

2. **Prometheus Alerts**: http://VM1_IP:9090/alerts
   - View triggered alerts
   - Check alert status

3. **Alertmanager**: http://VM1_IP:9093
   - Verify alert routing
   - Check if webhook called

4. **Slack/Telegram**
   - Receive AI-enhanced notifications
   - View root cause analysis

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/architecture.md) | System design and data flow |
| [VM Setup](docs/vm-setup.md) | Detailed VM configuration steps |
| [Deployment Checklist](docs/deployment-checklist.md) | Pre-deployment verification |
| [Quick Reference](docs/quick-reference.md) | Common commands and troubleshooting |

---

## 🔄 Management Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f ai-engine
```

### Restart Services
```bash
# Restart all
docker compose restart

# Restart specific
docker compose restart prometheus
```

### Stop/Start
```bash
# Stop all
docker compose stop

# Start all
docker compose up -d

# Stop and remove containers (keep data)
docker compose down
```

### Update Configuration
```bash
# Edit config
vim monitoring/prometheus/prometheus.yml

# Reload Prometheus
curl -X POST http://localhost:9090/-/reload
```

---

## 🛡️ Production Recommendations

1. **Security**
   - Enable HTTPS/TLS for all web services
   - Change default Grafana password
   - Use firewall to restrict access
   - Store secrets in secure vault

2. **Performance**
   - Use external persistent storage
   - Increase Prometheus retention period
   - Scale horizontally with multiple instances
   - Optimize alert thresholds

3. **Reliability**
   - Set up automated backups
   - Monitor the monitoring system itself
   - Create incident response playbooks
   - Regular security audits

4. **Scalability**
   - Consider Kubernetes for multi-region
   - Use load balancers
   - Implement service mesh
   - Plan for growth

---

## 🐛 Troubleshooting

### Service won't start
```bash
# Check logs
docker compose logs servicename

# Check ports
sudo lsof -i :9090
sudo firewall-cmd --list-ports

# Verify configuration
cat monitoring/prometheus/prometheus.yml
```

### Can't connect between VMs
```bash
# Test connectivity
ping 192.168.100.11
curl http://192.168.100.11:4000/metrics

# Check firewall
sudo firewall-cmd --list-all
```

### No metrics appearing
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq

# Verify app endpoints
curl http://192.168.100.11:4000/metrics
```

### See [Quick Reference](docs/quick-reference.md) for more troubleshooting steps

---

## 📞 Support

- GitHub Issues: Report bugs and request features
- Documentation: Read comprehensive guides
- Examples: Check `simulate-incidents.sh` for testing examples

---

## 📄 License

Apache 2.0 (or your chosen license)

---

## 🎓 Learning Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/overview/)
- [Ollama Documentation](https://github.com/ollama/ollama)

---

## 🚦 Next Steps

1. ✅ Run `setup-vm1.sh` and `setup-vm2.sh`
2. ✅ Access Grafana dashboard
3. ✅ Configure Slack/Telegram notifications
4. ✅ Run incident simulations
5. ✅ Validate alert generation
6. ✅ Customize dashboards
7. ✅ Deploy to production

---

**Happy Monitoring! 🎉**

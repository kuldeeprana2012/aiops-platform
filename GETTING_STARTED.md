# 🎉 AIOps Platform - Complete Deployment Package

## 📦 What's Included

Your AIOps monitoring platform is now fully configured with **one-shot deployment scripts** for Rocky Linux 10 VMs.

---

## 🚀 Getting Started (3 Steps)

### Step 1: Choose Your Deployment Model

#### **Option A: Single Machine (Development)**
Best for: Learning, testing, local development
```bash
cd /opt/aiops-project
bash scripts/quick-start.sh
```
⏱️ Time: ~3 minutes

#### **Option B: Two VMs (Production)**
Best for: Enterprise, high availability, real scenarios

**client (Monitoring Stack):**
```bash
bash scripts/setup-vm1.sh <VM2_IP>
```

**server (Applications):**
```bash
bash scripts/setup-vm2.sh 192.168.112.133
```

⏱️ Time: ~10 minutes total

### Step 2: Access the Dashboard
```
Grafana: http://localhost:3000 (admin/admin)
Prometheus: http://localhost:9090
```

### Step 3: Generate Test Incidents
```bash
cd scripts
bash simulate-incidents.sh all
```

---

## 📂 Files Created in Your Workspace

### 🔧 Setup Automation Scripts (`scripts/`)

```
scripts/
├── setup-vm1.sh              ← Run this on client (monitoring)
├── setup-vm2.sh              ← Run this on server (apps)
├── quick-start.sh            ← Run this for single machine
├── simulate-incidents.sh     ← Generate test incidents
├── check-health.sh           ← Verify all services
└── README.md                 ← Scripts documentation
```

**Key Features:**
- ✅ Automated Docker installation
- ✅ Firewall configuration
- ✅ Automatic service startup
- ✅ Cross-VM networking setup
- ✅ Color-coded output with progress
- ✅ Error handling and rollback

### 📋 Documentation (`docs/`)

```
docs/
├── architecture.md           ← System design & data flow
├── vm-setup.md               ← Manual VM setup steps
├── deployment-checklist.md   ← Pre-deployment verification
├── quick-reference.md        ← Common commands & troubleshooting
```

### 📱 Configuration Files

```
monitoring/
├── prometheus/
│   ├── prometheus.yml        ← Metrics collection config
│   └── alert-rules.yml       ← Alert definitions
├── grafana/
│   └── provisioning/
│       ├── datasources/      ← Auto-provision Prometheus/Loki
│       └── dashboards/       ← Pre-built dashboards
├── loki/
│   └── loki-config.yaml      ← Log storage
├── promtail/
│   └── promtail-config.yaml  ← Log collection
└── alertmanager/
    └── alertmanager.yml      ← Alert routing
```

### 🐳 Application & AI Engine

```
app/
├── node-app/                 ← Node.js sample app
│   ├── index.js
│   ├── Dockerfile
│   └── logs/                 ← Generated logs
└── python-app/               ← Python sample app
    ├── app.py
    ├── Dockerfile
    └── logs/                 ← Generated logs

ai-engine/
├── webhook.py                ← Alert webhook handler
├── analysis.py               ← Log analysis
└── Dockerfile
```

### 📊 Orchestration

```
docker-compose.yml           ← Complete stack definition
.env.example                 ← Environment template
SETUP.md                     ← Comprehensive setup guide
kubernetes/                  ← K8s manifests (optional)
.github/workflows/           ← GitHub Actions CI/CD
```

---

## 🎯 Usage Examples

### 1. **First Time Setup (New User)**

```bash
# Clone to client
cd /opt/aiops-project

# Run automated setup
bash scripts/setup-vm1.sh <VM2_IP>
```

**What happens automatically:**
1. System packages updated
2. Docker & Docker Compose installed
3. Firewall configured
4. Repository cloned
5. Services started
6. Dashboard ready to use

### 2. **Check Everything is Working**

```bash
# From project directory
bash scripts/check-health.sh 192.168.112.133 <VM2_IP>
```

**Output shows:**
- ✅/❌ Each service status
- Running containers
- Firewall configuration
- Network connectivity

### 3. **Generate Test Incidents**

```bash
bash scripts/simulate-incidents.sh error-spike
```

**Watch in real-time:**
- Error spike hits 50% in Grafana
- Alerts fire in Prometheus
- AI Engine analyzes the issue
- Slack/Telegram notification sent

---

## 🔑 Key Features

### ✅ Automation
- One-command setup for entire stack
- Automatic Docker installation
- Firewall pre-configured
- Services start automatically

### ✅ Monitoring
- Prometheus metrics collection
- Grafana dashboards pre-built
- Loki centralized logging
- Real-time alerting

### ✅ AI-Powered
- Ollama LLM integration
- Intelligent incident analysis
- Root cause suggestions
- Slack/Telegram alerts with AI insights

### ✅ Testing
- Built-in incident simulator
- Error spike generation
- Latency simulation
- CPU/memory stress testing
- Log injection tools

### ✅ Documentation
- Complete setup guides
- Architecture diagrams
- Troubleshooting guides
- Command reference

---

## 📊 Service Architecture

```
┌─────────────────────────────────────────────┐
│                  client (Monitoring)            │
├─────────────────────────────────────────────┤
│  Prometheus (9090)  →  Grafana (3000)       │
│  Loki (3100)  →  Promtail (log collector)   │
│  Alertmanager (9093)  →  AI Engine (8080)   │
└─────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│              server (Applications)              │
├─────────────────────────────────────────────┤
│  Node App (4000)  ↙ Metrics + Logs ↖        │
│  Python App (5000)                 │        │
│  Promtail (collects logs)  ────────┘        │
└─────────────────────────────────────────────┘
```

---

## 🌐 Access Points

| Service | VM | URL | Purpose |
|---------|----|----|---------|
| Grafana | 1 | `http://<vm1>:3000` | Dashboards & alerts |
| Prometheus | 1 | `http://<vm1>:9090` | Metrics query |
| Loki | 1 | `http://<vm1>:3100` | Log search |
| Alertmanager | 1 | `http://<vm1>:9093` | Alert status |
| AI Engine | 1 | `http://<vm1>:8080` | Webhook endpoint |
| Node App | 2 | `http://<vm2>:4000` | Test endpoint |
| Python App | 2 | `http://<vm2>:5000` | Test endpoint |

---

## 📋 Setup Checklist

- [ ] Two VMs or one machine ready
- [ ] Rocky Linux 10 installed
- [ ] Internet access available
- [ ] Project cloned to `/opt/aiops-project`
- [ ] Run `setup-vm1.sh` (or `quick-start.sh`)
- [ ] Run `setup-vm2.sh` (if two VMs)
- [ ] Wait 2-3 minutes for services to start
- [ ] Access Grafana: http://localhost:3000
- [ ] Run `simulate-incidents.sh` to test
- [ ] Verify Slack/Telegram notifications

---

## 🧪 Test Scenarios

### Scenario 1: Error Spike Alert
```bash
bash scripts/simulate-incidents.sh error-spike
# → Error rate jumps to 50%
# → Alert fires after 5 minutes
# → AI analyzes and sends notification
```

### Scenario 2: Performance Degradation
```bash
bash scripts/simulate-incidents.sh high-latency
# → Response time increases
# → 95th percentile latency exceeds threshold
# → Alert triggers with AI recommendation
```

### Scenario 3: Resource Pressure
```bash
bash scripts/simulate-incidents.sh cpu-spike
# → CPU usage spikes to 80%+
# → Logs show increased error rate
# → Root cause: CPU saturation identified
```

---

## 🛠️ Common Operations

### View Logs
```bash
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f ai-engine
```

### Restart Services
```bash
docker compose restart
```

### Update Configuration
```bash
vim monitoring/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
```

### Health Check
```bash
bash scripts/check-health.sh
```

---

## 📚 Documentation Files

1. **SETUP.md** (main guide)
   - Complete step-by-step instructions
   - Access points and URLs
   - Testing procedures
   - Troubleshooting guide

2. **scripts/README.md**
   - Detailed script documentation
   - Usage examples for each script
   - Parameter explanations

3. **docs/quick-reference.md**
   - Common commands
   - Troubleshooting tips
   - Quick lookups

4. **docs/deployment-checklist.md**
   - Pre-deployment verification
   - Post-deployment validation
   - Security hardening steps

5. **docs/architecture.md**
   - System design
   - Data flow diagrams
   - Component interaction

---

## 🚀 Next Steps

### Immediate (Today)
1. Run one of the setup scripts
2. Access Grafana dashboard
3. Run incident simulator
4. Watch alerts flow through system

### Short Term (This Week)
1. Customize Grafana dashboards
2. Tune alert thresholds
3. Integrate with your Slack workspace
4. Train team on using the platform

### Long Term (This Month)
1. Deploy to production VMs
2. Enable HTTPS/TLS
3. Set up log rotation
4. Create incident runbooks
5. Schedule regular training

---

## 💡 Tips & Tricks

### Monitor the Setup Script Output
```bash
# Save output to file for debugging
bash scripts/setup-vm1.sh 2>&1 | tee setup.log
```

### Test Without Incidents
```bash
# Just check endpoints
curl http://localhost:4000/api/hello
curl http://localhost:5000/api/hello
```

### View Real Logs
```bash
# Node app logs
tail -f app/node-app/logs/node-app.log

# Python app logs
tail -f app/python-app/logs/python-app.log
```

### Quick Grafana Access
```bash
# Default credentials (CHANGE THESE!)
# Username: admin
# Password: admin
# 
# First login will prompt to change password
```

---

## ❓ FAQ

**Q: What if a script fails?**
A: Check the error message, fix the issue, and rerun. Most scripts are idempotent (safe to rerun).

**Q: Can I run on a single machine?**
A: Yes! Use `quick-start.sh` for all-in-one setup.

**Q: How long does setup take?**
A: Single machine: 3-5 minutes. Two VMs: 10-15 minutes.

**Q: Do I need Kubernetes?**
A: No, Docker Compose is included. Kubernetes manifests are optional.

**Q: How do I update the project?**
A: `git pull` to get latest changes, then `docker compose up -d --build`.

---

## 📞 Support

1. **Check Documentation**
   - `docs/quick-reference.md` for common issues
   - `SETUP.md` for detailed guidance

2. **View Logs**
   - `docker compose logs servicename` for service issues

3. **Run Health Check**
   - `bash scripts/check-health.sh` to verify setup

4. **Consult Troubleshooting**
   - Section in `docs/quick-reference.md`

---

## 🎓 Learning Path

1. **Beginner**
   - Run `quick-start.sh`
   - Explore Grafana dashboard
   - Read `docs/architecture.md`

2. **Intermediate**
   - Set up two VMs
   - Customize alert rules
   - Integrate Slack/Telegram

3. **Advanced**
   - Deploy to Kubernetes
   - Extend AI Engine prompts
   - Production hardening

---

## ✨ Features You Now Have

✅ Prometheus metrics collection
✅ Grafana dashboards and alerts
✅ Loki centralized logging
✅ Promtail log aggregation
✅ Alertmanager routing
✅ AI-powered incident analysis
✅ Slack/Telegram notifications
✅ Docker Compose deployment
✅ Kubernetes manifests (optional)
✅ CI/CD workflows (GitHub Actions)
✅ Test incident generator
✅ Health check utilities
✅ Complete documentation

---

## 🎉 You're Ready!

Your complete AIOps platform is configured and ready to deploy.

**Start with:**
```bash
bash scripts/quick-start.sh
# OR
bash scripts/setup-vm1.sh <VM2_IP>
```

**Then access:**
```
http://localhost:3000
```

**Happy Monitoring! 🚀**

---

*For more details, see SETUP.md and docs/ folder*

#!/bin/bash

# 🚀 AIOps Rocky Linux Deployment - EXACT COMMANDS
# Copy and paste these commands directly on your Rocky Linux 10 VMs

################################################################################
# client SETUP (Monitoring Stack + AI Engine)
# Run these commands on the first VM (client)
################################################################################

# Step 1: Prerequisites
sudo dnf update -y
sudo dnf install -y git curl wget vim firewalld

# Step 2: Clone Project
mkdir -p /opt/aiops-project
cd /opt/aiops-project
git clone https://github.com/kuldeeprana2012/aiops-platform.git .

# Step 3: Run Automated Setup (choose the appropriate command)

# Option A: If server is at the standard IP
bash scripts/setup-vm1.sh <VM2_IP>

# Option B: If server has a different IP
bash scripts/setup-vm1.sh YOUR_VM2_IP

# Step 4: Wait for services to start (2-3 minutes)
docker compose logs -f

# Step 5: Access Grafana
# Open browser to: http://VM1_IP:3000
# Username: admin
# Password: admin

################################################################################
# server SETUP (Applications + Log Collection)
# Run these commands on the second VM (server)
################################################################################

# Step 1: Prerequisites
sudo dnf update -y
sudo dnf install -y git curl wget vim firewalld

# Step 2: Clone Project
mkdir -p /opt/aiops-project
cd /opt/aiops-project
git clone https://github.com/kuldeeprana2012/aiops-platform.git .

# Step 3: Run Automated Setup
bash scripts/setup-vm2.sh

# Step 4: Verify services running
docker ps

# Step 5: Test applications
curl http://localhost:4000/api/hello
curl http://localhost:5000/api/hello

################################################################################
# SINGLE MACHINE SETUP (All services on one machine)
# Run these commands on a single Rocky Linux 10 VM
################################################################################

# Step 1: Prerequisites
sudo dnf update -y
sudo dnf install -y git curl wget vim firewalld

# Step 2: Clone Project
mkdir -p /opt/aiops-project
cd /opt/aiops-project
git clone https://github.com/kuldeeprana2012/aiops-platform.git .

# Step 3: Quick Start (everything in one command)
bash scripts/quick-start.sh

# Step 4: Access Grafana
# Open browser to: http://localhost:3000

################################################################################
# CONFIGURATION AFTER SETUP (client)
################################################################################

# Edit environment variables
cd /opt/aiops-project
vim .env

# Add your credentials:
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
# TELEGRAM_TOKEN=123456789:ABC...
# TELEGRAM_CHAT_ID=123456789

# Restart services to load new variables
docker compose restart ai-engine

################################################################################
# TESTING & VALIDATION
################################################################################

# Health check (run on any machine)
cd /opt/aiops-project
bash scripts/check-health.sh

# Generate test incidents (run on server or single machine)
cd /opt/aiops-project
bash scripts/simulate-incidents.sh error-spike
bash scripts/simulate-incidents.sh all

# View logs
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f ai-engine

################################################################################
# COMMON DOCKER COMMANDS
################################################################################

# View running containers
docker ps

# View all services status
docker compose ps

# View specific service logs
docker compose logs -f service_name

# Restart all services
docker compose restart

# Stop all services
docker compose stop

# Start all services
docker compose up -d

# Rebuild and restart all services
docker compose up -d --build

# Stop and remove containers (keep data)
docker compose down

# Stop and remove everything including volumes
docker compose down -v

################################################################################
# VERIFICATION COMMANDS (Run from client)
################################################################################

# Test Prometheus
curl http://localhost:9090/-/healthy

# Test Grafana
curl http://localhost:3000/api/health

# Test Loki
curl http://localhost:3100/ready

# Test Alertmanager
curl http://localhost:9093/-/healthy

# Test AI Engine
curl http://localhost:8080/health

################################################################################
# VERIFICATION COMMANDS (Run from server)
################################################################################

# Test Node app
curl http://localhost:4000/api/hello
curl http://localhost:4000/metrics

# Test Python app
curl http://localhost:5000/api/hello
curl http://localhost:5000/metrics

################################################################################
# CROSS-VM VERIFICATION (From client to server)
################################################################################

# Replace <VM2_IP> with the actual server IP
curl http://<VM2_IP>:4000/metrics
curl http://<VM2_IP>:5000/metrics

################################################################################
# TROUBLESHOOTING
################################################################################

# View setup script output
bash scripts/setup-vm1.sh 2>&1 | tee setup.log

# Check firewall
sudo firewall-cmd --list-all

# Check Docker
docker --version
docker-compose --version

# Check network connectivity
ping <VM2_IP>

# View container logs
docker logs aiops_prometheus
docker logs aiops_grafana
docker logs aiops_ai_engine

################################################################################
# PRODUCTION HARDENING
################################################################################

# Change Grafana default password
# 1. Login to http://localhost:3000 with admin/admin
# 2. Click Settings → Server Admin → Users
# 3. Change admin password

# Update Prometheus retention
# Edit docker-compose.yml and modify prometheus args:
# - '--storage.tsdb.retention.time=30d'

# Enable firewall for specific IPs only
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload

################################################################################
# SERVICE ENDPOINTS (After Setup)
################################################################################

# client (Monitoring)
# Prometheus: http://<VM1_IP>:9090
# Grafana: http://<VM1_IP>:3000
# Loki: http://<VM1_IP>:3100
# Alertmanager: http://<VM1_IP>:9093
# AI Engine: http://<VM1_IP>:8080

# server (Applications)
# Node App: http://<VM2_IP>:4000
# Python App: http://<VM2_IP>:5000

################################################################################
# IMPORTANT NOTES
################################################################################

# 1. Replace repository URL with your actual GitHub repo
#    git clone https://github.com/kuldeeprana2012/aiops-platform.git .

# 2. Replace VM2_IP with actual IP of server
#    bash scripts/setup-vm1.sh <VM2_IP>

# 3. The setup scripts will prompt for confirmations
#    - Answer 'yes' when asked to continue
#    - Or provide repository URL when prompted

# 4. First setup takes 5-10 minutes to complete
#    - Don't interrupt or close the terminal
#    - Watch the progress output

# 5. Default credentials:
#    - Grafana: admin / admin (CHANGE THIS in production)
#    - No auth on Prometheus, Loki, Alertmanager
#    - AI Engine: No authentication (secure with reverse proxy)

# 6. After setup:
#    - Edit .env with your Slack/Telegram credentials
#    - Customize alert thresholds in prometheus/alert-rules.yml
#    - Add your own applications to docker-compose.yml

################################################################################
# QUICK REFERENCE
################################################################################

# Start entire stack
docker compose up -d --build

# Stop entire stack
docker compose down

# View all logs
docker compose logs -f

# Restart specific service
docker compose restart prometheus

# View Grafana
xdg-open http://localhost:3000  # Linux
open http://localhost:3000       # macOS
start http://localhost:3000      # Windows PowerShell

# Test applications
curl http://localhost:4000/api/hello
curl http://localhost:5000/api/hello

# Generate incidents
bash scripts/simulate-incidents.sh all

# Health check
bash scripts/check-health.sh

################################################################################
# THAT'S IT!
################################################################################

# Your AIOps platform is now fully deployed and ready to use.
# 
# Next steps:
# 1. Access Grafana dashboard
# 2. Configure Slack/Telegram notifications
# 3. Run incident simulations to validate
# 4. Customize for your environment
#
# For detailed information, see:
# - SETUP.md
# - docs/quick-reference.md
# - scripts/README.md

EOF

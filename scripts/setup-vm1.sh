#!/bin/bash

################################################################################
# AIOps VM1 Setup Script (Monitoring + AI Engine)
# Run this on Rocky Linux 10 VM1
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<repo>/scripts/setup-vm1.sh | bash
# OR
#   bash setup-vm1.sh
#
# This script will:
# - Update system packages
# - Install Docker and Docker Compose
# - Configure firewall for VM1 services
# - Clone the AIOps project
# - Set up Prometheus targets for remote VM2
# - Start monitoring services
################################################################################

set -e

echo "=========================================="
echo "AIOps VM1 Setup - Monitoring Stack"
echo "=========================================="

# Variables
PROJECT_PATH="/opt/aiops-platform"
VM2_IP="${1:-192.168.112.134}"
REPO_URL="${2:-https://github.com/kuldeeprana2012/aiops-platform.git}"

echo "Target VM2 IP: $VM2_IP"
echo "Project path: $PROJECT_PATH"
echo "Repository: $REPO_URL"

# Step 1: Update system
echo ""
echo "[1/8] Updating system packages..."
sudo dnf update -y
sudo dnf install -y git curl wget vim firewalld

# Step 2: Enable and start firewalld
echo ""
echo "[2/8] Configuring firewall..."
sudo systemctl enable --now firewalld

# Step 3: Install Docker
echo ""
echo "[3/8] Installing Docker and Docker Compose..."
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker

# Step 4: Install Docker Compose
echo ""
echo "[4/8] Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Step 5: Add current user to docker group
echo ""
echo "[5/8] Adding user to docker group..."
sudo usermod -aG docker "$USER"
newgrp docker

# Step 6: Configure firewall for VM1
echo ""
echo "[6/8] Opening firewall ports for VM1 services..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=9090/tcp   # Prometheus
sudo firewall-cmd --permanent --add-port=3000/tcp   # Grafana
sudo firewall-cmd --permanent --add-port=3100/tcp   # Loki
sudo firewall-cmd --permanent --add-port=9093/tcp   # Alertmanager
sudo firewall-cmd --permanent --add-port=8080/tcp   # AI Engine
sudo firewall-cmd --permanent --add-port=22/tcp     # SSH
sudo firewall-cmd --reload

# Step 7: Clone and setup project
echo ""
echo "[7/8] Cloning AIOps project..."
if [ -d "$PROJECT_PATH" ]; then
    echo "Project path exists, updating..."
    cd "$PROJECT_PATH"
    git pull origin main
else
    sudo mkdir -p "$PROJECT_PATH"
    sudo chown "$USER":"$USER" "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    git clone "$REPO_URL" .
fi

# Copy .env.example to .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo ""
    echo "⚠️  Created .env file. Please edit it with your credentials:"
    echo "   vim .env"
    echo "   - Set SLACK_WEBHOOK_URL"
    echo "   - Set TELEGRAM_TOKEN and TELEGRAM_CHAT_ID"
    echo "   - Set OLLAMA_URL (default: http://localhost:11434)"
fi

# Update Prometheus targets for VM2
echo ""
echo "[7b/8] Updating Prometheus targets for VM2 ($VM2_IP)..."
sed -i "s|targets: \['.*:4000'\]|targets: ['${VM2_IP}:4000']|g" "$PROJECT_PATH/monitoring/prometheus/prometheus.yml"
sed -i "s|targets: \['.*:5000'\]|targets: ['${VM2_IP}:5000']|g" "$PROJECT_PATH/monitoring/prometheus/prometheus.yml"
sed -i "s|targets: \['.*:9100'\]|targets: ['${VM2_IP}:9100']|g" "$PROJECT_PATH/monitoring/prometheus/prometheus.yml"

# Step 8: Start services
echo ""
echo "[8/8] Starting monitoring services..."
cd "$PROJECT_PATH"
docker compose up -d --build prometheus grafana loki alertmanager ai-engine

echo ""
echo "=========================================="
echo "✅ VM1 Setup Complete!"
echo "=========================================="
echo ""
echo "Services running:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000"
echo "  - Loki: http://localhost:3100"
echo "  - Alertmanager: http://localhost:9093"
echo "  - AI Engine: http://localhost:8080/health"
echo ""
echo "Next steps:"
echo "  1. Edit .env with your Slack/Telegram credentials"
echo "  2. Restart containers: docker compose restart"
echo "  3. Access Grafana at http://<vm1-ip>:3000 (admin:admin)"
echo ""
echo "To view logs:"
echo "  docker compose logs -f prometheus"
echo "  docker compose logs -f grafana"
echo "  docker compose logs -f ai-engine"
echo ""

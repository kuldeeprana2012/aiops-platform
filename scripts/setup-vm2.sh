#!/bin/bash

################################################################################
# AIOps VM2 Setup Script (Application Servers + Promtail)
# Run this on Rocky Linux 10 VM2
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<repo>/scripts/setup-vm2.sh | bash
# OR
#   bash setup-vm2.sh
#
# This script will:
# - Update system packages
# - Install Docker and Docker Compose
# - Configure firewall for VM2 services
# - Clone the AIOps project
# - Start application and logging services
################################################################################

set -e

echo "=========================================="
echo "AIOps VM2 Setup - Application Servers"
echo "=========================================="

# Variables
PROJECT_PATH="/opt/aiops-project"
VM1_IP="${1:-192.168.112.130}"
REPO_URL="${2:-https://github.com/yourusername/aiops-platform.git}"

echo "VM1 IP: $VM1_IP"
echo "Project path: $PROJECT_PATH"
echo "Repository: $REPO_URL"

# Step 1: Update system
echo ""
echo "[1/7] Updating system packages..."
sudo dnf update -y
sudo dnf install -y git curl wget vim firewalld stress-ng

# Step 2: Enable and start firewalld
echo ""
echo "[2/7] Configuring firewall..."
sudo systemctl enable --now firewalld

# Step 3: Install Docker
echo ""
echo "[3/7] Installing Docker and Docker Compose..."
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker

# Step 4: Install Docker Compose
echo ""
echo "[4/7] Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Step 5: Add current user to docker group
echo ""
echo "[5/7] Adding user to docker group..."
sudo usermod -aG docker "$USER"
newgrp docker

# Step 6: Configure firewall for VM2
echo ""
echo "[6/7] Opening firewall ports for VM2 services..."
sudo firewall-cmd --permanent --add-port=4000/tcp   # Node app
sudo firewall-cmd --permanent --add-port=5000/tcp   # Python app
sudo firewall-cmd --permanent --add-port=22/tcp     # SSH
sudo firewall-cmd --reload

# Step 7: Clone and setup project
echo ""
echo "[7/7] Cloning AIOps project and starting services..."
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

# Create log directories
mkdir -p app/node-app/logs app/python-app/logs

# Update Promtail config for VM1 Loki
echo ""
echo "[7b/7] Updating Promtail config for VM1 ($VM1_IP)..."
sed -i "s|http://loki:3100|http://${VM1_IP}:3100|g" "$PROJECT_PATH/monitoring/promtail/promtail-config.yaml"

# Start services
cd "$PROJECT_PATH"
docker compose up -d --build node-app python-app promtail

echo ""
echo "=========================================="
echo "✅ VM2 Setup Complete!"
echo "=========================================="
echo ""
echo "Services running:"
echo "  - Node app: http://localhost:4000/api/hello"
echo "  - Python app: http://localhost:5000/api/hello"
echo "  - Promtail: logging agent (no web interface)"
echo ""
echo "Test the applications:"
echo "  curl http://localhost:4000/api/hello"
echo "  curl http://localhost:5000/api/hello"
echo "  curl http://localhost:4000/metrics"
echo "  curl http://localhost:5000/metrics"
echo ""
echo "To view logs:"
echo "  docker compose logs -f node-app"
echo "  docker compose logs -f python-app"
echo "  docker compose logs -f promtail"
echo ""
echo "Simulate errors for testing:"
echo "  curl http://localhost:4000/api/error"
echo "  curl http://localhost:5000/api/error"
echo ""

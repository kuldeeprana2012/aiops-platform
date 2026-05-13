#!/bin/bash

################################################################################
# AIOps Quick Start Script
# One-command setup for testing on a single machine
#
# Usage:
#   bash quick-start.sh
################################################################################

echo "=========================================="
echo "AIOps Quick Start (Single Machine)"
echo "=========================================="
echo ""

PROJECT_PATH="${1:-.}"

if [ ! -f "$PROJECT_PATH/docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found in $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

# Copy .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file"
fi

# Create log directories
mkdir -p app/node-app/logs app/python-app/logs

echo ""
echo "Starting all services..."
docker compose down 2>/dev/null || true
docker compose up -d --build

echo ""
echo "Waiting for services to start..."
sleep 10

echo ""
echo "=========================================="
echo "✅ Quick Start Complete!"
echo "=========================================="
echo ""
echo "Access the stack at:"
echo ""
echo "  📊 Grafana Dashboard:"
echo "     http://localhost:3000"
echo "     (username: admin, password: admin)"
echo ""
echo "  📈 Prometheus:"
echo "     http://localhost:9090"
echo ""
echo "  📋 Loki Logs:"
echo "     http://localhost:3100"
echo ""
echo "  🚨 Alertmanager:"
echo "     http://localhost:9093"
echo ""
echo "  🤖 AI Engine:"
echo "     http://localhost:8080/health"
echo ""
echo "  🟢 Node App (test):"
echo "     http://localhost:4000/api/hello"
echo "     http://localhost:4000/metrics"
echo ""
echo "  🔵 Python App (test):"
echo "     http://localhost:5000/api/hello"
echo "     http://localhost:5000/metrics"
echo ""
echo "Generate test incidents:"
echo "  cd scripts"
echo "  bash simulate-incidents.sh all"
echo ""
echo "View logs:"
echo "  docker compose logs -f"
echo ""

#!/bin/bash

################################################################################
# AIOps Health Check Script
# Run this to verify all services are running correctly
#
# Usage:
#   bash check-health.sh [vm1-ip] [vm2-ip]
################################################################################

VM1_IP="${1:-localhost}"
VM2_IP="${2:-localhost}"

echo "=========================================="
echo "AIOps Health Check"
echo "=========================================="
echo "VM1 IP: $VM1_IP"
echo "VM2 IP: $VM2_IP"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_endpoint() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -n "Checking $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_code" ] || [[ "$response" =~ ^[2-3][0-9][0-9]$ ]]; then
        echo -e "${GREEN}✓ OK (HTTP $response)${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED (HTTP $response)${NC}"
        return 1
    fi
}

echo -e "${YELLOW}VM1 Services (Monitoring Stack):${NC}"
check_endpoint "Prometheus" "http://$VM1_IP:9090/-/healthy"
check_endpoint "Grafana" "http://$VM1_IP:3000/api/health"
check_endpoint "Loki" "http://$VM1_IP:3100/ready"
check_endpoint "Alertmanager" "http://$VM1_IP:9093/-/healthy"
check_endpoint "AI Engine" "http://$VM1_IP:8080/health"

echo ""
echo -e "${YELLOW}VM2 Services (Application Servers):${NC}"
check_endpoint "Node App" "http://$VM2_IP:4000/api/hello"
check_endpoint "Node App Metrics" "http://$VM2_IP:4000/metrics"
check_endpoint "Python App" "http://$VM2_IP:5000/api/hello"
check_endpoint "Python App Metrics" "http://$VM2_IP:5000/metrics"

echo ""
echo -e "${YELLOW}Docker Containers:${NC}"
echo -n "Listing running containers... "
if command -v docker &> /dev/null; then
    CONTAINER_COUNT=$(docker ps -q | wc -l)
    echo -e "${GREEN}$CONTAINER_COUNT containers running${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | tail -n +2 || echo "Docker available but unable to list containers"
else
    echo -e "${RED}Docker not found${NC}"
fi

echo ""
echo -e "${YELLOW}Firewall Rules (current machine):${NC}"
if command -v firewall-cmd &> /dev/null; then
    echo "Active zones and ports:"
    sudo firewall-cmd --list-all 2>/dev/null || echo "Unable to read firewall rules"
else
    echo "firewall-cmd not available"
fi

echo ""
echo "=========================================="
echo "Health check complete!"
echo "=========================================="
echo ""

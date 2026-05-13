#!/bin/bash

################################################################################
# AIOps Test & Incident Simulation Script
# Run this on VM2 to simulate real incidents for testing the monitoring stack
#
# Usage:
#   bash simulate-incidents.sh [incident-type]
#
# Incident types:
#   - error-spike       : Generates 500 errors
#   - high-latency      : Slows down responses
#   - cpu-spike         : CPU stress test
#   - memory-spike      : Memory pressure
#   - log-errors        : Write error logs
#   - all               : Run all tests sequentially
################################################################################

set -e

PROJECT_PATH="/opt/aiops-project"
INCIDENT_TYPE="${1:-all}"

echo "=========================================="
echo "AIOps Incident Simulation"
echo "=========================================="
echo "Incident type: $INCIDENT_TYPE"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test Node app endpoint
echo -e "${YELLOW}[TEST] Testing Node app connectivity...${NC}"
if ! curl -s http://localhost:4000/api/hello > /dev/null; then
    echo -e "${RED}Error: Node app not responding${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node app OK${NC}"

# Test Python app endpoint
echo -e "${YELLOW}[TEST] Testing Python app connectivity...${NC}"
if ! curl -s http://localhost:5000/api/hello > /dev/null; then
    echo -e "${RED}Error: Python app not responding${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python app OK${NC}"

# Incident 1: Error Spike
incident_error_spike() {
    echo ""
    echo -e "${YELLOW}[INCIDENT 1] Triggering error spike...${NC}"
    for i in {1..50}; do
        curl -s http://localhost:4000/api/error > /dev/null &
        curl -s http://localhost:5000/api/error > /dev/null &
    done
    wait
    echo -e "${GREEN}✓ Error spike triggered (check Alertmanager in 5 minutes)${NC}"
}

# Incident 2: High Latency
incident_high_latency() {
    echo ""
    echo -e "${YELLOW}[INCIDENT 2] Triggering high latency...${NC}"
    echo "Holding connections for 30 seconds..."
    for i in {1..30}; do
        timeout 5 curl -s http://localhost:4000/api/hello > /dev/null &
        timeout 5 curl -s http://localhost:5000/api/hello > /dev/null &
        sleep 1
    done
    wait
    echo -e "${GREEN}✓ Latency test complete (check Grafana dashboard)${NC}"
}

# Incident 3: CPU Spike
incident_cpu_spike() {
    echo ""
    echo -e "${YELLOW}[INCIDENT 3] Triggering CPU spike (30 seconds)...${NC}"
    stress-ng --cpu 4 --timeout 30s &
    STRESS_PID=$!
    echo "Stress test running (PID: $STRESS_PID)"
    wait $STRESS_PID
    echo -e "${GREEN}✓ CPU spike completed${NC}"
}

# Incident 4: Memory Spike
incident_memory_spike() {
    echo ""
    echo -e "${YELLOW}[INCIDENT 4] Triggering memory spike (30 seconds)...${NC}"
    stress-ng --vm 2 --vm-bytes 500M --timeout 30s &
    STRESS_PID=$!
    echo "Memory stress test running (PID: $STRESS_PID)"
    wait $STRESS_PID
    echo -e "${GREEN}✓ Memory spike completed${NC}"
}

# Incident 5: Log Errors
incident_log_errors() {
    echo ""
    echo -e "${YELLOW}[INCIDENT 5] Writing error logs...${NC}"
    
    # Node app logs
    for i in {1..20}; do
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"ERROR\",\"message\":\"Simulated error event $i\",\"service\":\"node-app\",\"error_code\":\"ERR_$(printf "%04d" $i)\"}" >> "$PROJECT_PATH/app/node-app/logs/node-app.log"
    done
    
    # Python app logs
    for i in {1..20}; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR Simulated error event $i" >> "$PROJECT_PATH/app/python-app/logs/python-app.log"
    done
    
    echo -e "${GREEN}✓ Error logs written (check Loki in Grafana)${NC}"
}

# Run incidents
case "$INCIDENT_TYPE" in
    error-spike)
        incident_error_spike
        ;;
    high-latency)
        incident_high_latency
        ;;
    cpu-spike)
        incident_cpu_spike
        ;;
    memory-spike)
        incident_memory_spike
        ;;
    log-errors)
        incident_log_errors
        ;;
    all)
        incident_error_spike
        sleep 5
        incident_log_errors
        sleep 5
        incident_high_latency
        sleep 5
        incident_cpu_spike
        sleep 5
        incident_memory_spike
        ;;
    *)
        echo -e "${RED}Unknown incident type: $INCIDENT_TYPE${NC}"
        echo "Valid types: error-spike, high-latency, cpu-spike, memory-spike, log-errors, all"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=========================================="
echo "Incident simulation complete!"
echo "==========================================${NC}"
echo ""
echo "Check your monitoring stack:"
echo "  - Grafana: http://<vm1-ip>:3000"
echo "  - Prometheus: http://<vm1-ip>:9090"
echo "  - Loki: http://<vm1-ip>:3100"
echo "  - Alertmanager: http://<vm1-ip>:9093"
echo ""

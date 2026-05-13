# VM Setup and Deployment Guide

## VM roles

- **VM1 (ClientAIlocal)**: monitoring stack and AI engine
  - Prometheus, Grafana, Loki, Alertmanager, AI Engine
- **VM2 (ServerAIlocal)**: application servers and log collector
  - Node.js app, Python app, Promtail

## Network configuration

1. Use bridged or host-only networking in VMware.
2. Assign static IPs or DHCP reservations:
   - VM1 (ClientAIlocal): `192.168.112.130`
   - VM2 (ServerAIlocal): `192.168.112.132`
3. Open required ports in firewalld:
   - `9090/tcp` Prometheus
   - `3000/tcp` Grafana
   - `3100/tcp` Loki
   - `9093/tcp` Alertmanager
   - `8080/tcp` AI Engine
   - `4000/tcp` Node app
   - `5000/tcp` Python app

## Install base packages on both VMs

```bash
sudo dnf update -y
sudo dnf install -y git curl wget vim firewalld
sudo systemctl enable --now firewalld
```

## Install Docker and Docker Compose

```bash
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Restart your shell or log out/in after adding Docker group permission.

## VM1 deployment (monitoring + AI)

1. Clone repo to VM1:
   ```bash
   git clone <repo-url> /opt/aiops-project
   cd /opt/aiops-project
   cp .env.example .env
   ```
2. Set environment variables in `.env`.
3. Start the stack on VM1:
   ```bash
   docker compose up -d --build prometheus grafana loki alertmanager ai-engine
   ```
   If you want to run everything on a single VM for testing, you can also run:
   ```bash
   docker compose up -d --build
   ```
4. Verify services:
   - Prometheus: `http://192.168.112.130:9090`
   - Grafana: `http://192.168.112.130:3000`
   - Loki: `http://192.168.112.130:3100`
   - Alertmanager: `http://192.168.112.130:9093`
   - AI Engine: `http://192.168.112.130:8080/health`

## VM2 deployment (apps + Promtail)

1. Clone repo to VM2:
   ```bash
   git clone <repo-url> /opt/aiops-project
   cd /opt/aiops-project
   cp .env.example .env
   ```
2. Start the apps and log collector:
   ```bash
   docker compose up -d --build node-app python-app promtail
   ```
3. Confirm app endpoints:
   - `http://192.168.112.132:4000/api/hello`
   - `http://192.168.112.132:4000/api/error`
   - `http://192.168.112.132:5000/api/hello`
   - `http://192.168.112.132:5000/api/error`

## Port forwarding / firewall commands

```bash
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=3100/tcp
sudo firewall-cmd --permanent --add-port=9093/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=4000/tcp
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

## Validate connectivity

From VM1:
```bash
curl http://192.168.100.11:4000/metrics
curl http://192.168.100.11:5000/metrics
```

If the applications are running on VM2, update `monitoring/prometheus/prometheus.yml` to use the VM2 IP address for the `node_app` and `python_app` targets.

From VM2:
```bash
curl http://192.168.100.10:9090/targets
curl http://192.168.100.10:3100/metrics
```

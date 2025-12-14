# WeberQ Infrastructure Configuration

This repository manages the core infrastructure for the WeberQ Virtual Machine on Google Cloud Platform (GCP). It automates the setup of Docker, SSH keys, and the Traefik Reverse Proxy, enabling a "Push to Deploy" workflow for multiple applications.

## 🚀 Quick Start Guide

### 1. Create GCP Virtual Machine
1.  **Go to GCP Console** -> Compute Engine -> VM Instances.
2.  **Create Instance**:
    *   **Name**: `web1` (or your preferred name)
    *   **Region**: `us-central1` (or nearest to you)
    *   **Machine Type**: `e2-medium` (Recommended minimum for multiple apps) or `e2-micro` (Free tier, strictly for basic testing).
    *   **Boot Disk**: Ubuntu 24.04 LTS or Debian 12 (x86/64).
    *   **Firewall**: Check ✅ **Allow HTTP traffic** and ✅ **Allow HTTPS traffic**.
3.  **Static IP** (Optional but Recommended):
    *   VPC Network -> IP Addresses -> Reserve External Static IP.
    *   Attach it to your VM.

### 2. Initial Server Setup
Connect to the VM via the GCP Console "SSH" button.

1.  **Create the Deploy User**:
    ```bash
    sudo adduser weberqbot
    sudo usermod -aG sudo weberqbot
    ```
2.  **Switch to User**:
    ```bash
    su - weberqbot
    ```
3.  **Clone this Repository**:
    ```bash
    git clone https://github.com/weberq/infra-config.git
    cd infra-config
    ```
4.  **Initial Run**:
    ```bash
    chmod +x *.sh
    ./script.sh
    ```
    *This will install Docker and Generate SSH Keys.*

### 3. GitHub Authentication Setup
The server needs to authenticate with GitHub to pull private repositories.

1.  **Get the Public Key** (from server):
    ```bash
    cat ~/.ssh/id_rsa.pub
    ```
    *Add this to your GitHub Repository -> Settings -> Deploy Keys (or Account Settings -> SSH Keys).*

2.  **Get the Private Key** (from server):
    ```bash
    cat ~/.ssh/id_rsa
    ```
    *Add this to your `infra-config` Repository -> Settings -> Secrets -> Actions as `GCP_SSH_PRIVATE_KEY`.*

### 4. Configure `main.yml`
Update `.github/workflows/main.yml` in this repo:
*   `SSH_USER`: `weberqbot`
*   `INSTANCE_IP`: Your VM's Public IP (e.g., `136.113.227.185`)

---

## 📦 How to Deploy Applications
For every new PHP, Flask, or React app you want to host:

### 1. Dockerize the App
Add a `Dockerfile` and `docker-compose.yml` to your app's repo.
**Crucial Docker Compose Labels for Traefik:**
```yaml
services:
  web:
    image: my-app
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.weberq.in`)"
      - "traefik.http.routers.myapp.entrypoints=web"
      # REQUIRED: Tell Traefik which port your container listens on
      - "traefik.http.services.myapp.loadbalancer.server.port=80"
    networks:
      - web_network

networks:
  web_network:
    external: true
```

### 2. Add Deployment Workflow
Copy `deploy-app-template.yml` from this repo to `.github/workflows/deploy.yml` in your app's repo.
*   **Secrets Required in App Repo**:
    *   `VPS_HOST`: Your VM IP
    *   `VPS_USER`: `weberqbot`
    *   `VPS_SSH_KEY`: The same Private Key from Step 3.2.

---

## 🔧 Troubleshooting

### 1. "Client version 1.24 is too old"
**Issue**: Newer Docker Engines (v29+) reject connections from older Traefik versions (v2, v3.3).
**Fix**:
*   Use **`traefik:v3.6`** (or newer) in `docker-compose.yml`.
*   Add `DOCKER_API_VERSION=1.45` to the `environment` section of the Traefik service.

### 2. "Permission denied (publickey)" in GitHub Action
**Issue**: The Action cannot SSH into the server or the Server cannot pull from GitHub.
**Fix**:
*   Ensure `GCP_SSH_PRIVATE_KEY` (infra) or `VPS_SSH_KEY` (app) is set in GitHub Secrets.
*   Ensure the Public Key is in `~/.ssh/authorized_keys` for the `weberqbot` user on the VM (`cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`).

### 3. "404 Page Not Found"
**Issue**: Traefik receives the request but doesn't know where to send it.
**Fix**:
*   Verify the container is running: `docker ps`.
*   Verify the labels in `docker-compose.yml`.
*   **Crucial**: Add `traefik.http.services.APPNAME.loadbalancer.server.port=80` (or your app's port).

### 4. Deployment says "Already up to date" but changes aren't live
**Issue**: `git pull` worked, but Docker didn't recreate the container.
**Fix**: Force recreation on the server:
```bash
docker compose pull
docker compose up -d --force-recreate
```

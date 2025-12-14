#!/bin/bash

echo "🚀 Starting deployment process..."

# Define variables
PROJECT_DIR="/home/weberqbot/infra-config"

echo "📦 Pulling latest changes from Git..."
cd "$PROJECT_DIR" || { echo "❌ Failed to change directory."; exit 1; }

# Handle Git Pull
git pull || {
  echo "Git pull failed, attempting to add safe directory..."
  git config --global --add safe.directory "$PROJECT_DIR" && git pull || {
    echo "❌ Git pull failed again. Exiting."
    exit 1
  }
}

# 1. Setup Docker if not present
chmod +x setup_docker.sh
./setup_docker.sh

# 2. Setup SSH Keys (Optional, just ensures they exist)
chmod +x setup_keys.sh
./setup_keys.sh

# 3. Start/Update Traefik Reverse Proxy
echo "🚀 Starting Traefik Proxy..."
docker compose up -d --remove-orphans || { echo "❌ Failed to start Traefik"; exit 1; }

echo "✅ Deployment complete!"
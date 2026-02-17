#!/bin/bash

echo "🚀 Starting deployment process..."

# Define variables
PROJECT_DIR="$HOME/infra-config"

echo "📦 Pulling latest changes from Git..."
cd "$PROJECT_DIR" || { echo "❌ Failed to change directory."; exit 1; }

# Handle Git Pull
# Handle Git Pull (Force Clean to Avoid Conflicts)
echo "🔄 Syncing with remote..."
git config --global --add safe.directory "$PROJECT_DIR"
git fetch origin main
git reset --hard origin/main

# 1. Setup Docker if not present
chmod +x setup_docker.sh
./setup_docker.sh

# 2. Setup SSH Keys (Optional, just ensures they exist)
chmod +x setup_keys.sh
./setup_keys.sh

# 3. Start/Update Traefik Reverse Proxy
echo "🚀 Starting Traefik Proxy..."
# Check if user is in docker group but current shell doesn't have it active
if groups | grep -q '\bdocker\b'; then
    docker compose up -d --remove-orphans || { echo "❌ Failed to start Traefik"; exit 1; }
else
    # Try with 'sg' if user belongs to group but current shell doesn't have it active
    # This fixes the "permission denied" error on the very first run after installation
    echo "⚠️  User in docker group but session not updated. Using 'sg'..."
    sg docker -c "docker compose up -d --remove-orphans" || { echo "❌ Failed to start Traefik"; exit 1; }
fi

echo "✅ Deployment complete!"
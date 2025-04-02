#!/bin/bash

echo "🚀 Starting deployment process..."

# Define variables
PROJECT_DIR="/home/weberqbot/infra-config"

echo "📦 Pulling latest changes from Git..."
cd "$PROJECT_DIR" || { echo "❌ Failed to change directory."; exit 1; }

git pull || {
  echo "Git pull failed, attempting to add safe directory..."
  git config --global --add safe.directory "$PROJECT_DIR" && git pull || {
    echo "❌ Git pull failed again. Exiting."
    exit 1
  }
}

echo "✅ Deployment complete!"
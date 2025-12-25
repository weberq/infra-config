#!/bin/bash
# -----------------------------------------------------------
# PHP Project Scaffolding Tool (Linux/Mac)
# Usage: ./init.sh
# -----------------------------------------------------------

echo "🚀 WeberQ Infrastructure Scaffolding (PHP)"
echo "This script will generate your Docker config and GitHub Action."

# 1. Get Inputs
read -p "Enter Application Name (e.g., my-php-app): " APP_NAME
if [ -z "$APP_NAME" ]; then echo "❌ App Name is required."; exit 1; fi

read -p "Enter Domain Name (e.g., app.weberq.in): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then echo "❌ Domain Name is required."; exit 1; fi

# 2. Define Paths
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(pwd)"

# 3. Copy Dockerfile
echo -e "\n📄 Generating Dockerfile..."
cp "$SCRIPT_DIR/Dockerfile.template" "$PROJECT_ROOT/Dockerfile"
echo "   Done."

# 4. Process docker-compose.yml
echo "📄 Generating docker-compose.yml..."
sed -e "s/{{APP_NAME}}/$APP_NAME/g" \
    -e "s/{{DOMAIN_NAME}}/$DOMAIN_NAME/g" \
    "$SCRIPT_DIR/docker-compose.yml.template" > "$PROJECT_ROOT/docker-compose.yml"
echo "   Done (Configured for $DOMAIN_NAME)."

# 5. Process GitHub Workflow
echo "📄 Generating GitHub Workflow..."
mkdir -p "$PROJECT_ROOT/.github/workflows"
sed -e "s/{{APP_NAME}}/$APP_NAME/g" \
    "$SCRIPT_DIR/deploy.yml.template" > "$PROJECT_ROOT/.github/workflows/deploy.yml"
echo "   Done (Saved to .github/workflows/deploy.yml)."

echo -e "\n✅ Scaffolding Complete!"
echo "Next Steps:"
echo "1. Git Add/Commit/Push these new files."
echo "2. Add secrets (VPS_HOST, VPS_USER, VPS_SSH_KEY) to your GitHub Repo."

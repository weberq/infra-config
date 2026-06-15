#!/bin/bash
# -----------------------------------------------------------
# WeberQ PHP Infrastructure Scaffolding Tool (Production Safe)
# Usage: ./init.sh
# Linux/Mac counterpart of init.ps1 — keep the two in sync.
# -----------------------------------------------------------

echo ""
echo "WeberQ PHP Infrastructure Scaffolding (GHCR + SHA + Traefik)"
echo "----------------------------------------------------------------"

# 1. Inputs
read -p "Enter Application Name (e.g., my-php-app): " APP_NAME
if [ -z "$APP_NAME" ]; then echo "Error: App Name is required."; exit 1; fi

read -p "Enter Domain Name (e.g., stmorg.in or app.weberq.in): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then echo "Error: Domain Name is required."; exit 1; fi

read -p "Does this domain require www support? (y/n): " ENABLE_WWW

# GHCR image names must be lowercase
APP_NAME="$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')"

# 2. Build Traefik Rule (backticks backslash-escaped for the VPS bash deploy script)
BT='\`'
if [ "$ENABLE_WWW" = "y" ] || [ "$ENABLE_WWW" = "Y" ]; then
    TRAEFIK_RULE="Host(${BT}${DOMAIN_NAME}${BT}) || Host(${BT}www.${DOMAIN_NAME}${BT})"
else
    TRAEFIK_RULE="Host(${BT}${DOMAIN_NAME}${BT})"
fi

echo ""
echo "Configuration Summary:"
echo "  App Name : $APP_NAME"
echo "  Domain   : $DOMAIN_NAME"
echo "  Rule     : $TRAEFIK_RULE"
echo ""

# 3. Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(pwd)"
WORKFLOW_DIR="$PROJECT_ROOT/.github/workflows"

# 4. Create Dockerfile from template (idempotent — skip if present)
if [ ! -f "$PROJECT_ROOT/Dockerfile" ]; then
    cp "$SCRIPT_DIR/Dockerfile.template" "$PROJECT_ROOT/Dockerfile"
    echo "Dockerfile created from template."
else
    echo "Warning: Dockerfile already exists. Skipping."
fi

# 5. Create .dockerignore (from template + scaffolding excludes; skip if present)
if [ ! -f "$PROJECT_ROOT/.dockerignore" ]; then
    {
        cat "$SCRIPT_DIR/.dockerignore.template"
        printf '%s\n' 'init.sh' 'init.ps1' '*.template'
    } > "$PROJECT_ROOT/.dockerignore"
    echo ".dockerignore created."
else
    echo "Warning: .dockerignore already exists. Skipping."
fi

# 6. Create GitHub workflow from template.
#    Literal (non-regex) substitution via bash ${//} so the escaped backticks in
#    TRAEFIK_RULE pass through verbatim (sed would mangle the backslashes).
mkdir -p "$WORKFLOW_DIR"
TEMPLATE="$(cat "$SCRIPT_DIR/deploy.yml.template")"
TEMPLATE="${TEMPLATE//'{{APP_NAME}}'/$APP_NAME}"
TEMPLATE="${TEMPLATE//'{{TRAEFIK_RULE}}'/$TRAEFIK_RULE}"
printf '%s\n' "$TEMPLATE" > "$WORKFLOW_DIR/deploy.yml"
echo "GitHub workflow generated."

# 7. Final Instructions
echo ""
echo "Scaffolding Complete!"
echo "----------------------------------------------------------------"
echo "Next Steps:"
echo "1. git add ."
echo "2. git commit -m 'Infra setup'"
echo "3. git push"
echo ""
echo "Add these GitHub Secrets:"
echo "  VPS_HOST"
echo "  VPS_USER"
echo "  VPS_SSH_KEY"
echo "  GHCR_PAT (read:packages)"
echo ""
echo "IMPORTANT:"
echo "Cloudflare SSL Mode must be set to: Full"
echo ""

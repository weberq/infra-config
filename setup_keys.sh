#!/bin/bash

# Exit on error
set -e

KEY_PATH="$HOME/.ssh/id_rsa"

echo "🔑 Setting up SSH Keys for GitHub..."

if [ -f "$KEY_PATH" ]; then
    echo "✅ SSH Key already exists at $KEY_PATH"
else
    echo "📦 Generating new SSH Key..."
    mkdir -p "$HOME/.ssh"
    # Generate key non-interactively, no passphrase
    ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "server-deploy-key"
    echo "✅ Key generated."
fi

echo ""
echo "========================================================================"
echo "📢 ACTION REQUIRED: Copy the public key below and add it to GitHub:"
echo "   1. Go to your Repository -> Settings -> Deploy keys"
echo "   2. Click 'Add deploy key'"
echo "   3. Paste the key below and give it a title (e.g., 'GCP Server')"
echo "========================================================================"
echo ""
cat "${KEY_PATH}.pub"
echo ""
echo "========================================================================"
echo ""

# Optional: Add github.com to known hosts to prevent interactive prompt on first connection
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 2>/dev/null || true

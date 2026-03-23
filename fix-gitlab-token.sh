#!/bin/bash
# fix-gitlab-token.sh

echo "🔐 GitLab Token Fix Script"
echo "=========================="
echo ""

# Ask for new token
read -p "glpat-vWZxEF7BNuSvcqi9swmhbm86MQp1Omtra2RlCw.01.121w22r2v: " NEW_TOKEN

if [ -z "$NEW_TOKEN" ]; then
    echo "❌ No token provided. Exiting."
    exit 1
fi

# Update remote URL
echo "📝 Updating Git remote URL..."
git remote set-url origin "https://oauth2:${NEW_TOKEN}@gitlab.com/Ntseze-Nelvis/hsbc-gamma-3tier-image-platform.git"

# Verify
echo "✅ Remote URL updated:"
git remote -v

# Test connection
echo ""
echo "🔍 Testing connection..."
git fetch origin

if [ $? -eq 0 ]; then
    echo "✅ Connection successful!"
    echo ""
    echo "📤 Pushing your changes..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "✅ Push successful!"
    else
        echo "❌ Push failed. Please check your changes."
    fi
else
    echo "❌ Connection failed. Please verify your token."
fi
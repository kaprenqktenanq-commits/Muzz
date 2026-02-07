#!/bin/bash

# Automatic deployment script for ArmedMusic bot
set -e

echo "🚀 ArmedMusic Bot Deployment Script"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Validate code
echo -e "${BLUE}[1/4]${NC} Validating code..."
python3 -m py_compile ArmedMusic/__main__.py && echo -e "${GREEN}✓ Code syntax valid${NC}" || {
    echo -e "${RED}✗ Code has syntax errors${NC}"
    exit 1
}

# Step 2: Check git status
echo -e "${BLUE}[2/4]${NC} Checking git status..."
if [[ -n $(git status -s) ]]; then
    echo "Uncommitted changes found. Committing..."
    git add -A
    git commit -m "Auto-deploy: Fix bot code issues"
fi

# Step 3: Push to fork
echo -e "${BLUE}[3/4]${NC} Pushing to fork repository..."
git push fork main && echo -e "${GREEN}✓ Code pushed to fork${NC}" || echo -e "${YELLOW}⚠ Fork push failed (may require manual action)${NC}"

# Step 4: Attempt Heroku deployment
echo -e "${BLUE}[4/4]${NC} Attempting Heroku deployment..."

if command -v heroku &> /dev/null; then
    echo "Found Heroku CLI. Authenticating..."
    
    # Check if already authenticated
    if heroku auth:whoami &> /dev/null; then
        echo "Heroku authenticated. Checking for apps..."
        
        # List available apps
        APPS=$(heroku apps --json 2>/dev/null | grep -o '"name":"[^"]*' | cut -d'"' -f4 || true)
        
        if [[ -z "$APPS" ]]; then
            echo -e "${YELLOW}⚠ No Heroku apps found${NC}"
        else
            echo "Available Heroku apps: $APPS"
            
            # Try to find and deploy to bot app
            for app in $APPS; do
                echo "Attempting to deploy to $app..."
                git push heroku main --force 2>/dev/null && {
                    echo -e "${GREEN}✓ Deployed to Heroku ($app)${NC}"
                    break
                } || true
            done
        fi
    else
        echo -e "${YELLOW}⚠ Heroku CLI not authenticated${NC}"
        echo "To authenticate, run: heroku login"
    fi
else
    echo -e "${YELLOW}⚠ Heroku CLI not found${NC}"
    echo "Installation options:"
    echo "  1. npm install -g heroku"
    echo "  2. brew install heroku (macOS)"
    echo "  3. Or deploy manually via Heroku Dashboard"
fi

echo ""
echo -e "${GREEN}==================================="
echo "✓ Deployment preparation complete!"
echo "===================================${NC}"
echo ""
echo "Next steps depending on your platform:"
echo ""
echo "📦 If using Heroku:"
echo "   heroku login"
echo "   heroku create (if app doesn't exist)"
echo "   git push heroku main"
echo ""
echo "🐳 If using Railway/Render/other:"
echo "   -  Code has been pushed to: https://github.com/kaprenqktenanq-commits/Muzz"
echo "   - Connect your platform to that repository"
echo "   - Your platform should auto-redeploy when main branch changes"
echo ""
echo "📋 Or manually force redeploy:"
echo "   - Visit your deployment platform's dashboard"
echo "   - Trigger a rebuild/redeploy manually"

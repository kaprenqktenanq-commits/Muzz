#!/bin/bash

# Fork Sync Script - Синхронизация fork с оригинальным репозиторием
# Использование: bash sync-fork.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔄 FORK SYNCHRONIZATION SCRIPT       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

# 1. Fetch upstream
echo -e "\n${BLUE}[1/4]${NC} Fetching from upstream..."
git fetch upstream main 2>/dev/null || {
    echo -e "${YELLOW}Adding upstream remote...${NC}"
    git remote add upstream https://github.com/barevbalikape0-lab/Muzz.git
    git fetch upstream main
}
echo -e "${GREEN}✓ Fetch complete${NC}"

# 2. Check status
echo -e "\n${BLUE}[2/4]${NC} Checking fork status..."
BEHIND=$(git rev-list --left-only --count upstream/main...main 2>/dev/null || echo 0)
AHEAD=$(git rev-list --right-only --count upstream/main...main 2>/dev/null || echo 0)

if [ "$BEHIND" -eq 0 ]; then
    echo -e "${GREEN}✓ Fork is up to date with upstream${NC}"
else
    echo -e "${YELLOW}⚠ Fork is $BEHIND commits behind${NC}"
fi

if [ "$AHEAD" -gt 0 ]; then
    echo -e "${GREEN}✓ Fork is $AHEAD commits ahead (your fixes)${NC}"
fi

# 3. Merge if needed
echo -e "\n${BLUE}[3/4]${NC} Merging changes..."
if git merge --no-edit upstream/main -m "Sync fork with upstream"; then
    echo -e "${GREEN}✓ Merge successful${NC}"
else
    echo -e "${YELLOW}⚠ Already up to date or merge completed${NC}"
fi

# 4. Push to fork
echo -e "\n${BLUE}[4/4]${NC} Pushing to fork..."
if git push fork main; then
    echo -e "${GREEN}✓ Pushed to fork${NC}"
else
    echo -e "${YELLOW}⚠ Push result: check git status${NC}"
fi

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}✅ FORK SYNC COMPLETE${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

echo -e "\n${BLUE}Summary:${NC}"
git log --oneline -3
echo ""
git status --short

echo -e "\n${BLUE}Fork status:${NC}"
echo "  Upstream: https://github.com/barevbalikape0-lab/Muzz"
echo "  Fork:     https://github.com/kaprenqktenanq-commits/Muzz"

#!/bin/bash
# Environment Validation Script
# Addresses: "What happens when the first dev agent gets stuck installing npm?"
# - Forsaken-Promise-269
#
# Run this BEFORE starting any Loki Mode session to ensure environment is ready.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}Validating development environment...${NC}"
echo "============================================"

# ============================================
# REQUIRED: Node.js
# ============================================

echo -n "Node.js: "
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | sed 's/v//')
    NODE_MAJOR="${NODE_VERSION%%.*}"
    if [[ "$NODE_MAJOR" -lt 18 ]]; then
        echo -e "${RED}v${NODE_VERSION} (requires >= 18)${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}v${NODE_VERSION}${NC}"
    fi
else
    echo -e "${RED}NOT INSTALLED${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ============================================
# REQUIRED: npm
# ============================================

echo -n "npm: "
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}v${NPM_VERSION}${NC}"
else
    echo -e "${RED}NOT INSTALLED${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ============================================
# REQUIRED: Git
# ============================================

echo -n "Git: "
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | sed 's/git version //')
    echo -e "${GREEN}v${GIT_VERSION}${NC}"
else
    echo -e "${RED}NOT INSTALLED${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ============================================
# OPTIONAL: Package managers
# ============================================

echo -n "yarn: "
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn -v)
    echo -e "${GREEN}v${YARN_VERSION}${NC}"
else
    echo -e "${YELLOW}not installed (optional)${NC}"
fi

echo -n "pnpm: "
if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm -v)
    echo -e "${GREEN}v${PNPM_VERSION}${NC}"
else
    echo -e "${YELLOW}not installed (optional)${NC}"
fi

# ============================================
# OPTIONAL: Other tools
# ============================================

echo -n "Docker: "
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        DOCKER_VERSION=$(docker --version | sed 's/Docker version //' | cut -d',' -f1)
        echo -e "${GREEN}v${DOCKER_VERSION}${NC}"
    else
        echo -e "${YELLOW}installed but not running${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}not installed (optional)${NC}"
fi

echo -n "jq: "
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}${JQ_VERSION}${NC}"
else
    echo -e "${YELLOW}not installed (recommended)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# ============================================
# DISK SPACE
# ============================================

echo ""
echo -n "Disk space: "
if command -v df &> /dev/null; then
    # Get available space in GB (works on both Linux and macOS)
    if [[ "$(uname)" == "Darwin" ]]; then
        AVAILABLE_KB=$(df -k . | tail -1 | awk '{print $4}')
    else
        AVAILABLE_KB=$(df -k . | tail -1 | awk '{print $4}')
    fi
    AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))

    if [[ "$AVAILABLE_GB" -lt 2 ]]; then
        echo -e "${RED}${AVAILABLE_GB}GB available (requires >= 2GB)${NC}"
        ERRORS=$((ERRORS + 1))
    elif [[ "$AVAILABLE_GB" -lt 5 ]]; then
        echo -e "${YELLOW}${AVAILABLE_GB}GB available (recommended >= 5GB)${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}${AVAILABLE_GB}GB available${NC}"
    fi
else
    echo -e "${YELLOW}could not check${NC}"
fi

# ============================================
# WRITE PERMISSIONS
# ============================================

echo -n "Write permissions: "
if [[ -w "." ]]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}NO WRITE ACCESS${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ============================================
# NETWORK CONNECTIVITY (optional)
# ============================================

echo -n "Network (npm registry): "
if command -v curl &> /dev/null; then
    if curl -s --connect-timeout 5 https://registry.npmjs.org/ > /dev/null 2>&1; then
        echo -e "${GREEN}reachable${NC}"
    else
        echo -e "${YELLOW}unreachable (may cause issues)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}could not check (curl not found)${NC}"
fi

# ============================================
# SUMMARY
# ============================================

echo ""
echo "============================================"

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}FAILED: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Fix the errors above before running Loki Mode."
    echo ""
    echo "Quick fixes:"
    echo "  Node.js: curl -fsSL https://fnm.vercel.app/install | bash && fnm install 20"
    echo "  npm: Comes with Node.js"
    echo "  Git: apt-get install git / brew install git"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}PASSED with $WARNINGS warning(s)${NC}"
    echo "Environment is usable but some features may be limited."
    exit 0
else
    echo -e "${GREEN}PASSED: Environment is ready${NC}"
    exit 0
fi

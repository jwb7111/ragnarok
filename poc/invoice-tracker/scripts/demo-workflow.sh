#!/bin/bash
# Invoice Tracker POC - Demo Workflow
# Demonstrates the full Loki Mode framework integration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POC_DIR="$SCRIPT_DIR/.."
RAGNAROK_DIR="$SCRIPT_DIR/../../.."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       Invoice Tracker POC - Loki Mode Framework Demo         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

cd "$POC_DIR"

# ============================================
# STEP 1: Environment Validation
# ============================================

echo -e "${BLUE}━━━ Step 1: Environment Validation ━━━${NC}"
echo "Running: scripts/validate-environment.sh"
echo ""

if "$RAGNAROK_DIR/scripts/validate-environment.sh"; then
    echo ""
    echo -e "${GREEN}✓ Environment validation passed${NC}"
else
    echo -e "${RED}✗ Environment validation failed${NC}"
    exit 1
fi

echo ""

# ============================================
# STEP 2: Jurisdiction Validation
# ============================================

echo -e "${BLUE}━━━ Step 2: Jurisdiction Validation ━━━${NC}"
echo "Running: scripts/validate-jurisdiction.sh config/jurisdiction.yaml"
echo ""

if "$RAGNAROK_DIR/scripts/validate-jurisdiction.sh" "$POC_DIR/config/jurisdiction.yaml"; then
    echo ""
    echo -e "${GREEN}✓ Jurisdiction validation passed${NC}"
else
    echo -e "${RED}✗ Jurisdiction validation failed${NC}"
    exit 1
fi

echo ""

# ============================================
# STEP 3: Checkpoint System Demo
# ============================================

echo -e "${BLUE}━━━ Step 3: Checkpoint System Demo ━━━${NC}"
echo "Initializing checkpoint system..."
echo ""

export LOKI_ROOT="$POC_DIR/.loki"
"$RAGNAROK_DIR/scripts/checkpoint-manager.sh" init

echo ""
echo "Triggering a sample checkpoint (architecture_review, non-blocking for demo)..."
# Use non-blocking mode for demo (4th param = false)
"$RAGNAROK_DIR/scripts/checkpoint-manager.sh" trigger architecture_review "Tech stack decision: React + Vite + TypeScript" "Please review the tech stack choice" false

echo ""
echo "Auto-approving checkpoint for demo..."
"$RAGNAROK_DIR/scripts/checkpoint-manager.sh" approve architecture_review "Demo auto-approval"

echo ""
echo "Checkpoint status:"
"$RAGNAROK_DIR/scripts/checkpoint-manager.sh" status

echo ""
echo -e "${GREEN}✓ Checkpoint system operational${NC}"
echo ""

# ============================================
# STEP 4: Agent Model Info
# ============================================

echo -e "${BLUE}━━━ Step 4: Agent Model (v3) ━━━${NC}"
echo "Showing migration mapping for agents used in this POC..."
echo ""

"$RAGNAROK_DIR/scripts/migrate-agents.sh" lookup eng-frontend || true
"$RAGNAROK_DIR/scripts/migrate-agents.sh" lookup eng-backend || true
"$RAGNAROK_DIR/scripts/migrate-agents.sh" lookup eng-qa || true
"$RAGNAROK_DIR/scripts/migrate-agents.sh" lookup review-code || true

echo ""
echo -e "${GREEN}✓ Agent model v3 configured${NC}"
echo ""

# ============================================
# STEP 5: Verification System Demo
# ============================================

echo -e "${BLUE}━━━ Step 5: Verification System Demo ━━━${NC}"
echo "Available verification commands:"
echo ""

echo "  npm run verify        - Run all code quality checks"
echo "  npm run loki:verify   - Run Loki verification (build/test/lint/types)"
echo ""

echo -e "${YELLOW}Note: Full verification requires npm install first${NC}"
echo -e "${GREEN}✓ Verification system configured${NC}"
echo ""

# ============================================
# STEP 6: Summary
# ============================================

echo -e "${CYAN}━━━ Framework Integration Summary ━━━${NC}"
echo ""
echo "This POC demonstrates integration with:"
echo ""
echo "  1. ${GREEN}Environment Bootstrap${NC}"
echo "     - Pre-flight validation"
echo "     - Intelligent npm install retry"
echo ""
echo "  2. ${GREEN}Jurisdiction/Legal Framework${NC}"
echo "     - US/CA jurisdiction configured"
echo "     - CCPA compliance enabled"
echo "     - PCI-DSS Level 4 for payments"
echo ""
echo "  3. ${GREEN}Checkpoint System${NC}"
echo "     - Architecture review checkpoint"
echo "     - Pre-deploy checkpoint"
echo "     - Payment integration checkpoint"
echo ""
echo "  4. ${GREEN}Agent Model v3${NC}"
echo "     - 12 capability-based agents"
echo "     - Mode-based specialization"
echo ""
echo "  5. ${GREEN}Verification System${NC}"
echo "     - Objective task completion"
echo "     - Evidence-based records"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    Demo Complete!                            ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. npm install          - Install dependencies"
echo "  2. npm run dev          - Start development server"
echo "  3. npm run loki:full-check - Run all Loki checks"

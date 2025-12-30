#!/bin/bash
# Project Bootstrap Script
# Handles dependency installation with intelligent retry logic
#
# Addresses: "What happens when the first dev agent gets stuck installing npm?"
# - Forsaken-Promise-269

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
LOG_DIR="${LOKI_ROOT:-.loki}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"
    echo -e "$*"
}

log_error() {
    echo "[$(date -Iseconds)] ERROR: $*" >> "$LOG_FILE"
    echo -e "${RED}ERROR: $*${NC}"
}

log_success() {
    echo "[$(date -Iseconds)] SUCCESS: $*" >> "$LOG_FILE"
    echo -e "${GREEN}SUCCESS: $*${NC}"
}

# ============================================
# STEP 1: Validate Environment
# ============================================

log "${BLUE}Step 1: Validating environment...${NC}"

if [[ -f "$SCRIPT_DIR/validate-environment.sh" ]]; then
    if ! "$SCRIPT_DIR/validate-environment.sh"; then
        log_error "Environment validation failed. See above for details."
        exit 1
    fi
else
    log "${YELLOW}Warning: validate-environment.sh not found, skipping validation${NC}"
fi

# ============================================
# STEP 2: Detect Package Manager
# ============================================

cd "$PROJECT_DIR"
log "${BLUE}Step 2: Detecting package manager in $(pwd)...${NC}"

detect_package_manager() {
    if [[ -f "pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "bun.lockb" ]]; then
        echo "bun"
    elif [[ -f "package-lock.json" ]]; then
        echo "npm"
    elif [[ -f "package.json" ]]; then
        echo "npm"  # Default to npm if package.json exists
    else
        echo "none"
    fi
}

PKG_MANAGER=$(detect_package_manager)
log "Detected package manager: $PKG_MANAGER"

if [[ "$PKG_MANAGER" == "none" ]]; then
    log_error "No package.json found in $PROJECT_DIR"
    exit 1
fi

# ============================================
# STEP 3: Install Dependencies with Retry
# ============================================

log "${BLUE}Step 3: Installing dependencies...${NC}"

install_with_npm() {
    local attempt=1
    local max_attempts=4

    while [[ $attempt -le $max_attempts ]]; do
        log "npm install attempt $attempt/$max_attempts"

        case $attempt in
            1)
                # Normal install
                if npm install 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            2)
                # Clear cache and retry
                log "Clearing npm cache..."
                npm cache clean --force 2>&1 | tee -a "$LOG_FILE"
                if npm install 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            3)
                # Delete node_modules and lockfile, retry with legacy deps
                log "Removing node_modules and package-lock.json..."
                rm -rf node_modules package-lock.json
                if npm install --legacy-peer-deps 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            4)
                # Last resort: try different package manager
                if command -v yarn &> /dev/null; then
                    log "Falling back to yarn..."
                    rm -rf node_modules
                    if yarn install 2>&1 | tee -a "$LOG_FILE"; then
                        return 0
                    fi
                elif command -v pnpm &> /dev/null; then
                    log "Falling back to pnpm..."
                    rm -rf node_modules
                    if pnpm install 2>&1 | tee -a "$LOG_FILE"; then
                        return 0
                    fi
                fi
                ;;
        esac

        attempt=$((attempt + 1))
        if [[ $attempt -le $max_attempts ]]; then
            log "${YELLOW}Attempt $((attempt-1)) failed, trying next strategy...${NC}"
            sleep 2
        fi
    done

    return 1
}

install_with_yarn() {
    local attempt=1
    local max_attempts=3

    while [[ $attempt -le $max_attempts ]]; do
        log "yarn install attempt $attempt/$max_attempts"

        case $attempt in
            1)
                if yarn install 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            2)
                log "Clearing yarn cache..."
                yarn cache clean 2>&1 | tee -a "$LOG_FILE"
                rm -rf node_modules
                if yarn install 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            3)
                # Fall back to npm
                if command -v npm &> /dev/null; then
                    log "Falling back to npm..."
                    rm -rf node_modules yarn.lock
                    if npm install 2>&1 | tee -a "$LOG_FILE"; then
                        return 0
                    fi
                fi
                ;;
        esac

        attempt=$((attempt + 1))
        sleep 2
    done

    return 1
}

install_with_pnpm() {
    local attempt=1
    local max_attempts=3

    while [[ $attempt -le $max_attempts ]]; do
        log "pnpm install attempt $attempt/$max_attempts"

        case $attempt in
            1)
                if pnpm install 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            2)
                log "Clearing pnpm store..."
                pnpm store prune 2>&1 | tee -a "$LOG_FILE"
                rm -rf node_modules
                if pnpm install 2>&1 | tee -a "$LOG_FILE"; then
                    return 0
                fi
                ;;
            3)
                # Fall back to npm
                if command -v npm &> /dev/null; then
                    log "Falling back to npm..."
                    rm -rf node_modules pnpm-lock.yaml
                    if npm install 2>&1 | tee -a "$LOG_FILE"; then
                        return 0
                    fi
                fi
                ;;
        esac

        attempt=$((attempt + 1))
        sleep 2
    done

    return 1
}

# Run the appropriate installer
case "$PKG_MANAGER" in
    npm)
        if ! install_with_npm; then
            log_error "All npm install attempts failed. See $LOG_FILE for details."
            exit 1
        fi
        ;;
    yarn)
        if ! install_with_yarn; then
            log_error "All yarn install attempts failed. See $LOG_FILE for details."
            exit 1
        fi
        ;;
    pnpm)
        if ! install_with_pnpm; then
            log_error "All pnpm install attempts failed. See $LOG_FILE for details."
            exit 1
        fi
        ;;
esac

# ============================================
# STEP 4: Verify Installation
# ============================================

log "${BLUE}Step 4: Verifying installation...${NC}"

if [[ ! -d "node_modules" ]]; then
    log_error "node_modules directory not created"
    exit 1
fi

# Count installed packages
PKG_COUNT=$(find node_modules -maxdepth 1 -type d | wc -l)
log "Installed approximately $((PKG_COUNT - 1)) packages"

# ============================================
# STEP 5: Run Post-Install Checks
# ============================================

log "${BLUE}Step 5: Running post-install checks...${NC}"

# Check if we can run basic commands
if [[ -f "package.json" ]]; then
    # Check for common scripts
    if command -v jq &> /dev/null; then
        SCRIPTS=$(jq -r '.scripts // {} | keys[]' package.json 2>/dev/null || echo "")
    else
        SCRIPTS=$(grep -A 100 '"scripts"' package.json | grep -E '^\s*"[^"]+":' | head -10 | sed 's/.*"\([^"]*\)".*/\1/' || echo "")
    fi

    if [[ -n "$SCRIPTS" ]]; then
        log "Available npm scripts:"
        echo "$SCRIPTS" | while read -r script; do
            log "  - npm run $script"
        done
    fi
fi

# ============================================
# COMPLETE
# ============================================

log_success "Project bootstrap complete!"
log "Log file: $LOG_FILE"

# Create bootstrap marker
mkdir -p "${LOKI_ROOT:-.loki}/validation"
cat > "${LOKI_ROOT:-.loki}/validation/bootstrap.json" << EOF
{
  "bootstrapped_at": "$(date -Iseconds)",
  "project_dir": "$(pwd)",
  "package_manager": "$PKG_MANAGER",
  "packages_installed": $((PKG_COUNT - 1)),
  "log_file": "$LOG_FILE",
  "status": "success"
}
EOF

log "Bootstrap marker created: ${LOKI_ROOT:-.loki}/validation/bootstrap.json"

#!/bin/bash
# Checkpoint Manager for Loki Mode Human-in-the-Loop System
# Handles checkpoint triggering, waiting, and approval verification

set -euo pipefail

LOKI_ROOT="${LOKI_ROOT:-.loki}"
CHECKPOINT_DIR="$LOKI_ROOT/checkpoints"
CONFIG_FILE="${CHECKPOINT_CONFIG:-templates/checkpoints/checkpoints.yaml}"
LOG_FILE="$LOKI_ROOT/logs/checkpoint-decisions.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize checkpoint directory
init_checkpoints() {
    mkdir -p "$CHECKPOINT_DIR"
    mkdir -p "$LOKI_ROOT/logs"
    mkdir -p "$LOKI_ROOT/reports/comprehension"
    echo "[$(date -Iseconds)] Checkpoint system initialized" >> "$LOG_FILE"
}

# Log a checkpoint event
log_checkpoint() {
    local checkpoint_name="$1"
    local action="$2"
    local details="${3:-}"
    echo "[$(date -Iseconds)] [$checkpoint_name] $action - $details" >> "$LOG_FILE"
}

# Create a checkpoint waiting file
create_checkpoint() {
    local checkpoint_name="$1"
    local description="$2"
    local prompt="$3"
    local approval_file="$CHECKPOINT_DIR/${checkpoint_name}.approved"

    # Create waiting notification
    cat > "$CHECKPOINT_DIR/WAITING_FOR_APPROVAL.md" << EOF
# Checkpoint: $checkpoint_name

**Status:** WAITING FOR APPROVAL
**Created:** $(date -Iseconds)

## Description
$description

## Required Action
$prompt

## How to Approve

Create the approval file:
\`\`\`bash
touch $approval_file
\`\`\`

Or with confirmation:
\`\`\`bash
echo "APPROVED by [your name] at $(date)" > $approval_file
\`\`\`

## How to Reject

Create a rejection file to stop the process:
\`\`\`bash
echo "REJECTED: [reason]" > $CHECKPOINT_DIR/${checkpoint_name}.rejected
\`\`\`

---
*This checkpoint was created by Loki Mode's Human-in-the-Loop system.*
EOF

    log_checkpoint "$checkpoint_name" "CREATED" "Waiting for approval"
    echo -e "${YELLOW}[CHECKPOINT]${NC} $checkpoint_name - Waiting for approval"
    echo -e "${BLUE}Approval file:${NC} $approval_file"
}

# Check if a checkpoint is approved
check_approval() {
    local checkpoint_name="$1"
    local approval_file="$CHECKPOINT_DIR/${checkpoint_name}.approved"
    local rejection_file="$CHECKPOINT_DIR/${checkpoint_name}.rejected"

    # Check for rejection first
    if [[ -f "$rejection_file" ]]; then
        log_checkpoint "$checkpoint_name" "REJECTED" "$(cat "$rejection_file")"
        echo -e "${RED}[REJECTED]${NC} $checkpoint_name"
        return 2
    fi

    # Check for approval
    if [[ -f "$approval_file" ]]; then
        log_checkpoint "$checkpoint_name" "APPROVED" "$(cat "$approval_file" 2>/dev/null || echo 'no message')"
        echo -e "${GREEN}[APPROVED]${NC} $checkpoint_name"
        # Clean up waiting file
        rm -f "$CHECKPOINT_DIR/WAITING_FOR_APPROVAL.md"
        return 0
    fi

    return 1
}

# Wait for checkpoint approval (blocking)
wait_for_approval() {
    local checkpoint_name="$1"
    local timeout_seconds="${2:-0}"  # 0 = wait forever
    local elapsed=0
    local check_interval=5

    echo -e "${YELLOW}[WAITING]${NC} Checkpoint: $checkpoint_name"

    while true; do
        check_approval "$checkpoint_name"
        local result=$?

        if [[ $result -eq 0 ]]; then
            return 0
        elif [[ $result -eq 2 ]]; then
            # Rejected
            return 1
        fi

        # Check timeout
        if [[ $timeout_seconds -gt 0 && $elapsed -ge $timeout_seconds ]]; then
            log_checkpoint "$checkpoint_name" "TIMEOUT" "Auto-proceeding after ${timeout_seconds}s"
            echo -e "${YELLOW}[TIMEOUT]${NC} Auto-proceeding after ${timeout_seconds}s"
            return 0
        fi

        sleep $check_interval
        elapsed=$((elapsed + check_interval))

        # Show waiting message every minute
        if [[ $((elapsed % 60)) -eq 0 ]]; then
            echo -e "${BLUE}[WAITING]${NC} Still waiting for approval... (${elapsed}s elapsed)"
        fi
    done
}

# Trigger a checkpoint and wait
trigger_checkpoint() {
    local checkpoint_name="$1"
    local description="$2"
    local prompt="$3"
    local blocking="${4:-true}"
    local timeout="${5:-0}"

    # Check for emergency skip
    if [[ -n "${LOKI_SKIP_CHECKPOINTS:-}" ]]; then
        log_checkpoint "$checkpoint_name" "SKIPPED" "Emergency skip via LOKI_SKIP_CHECKPOINTS"
        echo -e "${YELLOW}[SKIPPED]${NC} $checkpoint_name (emergency skip)"
        return 0
    fi

    # Create the checkpoint
    create_checkpoint "$checkpoint_name" "$description" "$prompt"

    # If blocking, wait for approval
    if [[ "$blocking" == "true" ]]; then
        wait_for_approval "$checkpoint_name" "$timeout"
        return $?
    fi

    # Non-blocking: just log and continue
    log_checkpoint "$checkpoint_name" "TRIGGERED" "Non-blocking checkpoint"
    return 0
}

# List all pending checkpoints
list_pending() {
    echo -e "${BLUE}Pending Checkpoints:${NC}"

    local found=false
    for waiting_file in "$CHECKPOINT_DIR"/WAITING_*.md; do
        if [[ -f "$waiting_file" ]]; then
            found=true
            echo "  - $(basename "$waiting_file" .md)"
        fi
    done

    if [[ "$found" == "false" ]]; then
        echo "  (none)"
    fi
}

# List all checkpoint decisions
list_decisions() {
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${BLUE}Recent Checkpoint Decisions:${NC}"
        tail -20 "$LOG_FILE"
    else
        echo "No checkpoint decisions logged yet."
    fi
}

# Clear a specific checkpoint (admin)
clear_checkpoint() {
    local checkpoint_name="$1"
    rm -f "$CHECKPOINT_DIR/${checkpoint_name}.approved"
    rm -f "$CHECKPOINT_DIR/${checkpoint_name}.rejected"
    rm -f "$CHECKPOINT_DIR/WAITING_FOR_APPROVAL.md"
    log_checkpoint "$checkpoint_name" "CLEARED" "Admin action"
    echo -e "${GREEN}[CLEARED]${NC} $checkpoint_name"
}

# Approve a checkpoint via CLI
approve() {
    local checkpoint_name="$1"
    local message="${2:-Approved via CLI}"
    local approval_file="$CHECKPOINT_DIR/${checkpoint_name}.approved"

    echo "APPROVED: $message at $(date -Iseconds)" > "$approval_file"
    echo -e "${GREEN}[APPROVED]${NC} $checkpoint_name"
}

# Reject a checkpoint via CLI
reject() {
    local checkpoint_name="$1"
    local reason="${2:-Rejected via CLI}"
    local rejection_file="$CHECKPOINT_DIR/${checkpoint_name}.rejected"

    echo "REJECTED: $reason at $(date -Iseconds)" > "$rejection_file"
    echo -e "${RED}[REJECTED]${NC} $checkpoint_name - $reason"
}

# Generate checkpoint status report
status_report() {
    cat << EOF
# Checkpoint System Status

**Generated:** $(date -Iseconds)

## Configuration
- Config File: $CONFIG_FILE
- Checkpoint Dir: $CHECKPOINT_DIR
- Log File: $LOG_FILE

## Pending Checkpoints
EOF

    shopt -s nullglob
    for waiting_file in "$CHECKPOINT_DIR"/WAITING_*.md; do
        if [[ -f "$waiting_file" ]]; then
            echo "- $(basename "$waiting_file" .md)"
        fi
    done
    shopt -u nullglob

    echo ""
    echo "## Recent Activity"
    if [[ -f "$LOG_FILE" ]]; then
        echo '```'
        tail -10 "$LOG_FILE"
        echo '```'
    else
        echo "(no activity)"
    fi
}

# Main command handler
main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        init)
            init_checkpoints
            ;;
        trigger)
            trigger_checkpoint "$@"
            ;;
        check)
            check_approval "$1"
            ;;
        wait)
            wait_for_approval "$@"
            ;;
        approve)
            approve "$@"
            ;;
        reject)
            reject "$@"
            ;;
        clear)
            clear_checkpoint "$1"
            ;;
        list)
            list_pending
            ;;
        decisions)
            list_decisions
            ;;
        status)
            status_report
            ;;
        help|*)
            cat << EOF
Checkpoint Manager - Human-in-the-Loop System

Usage: checkpoint-manager.sh <command> [args]

Commands:
  init                          Initialize checkpoint system
  trigger <name> <desc> <prompt> [blocking] [timeout]
                                Trigger a checkpoint
  check <name>                  Check if checkpoint is approved
  wait <name> [timeout]         Wait for checkpoint approval
  approve <name> [message]      Approve a checkpoint via CLI
  reject <name> [reason]        Reject a checkpoint via CLI
  clear <name>                  Clear a checkpoint (admin)
  list                          List pending checkpoints
  decisions                     Show recent checkpoint decisions
  status                        Generate status report
  help                          Show this help

Environment Variables:
  LOKI_ROOT                     Root directory for .loki (default: .loki)
  CHECKPOINT_CONFIG             Path to checkpoint config (default: templates/checkpoints/checkpoints.yaml)
  LOKI_SKIP_CHECKPOINTS         Set to skip all checkpoints (emergency)

Examples:
  # Initialize
  ./checkpoint-manager.sh init

  # Trigger architecture review checkpoint
  ./checkpoint-manager.sh trigger architecture_review "Review architecture" "Please review..."

  # Approve via CLI
  ./checkpoint-manager.sh approve architecture_review "Looks good"

  # Check status
  ./checkpoint-manager.sh status
EOF
            ;;
    esac
}

main "$@"

#!/bin/bash
# Agent Migration Script
# Migrates from 37 role-based agents (v2) to 12 capability-based agents (v3)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
LOKI_ROOT="${LOKI_ROOT:-.loki}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Migration mapping (v2 -> v3)
declare -A MIGRATION_MAP=(
    # Engineering
    ["eng-frontend"]="implementer:frontend"
    ["eng-backend"]="implementer:backend"
    ["eng-database"]="implementer:database"
    ["eng-mobile"]="implementer:mobile"
    ["eng-api"]="implementer:backend"
    ["eng-qa"]="tester:unit"
    ["eng-perf"]="optimizer:performance"
    ["eng-infra"]="implementer:infrastructure"

    # Operations
    ["ops-devops"]="deployer:ci_cd"
    ["ops-sre"]="deployer:release"
    ["ops-security"]="compliance:security"
    ["ops-monitor"]="deployer:cloud"
    ["ops-incident"]="deployer:release"
    ["ops-release"]="deployer:release"
    ["ops-cost"]="optimizer:cost"
    ["ops-compliance"]="compliance:regulatory"

    # Business
    ["biz-marketing"]="communicator:marketing"
    ["biz-sales"]="communicator:sales"
    ["biz-finance"]="integrator:payment"
    ["biz-legal"]="compliance:legal"
    ["biz-support"]="communicator:support"
    ["biz-hr"]="communicator:support"
    ["biz-investor"]="communicator:sales"
    ["biz-partnerships"]="communicator:sales"

    # Data
    ["data-ml"]="implementer:backend"
    ["data-eng"]="implementer:database"
    ["data-analytics"]="researcher:competitive"

    # Product
    ["prod-pm"]="orchestrator:planning"
    ["prod-design"]="architect:component_design"
    ["prod-techwriter"]="documenter:technical"

    # Growth
    ["growth-hacker"]="researcher:competitive"
    ["growth-community"]="communicator:marketing"
    ["growth-success"]="communicator:support"
    ["growth-lifecycle"]="communicator:marketing"

    # Review
    ["review-code"]="reviewer:code_quality"
    ["review-business"]="reviewer:business_logic"
    ["review-security"]="reviewer:security"
)

# Show migration mapping
show_mapping() {
    echo -e "${BLUE}Agent Migration Mapping (v2 -> v3)${NC}"
    echo "============================================"
    printf "%-20s -> %-25s\n" "Old Agent (v2)" "New Agent:Mode (v3)"
    echo "--------------------------------------------"

    for old_agent in $(echo "${!MIGRATION_MAP[@]}" | tr ' ' '\n' | sort); do
        new_agent="${MIGRATION_MAP[$old_agent]}"
        printf "%-20s -> %-25s\n" "$old_agent" "$new_agent"
    done
}

# Migrate a single agent type
migrate_agent() {
    local old_agent="$1"

    if [[ -z "${MIGRATION_MAP[$old_agent]:-}" ]]; then
        echo -e "${RED}Unknown agent: $old_agent${NC}"
        return 1
    fi

    local new_spec="${MIGRATION_MAP[$old_agent]}"
    local new_agent="${new_spec%%:*}"
    local new_mode="${new_spec##*:}"

    echo -e "${GREEN}Migrating:${NC} $old_agent -> $new_agent (mode: $new_mode)"

    # Return the new spec
    echo "$new_spec"
}

# Migrate task queue
migrate_queue() {
    local queue_file="${1:-.loki/queue/pending.json}"

    if [[ ! -f "$queue_file" ]]; then
        echo -e "${YELLOW}Queue file not found: $queue_file${NC}"
        return 1
    fi

    echo -e "${BLUE}Migrating queue: $queue_file${NC}"

    # Create backup
    cp "$queue_file" "${queue_file}.v2.backup"

    # Process each task
    local temp_file=$(mktemp)

    # Use jq to transform the queue
    jq --argjson mapping "$(
        echo "{"
        for key in "${!MIGRATION_MAP[@]}"; do
            value="${MIGRATION_MAP[$key]}"
            agent="${value%%:*}"
            mode="${value##*:}"
            echo "\"$key\": {\"agent\": \"$agent\", \"mode\": \"$mode\"},"
        done | sed '$ s/,$//'
        echo "}"
    )" '
        .tasks |= map(
            if .type and $mapping[.type] then
                .type = $mapping[.type].agent |
                .mode = $mapping[.type].mode
            else
                .
            end
        )
    ' "$queue_file" > "$temp_file"

    mv "$temp_file" "$queue_file"

    echo -e "${GREEN}Queue migrated. Backup saved to ${queue_file}.v2.backup${NC}"
}

# Migrate agent state files
migrate_state() {
    local state_dir="${1:-.loki/state/agents}"

    if [[ ! -d "$state_dir" ]]; then
        echo -e "${YELLOW}State directory not found: $state_dir${NC}"
        return 1
    fi

    echo -e "${BLUE}Migrating agent state files in: $state_dir${NC}"

    for state_file in "$state_dir"/*.json; do
        [[ -f "$state_file" ]] || continue

        local agent_id=$(jq -r '.id // empty' "$state_file")
        local old_role=$(jq -r '.role // empty' "$state_file")

        if [[ -n "$old_role" && -n "${MIGRATION_MAP[$old_role]:-}" ]]; then
            local new_spec="${MIGRATION_MAP[$old_role]}"
            local new_agent="${new_spec%%:*}"
            local new_mode="${new_spec##*:}"

            echo "  Migrating $agent_id: $old_role -> $new_agent:$new_mode"

            # Update the state file
            jq --arg agent "$new_agent" --arg mode "$new_mode" '
                .role = $agent |
                .mode = $mode |
                .migrated_from = .role |
                .migration_version = "3.0"
            ' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
    done

    echo -e "${GREEN}State migration complete${NC}"
}

# Generate migration report
generate_report() {
    local output="${1:-migration-report.md}"

    cat > "$output" << 'EOF'
# Agent Migration Report

## Overview

This report documents the migration from the 37 role-based agent model (v2)
to the 12 capability-based agent model (v3).

## Rationale

Community feedback identified that:
1. "Agents should reflect thinking patterns, not job titles" - darkflib
2. Too many specialized agents create coordination overhead
3. Similar agents (e.g., biz-sales, biz-investor) duplicate capabilities

## New Agent Model

| Agent | Modes | Replaces |
|-------|-------|----------|
EOF

    # Group by new agent
    declare -A agent_modes
    declare -A agent_replaces

    for old_agent in "${!MIGRATION_MAP[@]}"; do
        local new_spec="${MIGRATION_MAP[$old_agent]}"
        local new_agent="${new_spec%%:*}"
        local new_mode="${new_spec##*:}"

        agent_modes[$new_agent]+="$new_mode, "
        agent_replaces[$new_agent]+="$old_agent, "
    done

    for agent in $(echo "${!agent_modes[@]}" | tr ' ' '\n' | sort -u); do
        local modes="${agent_modes[$agent]%, }"
        local replaces="${agent_replaces[$agent]%, }"
        echo "| $agent | $modes | $replaces |" >> "$output"
    done

    cat >> "$output" << 'EOF'

## Benefits

1. **Reduced Complexity**: 12 agents vs 37
2. **Better Coherence**: Single agent maintains context across related tasks
3. **Flexible Modes**: Same agent can switch modes without spawning new instance
4. **Easier Scaling**: Scale by agent type, not by role

## Risks

1. **Mode Confusion**: Agent might apply wrong mode's patterns
2. **Context Overload**: Single agent handling too many responsibilities
3. **Migration Errors**: Existing tasks may need manual review

## Validation

After migration, verify:
- [ ] All pending tasks have valid agent:mode assignments
- [ ] Agent state files are updated
- [ ] No orphaned tasks with unknown agent types
- [ ] Review parallel execution still works

EOF

    echo -e "${GREEN}Report generated: $output${NC}"
}

# Validate migration
validate() {
    local queue_file="${1:-.loki/queue/pending.json}"
    local errors=0

    echo -e "${BLUE}Validating migration...${NC}"

    if [[ -f "$queue_file" ]]; then
        # Check for unknown agent types
        local unknown=$(jq -r '.tasks[].type // empty' "$queue_file" | sort -u | while read type; do
            if [[ ! " ${!MIGRATION_MAP[@]} " =~ " $type " ]]; then
                # Check if it's already a v3 agent
                case "$type" in
                    architect|implementer|tester|reviewer|deployer|documenter|researcher|integrator|optimizer|compliance|communicator|orchestrator)
                        ;;
                    *)
                        echo "$type"
                        ;;
                esac
            fi
        done)

        if [[ -n "$unknown" ]]; then
            echo -e "${RED}Unknown agent types found:${NC}"
            echo "$unknown"
            errors=$((errors + 1))
        fi
    fi

    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}Validation passed${NC}"
        return 0
    else
        echo -e "${RED}Validation failed with $errors errors${NC}"
        return 1
    fi
}

# Main command handler
main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        mapping)
            show_mapping
            ;;
        migrate-queue)
            migrate_queue "$@"
            ;;
        migrate-state)
            migrate_state "$@"
            ;;
        migrate-all)
            migrate_queue
            migrate_state
            generate_report
            validate
            ;;
        report)
            generate_report "$@"
            ;;
        validate)
            validate "$@"
            ;;
        lookup)
            if [[ -n "${1:-}" ]]; then
                migrate_agent "$1"
            else
                echo "Usage: migrate-agents.sh lookup <old-agent-type>"
            fi
            ;;
        help|*)
            cat << EOF
Agent Migration Script (v2 -> v3)

Migrates from 37 role-based agents to 12 capability-based agents.

Usage: migrate-agents.sh <command> [args]

Commands:
  mapping               Show full migration mapping
  lookup <agent>        Look up migration for specific agent type
  migrate-queue [file]  Migrate task queue file
  migrate-state [dir]   Migrate agent state files
  migrate-all           Run full migration (queue + state + report)
  report [file]         Generate migration report
  validate [queue]      Validate migration
  help                  Show this help

Examples:
  # See what eng-frontend maps to
  ./migrate-agents.sh lookup eng-frontend

  # Run full migration
  ./migrate-agents.sh migrate-all

  # Just generate report
  ./migrate-agents.sh report migration-report.md
EOF
            ;;
    esac
}

main "$@"

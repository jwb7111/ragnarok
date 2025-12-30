#!/bin/bash
# Task Verification Script
# Runs objective verification commands to validate task completion
# This is the ONLY way tasks can be marked as complete
#
# Addresses: "The teams just started lying about progress" - Agitated_Bet_9808

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOKI_ROOT="${LOKI_ROOT:-.loki}"
VERIFY_DIR="$LOKI_ROOT/verify"
LOG_FILE="$LOKI_ROOT/logs/verification.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Timeouts (in seconds)
TIMEOUT_BUILD=600      # 10 minutes
TIMEOUT_TEST=900       # 15 minutes
TIMEOUT_LINT=120       # 2 minutes
TIMEOUT_TYPECHECK=120  # 2 minutes

# Initialize verification directory
init_verify() {
    mkdir -p "$VERIFY_DIR"
    mkdir -p "$LOKI_ROOT/logs"
    echo "[$(date -Iseconds)] Verification system initialized" >> "$LOG_FILE"
}

# Log verification event
log_verify() {
    local task_id="$1"
    local check="$2"
    local result="$3"
    local details="${4:-}"
    echo "[$(date -Iseconds)] [$task_id] [$check] $result - $details" >> "$LOG_FILE"
}

# Run a command with timeout and capture output
run_with_timeout() {
    local timeout_seconds="$1"
    local output_file="$2"
    shift 2
    local cmd="$*"

    local start_time=$(date +%s)

    # Run with timeout, capture both stdout and stderr
    if timeout "$timeout_seconds" bash -c "$cmd" > "$output_file" 2>&1; then
        local exit_code=0
    else
        local exit_code=$?
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Return exit code and duration
    echo "$exit_code:$duration"
}

# Verify build passes
verify_build() {
    local task_id="$1"
    local project_dir="${2:-.}"
    local output_file="$VERIFY_DIR/build-${task_id}.log"

    echo -e "${BLUE}[VERIFY]${NC} Running build verification..."

    # Detect build command
    local build_cmd=""
    if [[ -f "$project_dir/package.json" ]]; then
        if grep -q '"build"' "$project_dir/package.json"; then
            build_cmd="cd $project_dir && npm run build"
        else
            echo -e "${YELLOW}[SKIP]${NC} No build script in package.json"
            log_verify "$task_id" "build" "SKIPPED" "No build script"
            return 0
        fi
    elif [[ -f "$project_dir/Makefile" ]]; then
        build_cmd="cd $project_dir && make build"
    elif [[ -f "$project_dir/Cargo.toml" ]]; then
        build_cmd="cd $project_dir && cargo build --release"
    elif [[ -f "$project_dir/go.mod" ]]; then
        build_cmd="cd $project_dir && go build ./..."
    else
        echo -e "${YELLOW}[SKIP]${NC} No recognized build system"
        log_verify "$task_id" "build" "SKIPPED" "No build system detected"
        return 0
    fi

    local result=$(run_with_timeout "$TIMEOUT_BUILD" "$output_file" "$build_cmd")
    local exit_code="${result%%:*}"
    local duration="${result##*:}"

    if [[ "$exit_code" -eq 0 ]]; then
        echo -e "${GREEN}[PASS]${NC} Build succeeded (${duration}s)"
        log_verify "$task_id" "build" "PASS" "duration=${duration}s"
        return 0
    elif [[ "$exit_code" -eq 124 ]]; then
        echo -e "${RED}[FAIL]${NC} Build timed out after ${TIMEOUT_BUILD}s"
        log_verify "$task_id" "build" "TIMEOUT" "exceeded ${TIMEOUT_BUILD}s"
        return 1
    else
        echo -e "${RED}[FAIL]${NC} Build failed (exit code: $exit_code)"
        log_verify "$task_id" "build" "FAIL" "exit_code=$exit_code"
        return 1
    fi
}

# Verify tests pass
verify_tests() {
    local task_id="$1"
    local project_dir="${2:-.}"
    local output_file="$VERIFY_DIR/test-${task_id}.log"

    echo -e "${BLUE}[VERIFY]${NC} Running test verification..."

    # Detect test command
    local test_cmd=""
    if [[ -f "$project_dir/package.json" ]]; then
        if grep -q '"test"' "$project_dir/package.json"; then
            test_cmd="cd $project_dir && npm test -- --passWithNoTests"
        else
            echo -e "${YELLOW}[SKIP]${NC} No test script in package.json"
            log_verify "$task_id" "test" "SKIPPED" "No test script"
            return 0
        fi
    elif [[ -f "$project_dir/Cargo.toml" ]]; then
        test_cmd="cd $project_dir && cargo test"
    elif [[ -f "$project_dir/go.mod" ]]; then
        test_cmd="cd $project_dir && go test ./..."
    elif [[ -f "$project_dir/pytest.ini" ]] || [[ -f "$project_dir/setup.py" ]]; then
        test_cmd="cd $project_dir && pytest"
    else
        echo -e "${YELLOW}[SKIP]${NC} No recognized test framework"
        log_verify "$task_id" "test" "SKIPPED" "No test framework detected"
        return 0
    fi

    local result=$(run_with_timeout "$TIMEOUT_TEST" "$output_file" "$test_cmd")
    local exit_code="${result%%:*}"
    local duration="${result##*:}"

    if [[ "$exit_code" -eq 0 ]]; then
        echo -e "${GREEN}[PASS]${NC} Tests passed (${duration}s)"
        log_verify "$task_id" "test" "PASS" "duration=${duration}s"

        # Try to extract coverage if available
        if grep -q "coverage" "$output_file" 2>/dev/null; then
            local coverage=$(grep -oP '\d+(\.\d+)?%' "$output_file" | tail -1 || echo "unknown")
            echo -e "        Coverage: $coverage"
        fi

        return 0
    elif [[ "$exit_code" -eq 124 ]]; then
        echo -e "${RED}[FAIL]${NC} Tests timed out after ${TIMEOUT_TEST}s"
        log_verify "$task_id" "test" "TIMEOUT" "exceeded ${TIMEOUT_TEST}s"
        return 1
    else
        echo -e "${RED}[FAIL]${NC} Tests failed (exit code: $exit_code)"
        log_verify "$task_id" "test" "FAIL" "exit_code=$exit_code"
        return 1
    fi
}

# Verify linting passes
verify_lint() {
    local task_id="$1"
    local project_dir="${2:-.}"
    local output_file="$VERIFY_DIR/lint-${task_id}.log"

    echo -e "${BLUE}[VERIFY]${NC} Running lint verification..."

    # Detect lint command
    local lint_cmd=""
    if [[ -f "$project_dir/package.json" ]]; then
        if grep -q '"lint"' "$project_dir/package.json"; then
            lint_cmd="cd $project_dir && npm run lint"
        elif [[ -f "$project_dir/.eslintrc.js" ]] || [[ -f "$project_dir/.eslintrc.json" ]]; then
            lint_cmd="cd $project_dir && npx eslint . --ext .ts,.tsx,.js,.jsx"
        else
            echo -e "${YELLOW}[SKIP]${NC} No lint configuration"
            log_verify "$task_id" "lint" "SKIPPED" "No lint config"
            return 0
        fi
    elif [[ -f "$project_dir/Cargo.toml" ]]; then
        lint_cmd="cd $project_dir && cargo clippy -- -D warnings"
    elif [[ -f "$project_dir/go.mod" ]]; then
        lint_cmd="cd $project_dir && golangci-lint run"
    else
        echo -e "${YELLOW}[SKIP]${NC} No recognized linting tool"
        log_verify "$task_id" "lint" "SKIPPED" "No linter detected"
        return 0
    fi

    local result=$(run_with_timeout "$TIMEOUT_LINT" "$output_file" "$lint_cmd")
    local exit_code="${result%%:*}"
    local duration="${result##*:}"

    if [[ "$exit_code" -eq 0 ]]; then
        echo -e "${GREEN}[PASS]${NC} Lint passed (${duration}s)"
        log_verify "$task_id" "lint" "PASS" "duration=${duration}s"
        return 0
    elif [[ "$exit_code" -eq 124 ]]; then
        echo -e "${RED}[FAIL]${NC} Lint timed out after ${TIMEOUT_LINT}s"
        log_verify "$task_id" "lint" "TIMEOUT" "exceeded ${TIMEOUT_LINT}s"
        return 1
    else
        echo -e "${RED}[FAIL]${NC} Lint failed (exit code: $exit_code)"
        log_verify "$task_id" "lint" "FAIL" "exit_code=$exit_code"
        return 1
    fi
}

# Verify TypeScript compilation
verify_types() {
    local task_id="$1"
    local project_dir="${2:-.}"
    local output_file="$VERIFY_DIR/types-${task_id}.log"

    echo -e "${BLUE}[VERIFY]${NC} Running type verification..."

    # Only for TypeScript projects
    if [[ ! -f "$project_dir/tsconfig.json" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} No TypeScript configuration"
        log_verify "$task_id" "types" "SKIPPED" "No tsconfig.json"
        return 0
    fi

    local type_cmd="cd $project_dir && npx tsc --noEmit"

    local result=$(run_with_timeout "$TIMEOUT_TYPECHECK" "$output_file" "$type_cmd")
    local exit_code="${result%%:*}"
    local duration="${result##*:}"

    if [[ "$exit_code" -eq 0 ]]; then
        echo -e "${GREEN}[PASS]${NC} Type check passed (${duration}s)"
        log_verify "$task_id" "types" "PASS" "duration=${duration}s"
        return 0
    elif [[ "$exit_code" -eq 124 ]]; then
        echo -e "${RED}[FAIL]${NC} Type check timed out after ${TIMEOUT_TYPECHECK}s"
        log_verify "$task_id" "types" "TIMEOUT" "exceeded ${TIMEOUT_TYPECHECK}s"
        return 1
    else
        echo -e "${RED}[FAIL]${NC} Type check failed (exit code: $exit_code)"
        log_verify "$task_id" "types" "FAIL" "exit_code=$exit_code"
        return 1
    fi
}

# Full verification suite
verify_all() {
    local task_id="$1"
    local project_dir="${2:-.}"
    local failures=0

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  TASK VERIFICATION: $task_id${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Run all verifications
    verify_build "$task_id" "$project_dir" || failures=$((failures + 1))
    verify_tests "$task_id" "$project_dir" || failures=$((failures + 1))
    verify_lint "$task_id" "$project_dir" || failures=$((failures + 1))
    verify_types "$task_id" "$project_dir" || failures=$((failures + 1))

    echo ""
    echo -e "${BLUE}========================================${NC}"

    if [[ $failures -eq 0 ]]; then
        echo -e "${GREEN}  VERIFICATION PASSED${NC}"
        echo -e "${BLUE}========================================${NC}"

        # Create verification record
        create_verification_record "$task_id" "PASS"
        return 0
    else
        echo -e "${RED}  VERIFICATION FAILED ($failures checks)${NC}"
        echo -e "${BLUE}========================================${NC}"

        # Create verification record
        create_verification_record "$task_id" "FAIL" "$failures"
        return 1
    fi
}

# Create machine-readable verification record
create_verification_record() {
    local task_id="$1"
    local result="$2"
    local failure_count="${3:-0}"

    local record_file="$VERIFY_DIR/record-${task_id}.json"

    cat > "$record_file" << EOF
{
  "taskId": "$task_id",
  "timestamp": "$(date -Iseconds)",
  "result": "$result",
  "failureCount": $failure_count,
  "checks": {
    "build": {
      "logFile": "$VERIFY_DIR/build-${task_id}.log",
      "exists": $([ -f "$VERIFY_DIR/build-${task_id}.log" ] && echo "true" || echo "false")
    },
    "test": {
      "logFile": "$VERIFY_DIR/test-${task_id}.log",
      "exists": $([ -f "$VERIFY_DIR/test-${task_id}.log" ] && echo "true" || echo "false")
    },
    "lint": {
      "logFile": "$VERIFY_DIR/lint-${task_id}.log",
      "exists": $([ -f "$VERIFY_DIR/lint-${task_id}.log" ] && echo "true" || echo "false")
    },
    "types": {
      "logFile": "$VERIFY_DIR/types-${task_id}.log",
      "exists": $([ -f "$VERIFY_DIR/types-${task_id}.log" ] && echo "true" || echo "false")
    }
  },
  "verifiedBy": "verify-task.sh",
  "version": "1.0"
}
EOF

    echo -e "${BLUE}Verification record:${NC} $record_file"
}

# Check if task has valid verification
check_verification() {
    local task_id="$1"
    local record_file="$VERIFY_DIR/record-${task_id}.json"

    if [[ ! -f "$record_file" ]]; then
        echo -e "${RED}[NOT VERIFIED]${NC} No verification record for task: $task_id"
        return 1
    fi

    local result=$(jq -r '.result' "$record_file")
    local timestamp=$(jq -r '.timestamp' "$record_file")

    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}[VERIFIED]${NC} Task $task_id passed verification at $timestamp"
        return 0
    else
        echo -e "${RED}[FAILED]${NC} Task $task_id failed verification at $timestamp"
        return 1
    fi
}

# Show verification history
show_history() {
    local limit="${1:-10}"

    echo -e "${BLUE}Recent Verification History${NC}"
    echo "============================"

    if [[ -f "$LOG_FILE" ]]; then
        tail -"$limit" "$LOG_FILE"
    else
        echo "(no history)"
    fi
}

# Generate verification report
generate_report() {
    local output="${1:-verification-report.md}"

    cat > "$output" << EOF
# Verification Report

Generated: $(date -Iseconds)

## Summary

EOF

    local total=0
    local passed=0
    local failed=0

    for record in "$VERIFY_DIR"/record-*.json; do
        [[ -f "$record" ]] || continue
        total=$((total + 1))

        local result=$(jq -r '.result' "$record")
        if [[ "$result" == "PASS" ]]; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
    done

    cat >> "$output" << EOF
- Total verifications: $total
- Passed: $passed
- Failed: $failed
- Pass rate: $([ $total -gt 0 ] && echo "scale=1; $passed * 100 / $total" | bc || echo "0")%

## Recent Verifications

| Task ID | Result | Timestamp |
|---------|--------|-----------|
EOF

    for record in "$VERIFY_DIR"/record-*.json; do
        [[ -f "$record" ]] || continue
        local task_id=$(jq -r '.taskId' "$record")
        local result=$(jq -r '.result' "$record")
        local timestamp=$(jq -r '.timestamp' "$record")
        echo "| $task_id | $result | $timestamp |" >> "$output"
    done

    echo -e "${GREEN}Report generated:${NC} $output"
}

# Main command handler
main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        init)
            init_verify
            echo -e "${GREEN}Verification system initialized${NC}"
            ;;
        verify)
            if [[ -z "${1:-}" ]]; then
                echo "Usage: verify-task.sh verify <task_id> [project_dir]"
                exit 1
            fi
            init_verify
            verify_all "$@"
            ;;
        build)
            init_verify
            verify_build "$@"
            ;;
        test)
            init_verify
            verify_tests "$@"
            ;;
        lint)
            init_verify
            verify_lint "$@"
            ;;
        types)
            init_verify
            verify_types "$@"
            ;;
        check)
            check_verification "$@"
            ;;
        history)
            show_history "$@"
            ;;
        report)
            generate_report "$@"
            ;;
        help|*)
            cat << EOF
Task Verification System

Runs objective verification to prevent agents from lying about progress.
Tasks can ONLY be marked complete with passing verification.

Usage: verify-task.sh <command> [args]

Commands:
  init                      Initialize verification system
  verify <task_id> [dir]    Run full verification suite
  build <task_id> [dir]     Verify build only
  test <task_id> [dir]      Verify tests only
  lint <task_id> [dir]      Verify lint only
  types <task_id> [dir]     Verify types only
  check <task_id>           Check if task has valid verification
  history [limit]           Show verification history
  report [file]             Generate verification report
  help                      Show this help

Examples:
  # Full verification
  ./verify-task.sh verify task-123 ./my-project

  # Check if task is verified
  ./verify-task.sh check task-123

  # Generate report
  ./verify-task.sh report verification-report.md

Notes:
  - All verification logs are stored in .loki/verify/
  - A task is only verified if ALL checks pass (or are skipped)
  - Skipped checks (no build script, no tests, etc.) don't fail verification
  - Timeout failures count as failures
EOF
            ;;
    esac
}

main "$@"

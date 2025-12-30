#!/bin/bash
# Jurisdiction Validation Script
# Ensures required legal/compliance fields are set before business agents operate

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${1:-$SCRIPT_DIR/../config/jurisdiction.yaml}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if yq is available, fall back to grep-based parsing
if command -v yq &> /dev/null; then
    USE_YQ=true
else
    USE_YQ=false
fi

# Get YAML value (simple grep-based for portability)
get_value() {
    local key="$1"
    if $USE_YQ; then
        yq -r "$key // \"\"" "$CONFIG_FILE" 2>/dev/null || echo ""
    else
        # Simple grep-based extraction (handles basic cases)
        grep -E "^\s*${key##*.}:" "$CONFIG_FILE" 2>/dev/null | head -1 | sed 's/.*:\s*"\?\([^"]*\)"\?.*/\1/' | tr -d ' '
    fi
}

errors=()
warnings=()

echo -e "${YELLOW}Validating Jurisdiction Configuration${NC}"
echo "Config file: $CONFIG_FILE"
echo "============================================"

# Check file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}ERROR: Configuration file not found: $CONFIG_FILE${NC}"
    echo ""
    echo "Create the file from template:"
    echo "  cp config/jurisdiction.yaml.example config/jurisdiction.yaml"
    echo "  # Edit with your jurisdiction details"
    exit 1
fi

# Required: Primary Country
primary_country=$(get_value ".jurisdiction.primary_country")
if [[ -z "$primary_country" || "$primary_country" == '""' ]]; then
    errors+=("jurisdiction.primary_country is REQUIRED (e.g., US, GB, DE)")
else
    echo -e "${GREEN}✓${NC} Primary country: $primary_country"
fi

# Required if US: Primary State
if [[ "$primary_country" == "US" ]]; then
    primary_state=$(get_value ".jurisdiction.primary_state")
    if [[ -z "$primary_state" || "$primary_state" == '""' ]]; then
        errors+=("jurisdiction.primary_state is REQUIRED for US-based companies (e.g., CA, NY, DE)")
    else
        echo -e "${GREEN}✓${NC} Primary state: $primary_state"
    fi
fi

# Required: At least one target market
# Check if countries list has at least one non-empty entry
if $USE_YQ; then
    first_country=$(yq -r '.target_markets.countries[0] // ""' "$CONFIG_FILE" 2>/dev/null || echo "")
else
    first_country=$(grep -A1 "countries:" "$CONFIG_FILE" | tail -1 | sed 's/.*- "\?\([^"]*\)"\?.*/\1/' | tr -d ' ')
fi

if [[ -z "$first_country" || "$first_country" == '""' || "$first_country" == "-" ]]; then
    errors+=("target_markets.countries must have at least one country")
else
    echo -e "${GREEN}✓${NC} Target market: $first_country"
fi

# Auto-enable checks based on target markets
eu_users=$(get_value ".target_markets.eu_users")
if [[ "$eu_users" == "true" ]]; then
    gdpr_enabled=$(get_value ".compliance.gdpr.enabled")
    if [[ "$gdpr_enabled" != "true" ]]; then
        warnings+=("EU users targeted but GDPR not enabled - should set compliance.gdpr.enabled: true")
    else
        echo -e "${GREEN}✓${NC} GDPR compliance enabled for EU users"
    fi
fi

ca_users=$(get_value ".target_markets.california_users")
if [[ "$ca_users" == "true" ]]; then
    ccpa_enabled=$(get_value ".compliance.ccpa.enabled")
    if [[ "$ccpa_enabled" != "true" ]]; then
        warnings+=("California users targeted but CCPA not enabled - should set compliance.ccpa.enabled: true")
    else
        echo -e "${GREEN}✓${NC} CCPA compliance enabled for California users"
    fi
fi

children=$(get_value ".target_markets.children_under_13")
if [[ "$children" == "true" ]]; then
    coppa_enabled=$(get_value ".compliance.coppa.enabled")
    if [[ "$coppa_enabled" != "true" ]]; then
        errors+=("Children under 13 targeted but COPPA not enabled - MUST set compliance.coppa.enabled: true")
    else
        echo -e "${GREEN}✓${NC} COPPA compliance enabled for children"
    fi
fi

# Check cookie consent for EU
if [[ "$eu_users" == "true" ]]; then
    banner_required=$(get_value ".cookies.consent.banner_required")
    if [[ "$banner_required" != "true" ]]; then
        warnings+=("EU users targeted but cookie banner not required - should set cookies.consent.banner_required: true")
    fi
fi

echo ""
echo "============================================"

# Report warnings
if [[ ${#warnings[@]} -gt 0 ]]; then
    echo -e "${YELLOW}WARNINGS (${#warnings[@]}):${NC}"
    for warning in "${warnings[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $warning"
    done
    echo ""
fi

# Report errors
if [[ ${#errors[@]} -gt 0 ]]; then
    echo -e "${RED}ERRORS (${#errors[@]}):${NC}"
    for error in "${errors[@]}"; do
        echo -e "  ${RED}✗${NC} $error"
    done
    echo ""
    echo -e "${RED}Jurisdiction validation FAILED${NC}"
    echo "Business/legal agents cannot operate until these are fixed."
    exit 1
fi

echo -e "${GREEN}Jurisdiction validation PASSED${NC}"
echo ""
echo "Legal agents may now operate with:"
echo "  - Primary jurisdiction: ${primary_country}${primary_state:+ ($primary_state)}"
echo "  - Target market: $first_country"

# Create validation marker
LOKI_ROOT="${LOKI_ROOT:-.loki}"
mkdir -p "$LOKI_ROOT/validation"
cat > "$LOKI_ROOT/validation/jurisdiction.json" << EOF
{
  "validated_at": "$(date -Iseconds)",
  "config_file": "$CONFIG_FILE",
  "primary_country": "$primary_country",
  "primary_state": "${primary_state:-}",
  "warnings": ${#warnings[@]},
  "status": "passed"
}
EOF

echo ""
echo "Validation marker created: $LOKI_ROOT/validation/jurisdiction.json"

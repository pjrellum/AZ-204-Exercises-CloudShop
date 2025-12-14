#!/bin/bash
# =============================================================================
# Validate Exercise 08 - API Management
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Validating Exercise 08: API Management ==="
echo ""

PASSED=0
FAILED=0

check() {
    local name="$1"
    local cmd="$2"

    printf "%-40s" "Checking $name..."

    if eval "$cmd" > /dev/null 2>&1; then
        echo "✓ PASS"
        ((PASSED++))
        return 0
    else
        echo "✗ FAIL"
        ((FAILED++))
        return 1
    fi
}

# Check Resource Group
check "Resource Group exists" \
    "az group show --name $RESOURCE_GROUP"

# Check Storage Account
check "Storage Account exists" \
    "az storage account show --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP"

# Check Function App
check "Function App exists" \
    "az functionapp show --name $FUNCTION_APP --resource-group $RESOURCE_GROUP"

# Check Function App is running
check "Function App is running" \
    "az functionapp show --name $FUNCTION_APP --resource-group $RESOURCE_GROUP --query 'state' -o tsv | grep -i running"

# Check APIM
check "API Management exists" \
    "az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP"

# Check APIM is provisioned
check "API Management is ready" \
    "az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP --query 'provisioningState' -o tsv | grep -i succeeded"

# Check Function responds
check "Function responds to requests" \
    "curl -sf https://$FUNCTION_APP.azurewebsites.net/api/health"

# Check APIM has Orders API (if configured)
echo ""
printf "%-40s" "Checking Orders API in APIM..."
if az apim api show --resource-group "$RESOURCE_GROUP" --service-name "$APIM_NAME" --api-id orders-api > /dev/null 2>&1; then
    echo "✓ PASS"
    ((PASSED++))

    # If API exists, check subscription requirement
    check "API requires subscription" \
        "az apim api show --resource-group $RESOURCE_GROUP --service-name $APIM_NAME --api-id orders-api --query 'subscriptionRequired' -o tsv | grep -i true"
else
    echo "○ SKIP (API not yet imported)"
fi

echo ""
echo "========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi

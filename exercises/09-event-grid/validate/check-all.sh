#!/bin/bash
# Validate Event Grid exercise deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Event Grid Exercise ==="
echo ""

PASS=0
FAIL=0
SKIP=0

check() {
    local name="$1"
    local result="$2"
    if [ "$result" == "true" ] || [ -n "$result" ]; then
        echo "[PASS] $name"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $name"
        FAIL=$((FAIL + 1))
    fi
}

skip() {
    local name="$1"
    local reason="$2"
    echo "[SKIP] $name ($reason)"
    SKIP=$((SKIP + 1))
}

# Check storage account
echo "Checking storage account..."
STORAGE_EXISTS=$(az storage account show --name "$STORAGE_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Storage account exists" "$STORAGE_EXISTS"

# Check orders container
echo ""
echo "Checking containers..."
CONTAINER_EXISTS=$(az storage container exists --name orders --account-name "$STORAGE_NAME" --auth-mode key --query "exists" -o tsv 2>/dev/null || echo "false")
check "Orders container exists" "$CONTAINER_EXISTS"

# Check dead-letter container
DL_EXISTS=$(az storage container exists --name deadletter --account-name "$STORAGE_NAME" --auth-mode key --query "exists" -o tsv 2>/dev/null || echo "false")
check "Dead-letter container exists" "$DL_EXISTS"

# Check Function App
echo ""
echo "Checking Function App..."
FUNC_EXISTS=$(az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Function App exists" "$FUNC_EXISTS"

if [ -n "$FUNC_EXISTS" ]; then
    FUNC_STATE=$(az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" --query "state" -o tsv 2>/dev/null || echo "")
    if [ "$FUNC_STATE" == "Running" ]; then
        check "Function App is running" "true"
    else
        check "Function App is running" ""
    fi
fi

# Check Event Grid subscription
echo ""
echo "Checking Event Grid subscription..."
STORAGE_ID=$(az storage account show --name "$STORAGE_NAME" --resource-group "$RESOURCE_GROUP" --query id -o tsv 2>/dev/null || echo "")
if [ -n "$STORAGE_ID" ]; then
    EG_SUB=$(az eventgrid event-subscription show --name order-uploaded --source-resource-id "$STORAGE_ID" --query "name" -o tsv 2>/dev/null || echo "")
    check "Event Grid subscription exists" "$EG_SUB"
else
    skip "Event Grid subscription" "Storage account not found"
fi

# Check Event Grid filters
if [ -n "$EG_SUB" ]; then
    echo ""
    echo "Checking Event Grid filters..."

    # Check subject-ends-with filter (.json)
    SUBJECT_ENDS=$(az eventgrid event-subscription show --name order-uploaded --source-resource-id "$STORAGE_ID" --query "filter.subjectEndsWith" -o tsv 2>/dev/null || echo "")
    if [ "$SUBJECT_ENDS" == ".json" ]; then
        check "Filter: subject ends with .json" "true"
    else
        check "Filter: subject ends with .json" ""
    fi

    # Check subject-begins-with filter (orders container)
    SUBJECT_BEGINS=$(az eventgrid event-subscription show --name order-uploaded --source-resource-id "$STORAGE_ID" --query "filter.subjectBeginsWith" -o tsv 2>/dev/null || echo "")
    if [[ "$SUBJECT_BEGINS" == *"/orders/"* ]]; then
        check "Filter: subject begins with orders path" "true"
    else
        check "Filter: subject begins with orders path" ""
    fi

    # Check dead-letter configuration
    DL_ENDPOINT=$(az eventgrid event-subscription show --name order-uploaded --source-resource-id "$STORAGE_ID" --query "deadLetterDestination" -o tsv 2>/dev/null || echo "")
    check "Dead-letter endpoint configured" "$DL_ENDPOINT"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Skipped: $SKIP"
echo ""

if [ $FAIL -gt 0 ]; then
    echo "Some checks failed. Review the output above."
    exit 1
else
    echo "All checks passed!"
fi

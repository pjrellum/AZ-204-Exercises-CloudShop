#!/bin/bash
# Validate Event Grid exercise deployment

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Event Grid Exercise ==="
echo ""

PASS=0
FAIL=0

check() {
    local name="$1"
    local result="$2"
    if [ "$result" == "true" ] || [ -n "$result" ]; then
        echo "[PASS] $name"
        ((PASS++))
    else
        echo "[FAIL] $name"
        ((FAIL++))
    fi
}

# Check storage account
echo "Checking storage account..."
STORAGE_EXISTS=$(az storage account show --name "$STORAGE_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Storage account exists" "$STORAGE_EXISTS"

# Check orders container
echo "Checking orders container..."
CONTAINER_EXISTS=$(az storage container exists --name orders --account-name "$STORAGE_NAME" --auth-mode key --query "exists" -o tsv 2>/dev/null || echo "false")
check "Orders container exists" "$CONTAINER_EXISTS"

# Check dead-letter container
echo "Checking dead-letter container..."
DL_EXISTS=$(az storage container exists --name deadletter --account-name "$STORAGE_NAME" --auth-mode key --query "exists" -o tsv 2>/dev/null || echo "false")
check "Dead-letter container exists" "$DL_EXISTS"

# Check Function App
echo "Checking Function App..."
FUNC_EXISTS=$(az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Function App exists" "$FUNC_EXISTS"

# Check Event Grid subscription
echo "Checking Event Grid subscription..."
STORAGE_ID=$(az storage account show --name "$STORAGE_NAME" --resource-group "$RESOURCE_GROUP" --query id -o tsv 2>/dev/null || echo "")
if [ -n "$STORAGE_ID" ]; then
    EG_SUB=$(az eventgrid event-subscription show --name order-uploaded --source-resource-id "$STORAGE_ID" --query "name" -o tsv 2>/dev/null || echo "")
    check "Event Grid subscription exists" "$EG_SUB"
else
    check "Event Grid subscription exists" ""
fi

# Check Event Grid filters
if [ -n "$EG_SUB" ]; then
    echo "Checking Event Grid filters..."
    SUBJECT_FILTER=$(az eventgrid event-subscription show --name order-uploaded --source-resource-id "$STORAGE_ID" --query "filter.subjectEndsWith" -o tsv 2>/dev/null || echo "")
    if [ "$SUBJECT_FILTER" == ".json" ]; then
        check "Event Grid filter for .json files" "true"
    else
        check "Event Grid filter for .json files" ""
    fi
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -gt 0 ]; then
    echo "Some checks failed. Review the output above."
    exit 1
else
    echo "All checks passed!"
fi

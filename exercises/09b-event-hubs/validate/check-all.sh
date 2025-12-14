#!/bin/bash
# Validate Event Hubs exercise

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Event Hubs Exercise ==="
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

# Check Event Hubs namespace
echo "Checking Event Hubs namespace..."
NS_EXISTS=$(az eventhubs namespace show --name "$EVENTHUB_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Event Hubs namespace exists" "$NS_EXISTS"

# Check Event Hub
echo "Checking Event Hub..."
HUB_EXISTS=$(az eventhubs eventhub show --name "$EVENTHUB_NAME" --namespace-name "$EVENTHUB_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Event Hub exists" "$HUB_EXISTS"

# Check partition count
echo "Checking partitions..."
PARTITIONS=$(az eventhubs eventhub show --name "$EVENTHUB_NAME" --namespace-name "$EVENTHUB_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "partitionCount" -o tsv 2>/dev/null || echo "0")
if [ "$PARTITIONS" -ge 4 ]; then
    check "Event Hub has 4+ partitions" "true"
else
    check "Event Hub has 4+ partitions" ""
fi

# Check storage account (for checkpoints)
echo "Checking checkpoint storage..."
STORAGE_EXISTS=$(az storage account show --name "$STORAGE_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Storage account exists" "$STORAGE_EXISTS"

# Check checkpoint container
if [ -n "$STORAGE_EXISTS" ]; then
    CONTAINER_EXISTS=$(az storage container exists --name checkpoints --account-name "$STORAGE_NAME" --auth-mode key --query "exists" -o tsv 2>/dev/null || echo "false")
    check "Checkpoint container exists" "$CONTAINER_EXISTS"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

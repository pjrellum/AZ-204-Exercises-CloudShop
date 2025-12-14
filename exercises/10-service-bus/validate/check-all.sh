#!/bin/bash
# Validate Service Bus exercise

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Service Bus Exercise ==="
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

# Check namespace
echo "Checking Service Bus namespace..."
NS_EXISTS=$(az servicebus namespace show --name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Service Bus namespace exists" "$NS_EXISTS"

# Check queue
echo "Checking queue..."
QUEUE_EXISTS=$(az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Queue exists" "$QUEUE_EXISTS"

# Check max delivery count
if [ -n "$QUEUE_EXISTS" ]; then
    MAX_DELIVERY=$(az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "maxDeliveryCount" -o tsv 2>/dev/null || echo "0")
    if [ "$MAX_DELIVERY" == "3" ]; then
        check "Max delivery count is 3" "true"
    else
        check "Max delivery count is 3" ""
    fi
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

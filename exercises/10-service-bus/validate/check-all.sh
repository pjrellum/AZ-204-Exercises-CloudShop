#!/bin/bash
# Validate Service Bus exercise

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Service Bus Exercise ==="
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

# Check namespace
echo "Checking Service Bus namespace..."
NS_EXISTS=$(az servicebus namespace show --name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Service Bus namespace exists" "$NS_EXISTS"

# Check queue
echo ""
echo "Checking queue configuration..."
QUEUE_EXISTS=$(az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Queue '$QUEUE_NAME' exists" "$QUEUE_EXISTS"

# Check queue properties
if [ -n "$QUEUE_EXISTS" ]; then
    # Max delivery count
    MAX_DELIVERY=$(az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "maxDeliveryCount" -o tsv 2>/dev/null || echo "0")
    if [ "$MAX_DELIVERY" == "3" ]; then
        check "Max delivery count is 3" "true"
    else
        check "Max delivery count is 3 (current: $MAX_DELIVERY)" ""
    fi

    # Dead-letter enabled
    DLQ_ENABLED=$(az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "deadLetteringOnMessageExpiration" -o tsv 2>/dev/null || echo "false")
    check "Dead-letter on expiration enabled" "$DLQ_ENABLED"

    # Lock duration (should be 30 seconds for processing)
    LOCK_DURATION=$(az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" --query "lockDuration" -o tsv 2>/dev/null || echo "")
    check "Lock duration configured" "$LOCK_DURATION"
fi

# Check Function App connection
echo ""
echo "Checking Function App connection..."
if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    FUNC_SB_CONN=$(az functionapp config appsettings list --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" --query "[?name=='ServiceBusConnection'].value" -o tsv 2>/dev/null || echo "")
    check "Function App has ServiceBusConnection" "$FUNC_SB_CONN"
else
    skip "Function App connection" "Function App not found"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Skipped: $SKIP"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

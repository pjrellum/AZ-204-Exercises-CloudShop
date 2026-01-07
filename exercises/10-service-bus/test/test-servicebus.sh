#!/bin/bash
# Test Service Bus by sending order messages via the Function App API

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="${ENV_FILE:-env.sh}"

source "$EXERCISE_DIR/$ENV_FILE" 2>/dev/null || {
    echo "Error: $ENV_FILE not found. Copy env.example.sh to $ENV_FILE and configure it."
    exit 1
}

FUNC_URL="https://${FUNC_NAME}.azurewebsites.net"

echo "=== Testing Service Bus ==="
echo ""
echo "Function App: $FUNC_NAME"
echo "Service Bus: $SERVICEBUS_NAMESPACE"
echo "Queue: $QUEUE_NAME"
echo ""

# Check queue status before
echo "Queue status before:"
az servicebus queue show \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$QUEUE_NAME" \
    --query "{activeMessages:countDetails.activeMessageCount,deadLetter:countDetails.deadLetterMessageCount}" \
    -o table

# Test 1: Send a normal order (should be processed successfully)
echo ""
echo "=== Test 1: Normal Order (should succeed) ==="
ORDER_ID="TEST-$(date +%s)-001"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${FUNC_URL}/api/orders" \
    -H "Content-Type: application/json" \
    -d "{
        \"orderId\": \"$ORDER_ID\",
        \"customer\": \"Test Customer\",
        \"total\": 99.99,
        \"items\": [{\"sku\": \"WIDGET-001\", \"quantity\": 1, \"price\": 99.99}]
    }")
echo "Order $ORDER_ID (total: \$99.99) - HTTP $HTTP_CODE"

# Test 2: Send a high-value order (should go to dead-letter)
echo ""
echo "=== Test 2: High-Value Order (should go to dead-letter) ==="
ORDER_ID="TEST-$(date +%s)-002"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${FUNC_URL}/api/orders" \
    -H "Content-Type: application/json" \
    -d "{
        \"orderId\": \"$ORDER_ID\",
        \"customer\": \"Big Spender\",
        \"total\": 15000.00,
        \"items\": [{\"sku\": \"PREMIUM-X\", \"quantity\": 50, \"price\": 300.00}]
    }")
echo "Order $ORDER_ID (total: \$15,000) - HTTP $HTTP_CODE"
echo "  -> Orders over \$10,000 are flagged for review (dead-lettered)"

# Wait for processing
echo ""
echo "Waiting 10 seconds for processing..."
sleep 10

# Check queue status after
echo ""
echo "Queue status after:"
az servicebus queue show \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$QUEUE_NAME" \
    --query "{activeMessages:countDetails.activeMessageCount,deadLetter:countDetails.deadLetterMessageCount}" \
    -o table

echo ""
echo "=== Test Complete ==="
echo ""
echo "To view dead-letter messages:"
echo "  Azure Portal -> Service Bus -> $SERVICEBUS_NAMESPACE -> Queues -> $QUEUE_NAME"
echo "  Click 'Service Bus Explorer' -> Select 'Dead-letter' subqueue -> 'Peek from start'"
echo ""
echo "To check function logs:"
echo "  func azure functionapp logstream $FUNC_NAME"

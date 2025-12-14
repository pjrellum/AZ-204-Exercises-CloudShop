#!/bin/bash
# Test Event Grid integration by uploading a blob

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Testing Event Grid Integration ==="
echo ""

# Create test order file
ORDER_ID="ORD-$(date +%s)"
TEST_FILE="/tmp/${ORDER_ID}.json"

cat > "$TEST_FILE" << EOF
{
    "orderId": "$ORDER_ID",
    "customer": "Test Customer",
    "items": [
        {"sku": "WIDGET-001", "quantity": 2, "price": 25.00},
        {"sku": "GADGET-002", "quantity": 1, "price": 49.99}
    ],
    "total": 99.99,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "Created test order: $ORDER_ID"
echo "Content:"
cat "$TEST_FILE"
echo ""

# Upload to blob storage
echo "Uploading to blob storage..."
az storage blob upload \
    --account-name "$STORAGE_NAME" \
    --container-name orders \
    --name "${ORDER_ID}.json" \
    --file "$TEST_FILE" \
    --overwrite \
    --auth-mode key \
    --output none

echo ""
echo "=== Upload Complete ==="
echo "Blob: orders/${ORDER_ID}.json"
echo ""
echo "Check the Function logs to see the Event Grid event:"
echo "  az functionapp logs tail --name $FUNC_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "Or view in Azure Portal:"
echo "  Function App -> $FUNC_NAME -> Functions -> OrderUploaded -> Monitor"

# Cleanup
rm -f "$TEST_FILE"

#!/bin/bash
# Test Event Grid integration by uploading a blob

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Testing Event Grid Integration ==="
echo ""

# Create test batch file with multiple orders
BATCH_ID="BATCH-$(date +%s)"
TEST_FILE="/tmp/${BATCH_ID}.json"

cat > "$TEST_FILE" << EOF
[
    {
        "orderId": "${BATCH_ID}-001",
        "customer": "Alice Smith",
        "items": [
            {"sku": "WIDGET-001", "quantity": 2, "price": 25.00}
        ],
        "total": 50.00
    },
    {
        "orderId": "${BATCH_ID}-002",
        "customer": "Bob Jones",
        "items": [
            {"sku": "GADGET-002", "quantity": 1, "price": 49.99},
            {"sku": "WIDGET-001", "quantity": 3, "price": 25.00}
        ],
        "total": 124.99
    },
    {
        "orderId": "${BATCH_ID}-003",
        "customer": "Carol White",
        "items": [
            {"sku": "PREMIUM-X", "quantity": 1, "price": 299.00}
        ],
        "total": 299.00
    }
]
EOF

echo "Created batch file with 3 orders: $BATCH_ID"
echo "Content:"
cat "$TEST_FILE"
echo ""

# Upload to blob storage
echo "Uploading batch to blob storage..."
az storage blob upload \
    --account-name "$STORAGE_NAME" \
    --container-name orders \
    --name "${BATCH_ID}.json" \
    --file "$TEST_FILE" \
    --overwrite \
    --auth-mode key \
    --output none

echo ""
echo "=== Upload Complete ==="
echo "Blob: orders/${BATCH_ID}.json (3 orders)"
echo ""
echo "Check the Function logs to see the Event Grid event:"
echo "  func azure functionapp logstream $FUNC_NAME"
echo "  # or: az functionapp logs tail --name $FUNC_NAME --resource-group $RESOURCE_GROUP"

# Cleanup
rm -f "$TEST_FILE"

#!/bin/bash
# Test Event Hubs by sending and receiving events

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Testing Event Hubs ==="
echo ""

# Get connection string
EVENTHUB_CONNECTION=$(az eventhubs namespace authorization-rule keys list \
    --namespace-name "$EVENTHUB_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

STORAGE_CONNECTION=$(az storage account show-connection-string \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)

echo "Sending 10 test events..."
cd ../code/python/complete
pip install -q -r requirements.txt

export EVENTHUB_CONNECTION_STRING="$EVENTHUB_CONNECTION"
export EVENTHUB_NAME="$EVENTHUB_NAME"
python producer.py --count 10

echo ""
echo "=== Events Sent ==="
echo ""
echo "To consume events, run:"
echo "  export STORAGE_CONNECTION_STRING=\"<storage-conn-string>\""
echo "  python consumer.py"

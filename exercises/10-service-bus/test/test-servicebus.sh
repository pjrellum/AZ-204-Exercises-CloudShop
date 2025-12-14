#!/bin/bash
# Test Service Bus by sending order messages

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Testing Service Bus ==="
echo ""

# Get connection string
SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

export SERVICEBUS_CONNECTION_STRING="$SERVICEBUS_CONNECTION"
export QUEUE_NAME="$QUEUE_NAME"

echo "Namespace: $SERVICEBUS_NAMESPACE"
echo "Queue: $QUEUE_NAME"
echo ""

# Check queue status before
echo "Queue status before sending:"
az servicebus queue show \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$QUEUE_NAME" \
    --query "{activeMessages:countDetails.activeMessageCount,deadLetter:countDetails.deadLetterMessageCount}" \
    -o table

echo ""
echo "Sending 3 test order messages..."
cd ../code/python/complete
pip install -q -r requirements.txt
python sender.py --count 3

echo ""
echo "=== Messages Sent ==="
echo ""

# Check queue status after
echo "Queue status after sending:"
az servicebus queue show \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name "$QUEUE_NAME" \
    --query "{activeMessages:countDetails.activeMessageCount,deadLetter:countDetails.deadLetterMessageCount}" \
    -o table

echo ""
echo "To receive messages, run:"
echo "  cd deploy && ./deploy-code.sh python receiver"

#!/bin/bash
# Exercise 10: Service Bus - Complete Solution

set -e

source ../../env.sh 2>/dev/null || source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Deploying Service Bus Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Create resource group
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Create Service Bus namespace
echo "Creating Service Bus namespace..."
az servicebus namespace create \
    --name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard \
    --output none

# Create order processing queue
echo "Creating queue: $QUEUE_NAME..."
az servicebus queue create \
    --name "$QUEUE_NAME" \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --max-delivery-count 3 \
    --default-message-time-to-live P1D \
    --output none

# Get connection string
SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo "Service Bus Namespace: $SERVICEBUS_NAMESPACE"
echo "Queue: $QUEUE_NAME"
echo ""
echo "Connection String:"
echo "$SERVICEBUS_CONNECTION"

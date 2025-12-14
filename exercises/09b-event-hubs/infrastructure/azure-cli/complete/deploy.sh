#!/bin/bash
# Exercise 09b: Event Hubs - Complete Solution

set -e

source ../../env.sh 2>/dev/null || source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Deploying Event Hubs Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Create resource group
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Create storage account (for checkpoints)
echo "Creating storage account..."
az storage account create \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --output none

# Create checkpoint container
az storage container create \
    --name checkpoints \
    --account-name "$STORAGE_NAME" \
    --output none

# Create Event Hubs namespace
echo "Creating Event Hubs namespace..."
az eventhubs namespace create \
    --name "$EVENTHUB_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard \
    --output none

# Create Event Hub with 4 partitions
echo "Creating Event Hub: $EVENTHUB_NAME..."
az eventhubs eventhub create \
    --name "$EVENTHUB_NAME" \
    --namespace-name "$EVENTHUB_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --partition-count 4 \
    --message-retention 1 \
    --output none

# Get connection string
EVENTHUB_CONNECTION=$(az eventhubs namespace authorization-rule keys list \
    --namespace-name "$EVENTHUB_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo "Event Hubs Namespace: $EVENTHUB_NAMESPACE"
echo "Event Hub: $EVENTHUB_NAME"
echo "Partitions: 4"
echo ""
echo "Connection String:"
echo "$EVENTHUB_CONNECTION"

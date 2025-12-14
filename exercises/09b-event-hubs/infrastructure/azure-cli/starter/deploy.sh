#!/bin/bash
# Exercise 09b: Event Hubs - Starter Template

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

# TODO 1: Create storage account for checkpoints
# Hint: az storage account create
echo "Creating storage account..."
# az storage account create \
#     --name ??? \
#     --resource-group ??? \
#     --location ??? \
#     --sku Standard_LRS

# TODO 2: Create checkpoint container
# Hint: az storage container create --name checkpoints
# az storage container create ...

# TODO 3: Create Event Hubs namespace
# Hint: az eventhubs namespace create with Standard SKU
echo "Creating Event Hubs namespace..."
# az eventhubs namespace create \
#     --name ??? \
#     --resource-group ??? \
#     --location ??? \
#     --sku ???

# TODO 4: Create Event Hub with 4 partitions
# Hint: az eventhubs eventhub create
echo "Creating Event Hub..."
# az eventhubs eventhub create \
#     --name ??? \
#     --namespace-name ??? \
#     --resource-group ??? \
#     --partition-count ??? \
#     --message-retention 1

# TODO 5: Get connection string
# Hint: az eventhubs namespace authorization-rule keys list
# EVENTHUB_CONNECTION=$(...)

echo ""
echo "=== Fill in the TODOs above ==="

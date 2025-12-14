#!/bin/bash
# Exercise 09a: Event Grid - Starter Template
# TODO: Fill in the missing commands

set -e

# Load environment variables
source ../../env.sh 2>/dev/null || source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Event Grid Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Unique Suffix: $UNIQUE_SUFFIX"
echo ""

# Create resource group if not exists
echo "Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

# TODO 1: Create storage account
# Hint: Use az storage account create
# Name should be: stcloudshop${UNIQUE_SUFFIX}
STORAGE_NAME="stcloudshop${UNIQUE_SUFFIX}"
echo "Creating storage account: $STORAGE_NAME..."
# az storage account create \
#     --name ??? \
#     --resource-group ??? \
#     --location ??? \
#     --sku Standard_LRS

# TODO 2: Create orders container
# Hint: Use az storage container create
echo "Creating orders container..."
# az storage container create \
#     --name ??? \
#     --account-name ???

# TODO 3: Create Function App for webhook
# Hint: Use az functionapp create
FUNC_NAME="func-cloudshop-processor-${UNIQUE_SUFFIX}"
echo "Creating Function App: $FUNC_NAME..."
# az functionapp create \
#     --name ??? \
#     --resource-group ??? \
#     --storage-account ??? \
#     --consumption-plan-location ??? \
#     --runtime python \
#     --runtime-version 3.11 \
#     --functions-version 4 \
#     --os-type Linux \
#     --disable-app-insights true

# TODO 4: Get storage account resource ID
# Hint: Use az storage account show --query id
# STORAGE_ID=$(az storage account show ...)

# TODO 5: Create Event Grid subscription
# Hint: Use az eventgrid event-subscription create
# - Subscribe to Microsoft.Storage.BlobCreated events
# - Filter to only .json files in orders/ container
echo "Creating Event Grid subscription..."
# az eventgrid event-subscription create \
#     --name order-uploaded \
#     --source-resource-id ??? \
#     --endpoint ??? \
#     --endpoint-type webhook \
#     --included-event-types ???

echo ""
echo "=== Fill in the TODOs above to complete deployment ==="

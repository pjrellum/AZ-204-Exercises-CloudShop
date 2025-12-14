#!/bin/bash
# Exercise 09a: Event Grid - Complete Solution
# This script deploys all infrastructure for Event Grid exercise

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

# Create storage account
STORAGE_NAME="stcloudshop${UNIQUE_SUFFIX}"
echo "Creating storage account: $STORAGE_NAME..."
az storage account create \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --output none

# Create orders container
echo "Creating orders container..."
az storage container create \
    --name orders \
    --account-name "$STORAGE_NAME" \
    --output none

# Create dead-letter container
echo "Creating dead-letter container..."
az storage container create \
    --name deadletter \
    --account-name "$STORAGE_NAME" \
    --output none

# Create Function App for webhook
FUNC_NAME="func-cloudshop-processor-${UNIQUE_SUFFIX}"
echo "Creating Function App: $FUNC_NAME..."

# Create App Service Plan (Consumption)
az functionapp create \
    --name "$FUNC_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --storage-account "$STORAGE_NAME" \
    --consumption-plan-location "$LOCATION" \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --os-type Linux \
    --disable-app-insights true \
    --output none

# Get Function App URL
FUNC_URL=$(az functionapp show \
    --name "$FUNC_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "defaultHostName" -o tsv)

WEBHOOK_URL="https://${FUNC_URL}/api/OrderUploaded"
echo "Webhook URL: $WEBHOOK_URL"

# Get storage account resource ID
STORAGE_ID=$(az storage account show \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query id -o tsv)

# Create Event Grid subscription
echo "Creating Event Grid subscription..."
az eventgrid event-subscription create \
    --name order-uploaded \
    --source-resource-id "$STORAGE_ID" \
    --endpoint "$WEBHOOK_URL" \
    --endpoint-type webhook \
    --included-event-types Microsoft.Storage.BlobCreated \
    --subject-begins-with "/blobServices/default/containers/orders/blobs/" \
    --subject-ends-with ".json" \
    --output none 2>/dev/null || echo "Note: Event Grid subscription will be created after Function is deployed"

echo ""
echo "=== Deployment Complete ==="
echo "Storage Account: $STORAGE_NAME"
echo "Function App: $FUNC_NAME"
echo "Webhook URL: $WEBHOOK_URL"
echo ""
echo "Next steps:"
echo "1. Deploy the function code: cd ../../code && ./deploy.sh"
echo "2. Create the Event Grid subscription (if not created above)"

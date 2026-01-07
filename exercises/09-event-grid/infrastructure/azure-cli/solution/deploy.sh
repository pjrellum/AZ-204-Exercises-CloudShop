#!/bin/bash
# Exercise 09: Event Grid - Complete Solution
# This script deploys Event Grid infrastructure (assumes Function App exists from Exercise 08)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

FUNC_NAME="func-cloudshop-${UNIQUE_SUFFIX}"
STORAGE_NAME="stcloudshop${UNIQUE_SUFFIX}"

echo "=== Deploying Event Grid Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Function App: $FUNC_NAME (from Exercise 08)"
echo ""

# Verify Function App exists
echo "Verifying Function App exists..."
az functionapp show \
    --name "$FUNC_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --output none 2>/dev/null || {
    echo "Error: Function App $FUNC_NAME not found."
    echo "Please complete Exercise 08 first to create the Function App."
    exit 1
}
echo "      ✓ Function App exists"

# Create orders container
echo "Creating orders container..."
az storage container create \
    --name orders \
    --account-name "$STORAGE_NAME" \
    --output none 2>/dev/null || true

echo "      ✓ Orders container ready"

# Create dead-letter container
echo "Creating dead-letter container..."
az storage container create \
    --name deadletter \
    --account-name "$STORAGE_NAME" \
    --output none 2>/dev/null || true

echo "      ✓ Dead-letter container ready"

# Get storage account resource ID (for later use)
STORAGE_ID=$(az storage account show \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query id -o tsv)

echo ""
echo "=== Infrastructure Deployment Complete ==="
echo "Storage Account: $STORAGE_NAME"
echo "Function App: $FUNC_NAME"
echo "Storage ID: $STORAGE_ID"
echo ""
echo "Next steps:"
echo "1. Deploy the function code:"
echo "   cd ../../code/dotnet && ./deploy.sh"
echo ""
echo "2. Wait 30 seconds for function to be ready, then create Event Grid subscription:"
echo "   az eventgrid event-subscription create \\"
echo "       --name order-uploaded \\"
echo "       --source-resource-id \"$STORAGE_ID\" \\"
echo "       --endpoint \"https://${FUNC_NAME}.azurewebsites.net/api/OrderUploaded\" \\"
echo "       --endpoint-type webhook \\"
echo "       --included-event-types Microsoft.Storage.BlobCreated \\"
echo "       --subject-begins-with \"/blobServices/default/containers/orders/blobs/\" \\"
echo "       --subject-ends-with \".json\" \\"
echo "       --deadletter-endpoint \"${STORAGE_ID}/blobServices/default/containers/deadletter\""

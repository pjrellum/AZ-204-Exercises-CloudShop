#!/bin/bash
# Quick deployment - deploys everything for Event Grid exercise

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

source env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== CloudShop Event Grid - Quick Deploy ==="
echo "This will deploy all infrastructure and code."
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Deploy infrastructure
echo ""
echo "=== Step 1: Deploying Infrastructure ==="
cd infrastructure/azure-cli/complete
chmod +x deploy.sh
./deploy.sh

# Deploy code
echo ""
echo "=== Step 2: Deploying Function Code ==="
cd ../../../code/dotnet/complete
chmod +x deploy.sh
./deploy.sh

# Wait for function to be ready
echo ""
echo "Waiting for function to be ready..."
sleep 30

# Create Event Grid subscription (if not created during infra deploy)
echo ""
echo "=== Step 3: Creating Event Grid Subscription ==="
STORAGE_ID=$(az storage account show \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query id -o tsv)

WEBHOOK_URL="https://${FUNC_NAME}.azurewebsites.net/api/OrderUploaded"

az eventgrid event-subscription create \
    --name order-uploaded \
    --source-resource-id "$STORAGE_ID" \
    --endpoint "$WEBHOOK_URL" \
    --endpoint-type webhook \
    --included-event-types Microsoft.Storage.BlobCreated \
    --subject-begins-with "/blobServices/default/containers/orders/blobs/" \
    --subject-ends-with ".json" \
    --output none 2>/dev/null || echo "Event Grid subscription already exists or webhook not ready"

# Validate
echo ""
echo "=== Step 4: Validating Deployment ==="
cd ../validate
chmod +x check-all.sh
./check-all.sh || true

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Test the integration:"
echo "  cd test && ./test-eventgrid.sh"

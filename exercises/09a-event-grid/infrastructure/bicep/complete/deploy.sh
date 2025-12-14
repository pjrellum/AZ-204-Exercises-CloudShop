#!/bin/bash
# Deploy Event Grid exercise using Bicep

set -e

# Load environment variables
source ../../../env.sh 2>/dev/null || source ../../env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Event Grid Infrastructure (Bicep) ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Unique Suffix: $UNIQUE_SUFFIX"
echo ""

# Create resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

# Deploy Bicep template
echo "Deploying Bicep template..."
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters uniqueSuffix="$UNIQUE_SUFFIX" \
    --query "properties.outputs" \
    --output table

echo ""
echo "=== Deployment Complete ==="
echo "Next: Deploy the function code with: cd ../../../code && ./deploy.sh"

#!/bin/bash
# =============================================================================
# Deploy Bicep template for Exercise 08
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Bicep template ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Unique Suffix: $UNIQUE_SUFFIX"
echo ""

# Create resource group if it doesn't exist
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Deploy Bicep template
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$SCRIPT_DIR/main.bicep" \
    --parameters uniqueSuffix="$UNIQUE_SUFFIX" \
    --output table

echo ""
echo "=== Deployment complete ==="
echo ""
echo "To see outputs:"
echo "az deployment group show -g $RESOURCE_GROUP -n main --query properties.outputs"

#!/bin/bash
# Exercise 11: Application Insights - Bicep Deployment Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$SCRIPT_DIR/../.."

source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Application Insights Infrastructure (Bicep) ==="
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Create resource group
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Deploy Bicep template
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$SCRIPT_DIR/main.bicep" \
    --parameters uniqueSuffix="$UNIQUE_SUFFIX" \
    --output table

# Get connection string
AI_CONNECTION=$(az monitor app-insights component show \
    --app "$APPINSIGHTS_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)

AI_KEY=$(az monitor app-insights component show \
    --app "$APPINSIGHTS_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query instrumentationKey -o tsv)

echo ""
echo "=== Connecting to Azure Functions ==="

# Check if Function App exists and connect it
if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "Connecting Function App: $FUNC_NAME..."
    az functionapp config appsettings set \
        --name "$FUNC_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CONNECTION" \
        --output none
    echo "Function App connected."
else
    echo "Function App $FUNC_NAME not found. Connect it manually later."
fi

echo ""
echo "=== Deployment Complete ==="
echo "Application Insights: $APPINSIGHTS_NAME"
echo ""
echo "Connection String:"
echo "$AI_CONNECTION"
echo ""
echo "Instrumentation Key:"
echo "$AI_KEY"

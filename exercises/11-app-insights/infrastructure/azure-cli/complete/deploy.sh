#!/bin/bash
# Exercise 11: Application Insights - Complete Solution

set -e

source ../../env.sh 2>/dev/null || source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Deploying Application Insights Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Create resource group if needed
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Create Application Insights
echo "Creating Application Insights..."
az monitor app-insights component create \
    --app "$APPINSIGHTS_NAME" \
    --location "$LOCATION" \
    --resource-group "$RESOURCE_GROUP" \
    --application-type web \
    --output none

# Get connection string and instrumentation key
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

# Check if Function App exists
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

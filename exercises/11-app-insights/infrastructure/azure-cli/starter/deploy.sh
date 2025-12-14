#!/bin/bash
# Exercise 11: Application Insights - Starter Template

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

# TODO 1: Create Application Insights
# Hint: az monitor app-insights component create
echo "Creating Application Insights..."
# az monitor app-insights component create \
#     --app ??? \
#     --location ??? \
#     --resource-group ??? \
#     --application-type web

# TODO 2: Get connection string
# Hint: az monitor app-insights component show --query connectionString
# AI_CONNECTION=$(...)

# TODO 3: Get instrumentation key
# Hint: az monitor app-insights component show --query instrumentationKey
# AI_KEY=$(...)

# TODO 4: (Optional) Connect to existing Function App
# Check if Function App exists, then update its settings
# if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
#     az functionapp config appsettings set \
#         --name "$FUNC_NAME" \
#         --resource-group "$RESOURCE_GROUP" \
#         --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CONNECTION"
# fi

echo ""
echo "=== Fill in the TODOs above ==="

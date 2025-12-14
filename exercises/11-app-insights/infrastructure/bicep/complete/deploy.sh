#!/bin/bash
# Exercise 11: Application Insights - Bicep Deployment Script

set -e

source ../../../env.sh 2>/dev/null || source ../../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
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
    --template-file main.bicep \
    --parameters uniqueSuffix="$UNIQUE_SUFFIX" \
    --output table

# Get connection string
AI_CONNECTION=$(az monitor app-insights component show \
    --app "ai-cloudshop-$UNIQUE_SUFFIX" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)

AI_KEY=$(az monitor app-insights component show \
    --app "ai-cloudshop-$UNIQUE_SUFFIX" \
    --resource-group "$RESOURCE_GROUP" \
    --query instrumentationKey -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo "Application Insights: ai-cloudshop-$UNIQUE_SUFFIX"
echo ""
echo "Connection String:"
echo "$AI_CONNECTION"
echo ""
echo "Instrumentation Key:"
echo "$AI_KEY"

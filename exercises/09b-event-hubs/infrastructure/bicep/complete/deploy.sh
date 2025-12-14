#!/bin/bash
# Exercise 09b: Event Hubs - Bicep Deployment Script

set -e

source ../../../env.sh 2>/dev/null || source ../../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Deploying Event Hubs Infrastructure (Bicep) ==="
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
EVENTHUB_CONNECTION=$(az eventhubs namespace authorization-rule keys list \
    --namespace-name "evhns-cloudshop-$UNIQUE_SUFFIX" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo "Event Hubs Namespace: evhns-cloudshop-$UNIQUE_SUFFIX"
echo "Event Hub: clickstream"
echo ""
echo "Connection String:"
echo "$EVENTHUB_CONNECTION"

#!/bin/bash
# Exercise 10: Service Bus - Bicep Deployment Script

set -e

source ../../../env.sh 2>/dev/null || source ../../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Deploying Service Bus Infrastructure (Bicep) ==="
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
SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
    --namespace-name "sbns-cloudshop-$UNIQUE_SUFFIX" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo "Service Bus Namespace: sbns-cloudshop-$UNIQUE_SUFFIX"
echo "Queue: order-processor"
echo ""
echo "Connection String:"
echo "$SERVICEBUS_CONNECTION"

#!/bin/bash
# Exercise 10: Service Bus - Bicep Deployment Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$SCRIPT_DIR/../.."

source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
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
    --template-file "$SCRIPT_DIR/main.bicep" \
    --parameters uniqueSuffix="$UNIQUE_SUFFIX" \
    --output table

# Get connection string
SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo "Service Bus Namespace: $SERVICEBUS_NAMESPACE"
echo "Queue: $QUEUE_NAME"
echo ""
echo "Connection String:"
echo "$SERVICEBUS_CONNECTION"

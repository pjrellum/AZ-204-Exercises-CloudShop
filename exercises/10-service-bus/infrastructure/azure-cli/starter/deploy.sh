#!/bin/bash
# Exercise 10: Service Bus - Starter Template

set -e

source ../../env.sh 2>/dev/null || source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Deploying Service Bus Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Create resource group
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# TODO 1: Create Service Bus namespace
# Hint: az servicebus namespace create with Standard SKU
echo "Creating Service Bus namespace..."
# az servicebus namespace create \
#     --name ??? \
#     --resource-group ??? \
#     --location ??? \
#     --sku ???

# TODO 2: Create order processing queue
# Hint: az servicebus queue create
# Properties: max-delivery-count 3, default-message-time-to-live P1D
echo "Creating queue..."
# az servicebus queue create \
#     --name ??? \
#     --namespace-name ??? \
#     --resource-group ??? \
#     --max-delivery-count ??? \
#     --default-message-time-to-live ???

# TODO 3: Get connection string
# Hint: az servicebus namespace authorization-rule keys list
# SERVICEBUS_CONNECTION=$(...)

echo ""
echo "=== Fill in the TODOs above ==="

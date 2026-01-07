#!/bin/bash
# Exercise 10: Service Bus - Complete Solution
# Deploys Service Bus and configures Function App connection

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$SCRIPT_DIR/../../.."

source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

FUNC_NAME="func-cloudshop-${UNIQUE_SUFFIX}"
SERVICEBUS_NAMESPACE="sbns-cloudshop-${UNIQUE_SUFFIX}"
QUEUE_NAME="orders"

echo "=== Deploying Service Bus Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Function App: $FUNC_NAME (from Exercise 08)"
echo ""

# Verify Function App exists
echo "Verifying Function App exists..."
az functionapp show \
    --name "$FUNC_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --output none 2>/dev/null || {
    echo "Error: Function App $FUNC_NAME not found."
    echo "Please complete Exercise 08 first."
    exit 1
}
echo "      ✓ Function App exists"

# Create Service Bus namespace
echo "Creating Service Bus namespace: $SERVICEBUS_NAMESPACE..."
az servicebus namespace create \
    --name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard \
    --output none

echo "      ✓ Service Bus namespace created"

# Create orders queue
echo "Creating queue: $QUEUE_NAME..."
az servicebus queue create \
    --name "$QUEUE_NAME" \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --max-delivery-count 3 \
    --default-message-time-to-live P1D \
    --lock-duration PT1M \
    --enable-dead-lettering-on-message-expiration \
    --output none

echo "      ✓ Queue created"

# Get connection string
echo "Getting connection string..."
SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
    --namespace-name "$SERVICEBUS_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

# Configure Function App with Service Bus connection
echo "Configuring Function App with Service Bus connection..."
az functionapp config appsettings set \
    --name "$FUNC_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings "ServiceBusConnection=$SERVICEBUS_CONNECTION" \
    --output none

echo "      ✓ Function App configured"

echo ""
echo "=== Deployment Complete ==="
echo "Service Bus Namespace: $SERVICEBUS_NAMESPACE"
echo "Queue: $QUEUE_NAME"
echo "Function App: $FUNC_NAME (configured with ServiceBusConnection)"
echo ""
echo "Next steps:"
echo "1. Deploy the function code: cd ../../code/dotnet && func azure functionapp publish $FUNC_NAME"
echo "2. Test by posting an order to the API"

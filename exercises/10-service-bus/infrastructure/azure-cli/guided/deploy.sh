#!/bin/bash
# Exercise 10: Service Bus - Guided Template
#
# Instructions:
# 1. Fill in the ??? placeholders with correct values
# 2. Uncomment each section one at a time
# 3. Run the script - it's safe to run multiple times
#
# Tip: Use $RESOURCE_GROUP, $LOCATION, $SERVICEBUS_NAMESPACE, $QUEUE_NAME from env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$SCRIPT_DIR/../../.."

source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Service Bus Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""

# ============================================================
# Step 1: Create Service Bus Namespace
# ============================================================
echo "Step 1: Service Bus Namespace..."
# Hint: az servicebus namespace create --name <name> --sku Standard
# Note: Standard tier required for topics
#
# if ! az servicebus namespace show --name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" &>/dev/null 2>&1; then
#     az servicebus namespace create \
#         --name ??? \
#         --resource-group ??? \
#         --location ??? \
#         --sku ??? \
#         --output none
#     echo "  Created: $SERVICEBUS_NAMESPACE"
# else
#     echo "  Already exists: $SERVICEBUS_NAMESPACE"
# fi

# ============================================================
# Step 2: Create Orders Queue
# ============================================================
echo "Step 2: Orders Queue..."
# Hint: az servicebus queue create with dead-letter settings
# - max-delivery-count: retries before dead-letter (e.g., 3)
# - default-message-time-to-live: expiration (e.g., P1D = 1 day)
#
# if ! az servicebus queue show --name "$QUEUE_NAME" --namespace-name "$SERVICEBUS_NAMESPACE" --resource-group "$RESOURCE_GROUP" &>/dev/null 2>&1; then
#     az servicebus queue create \
#         --name ??? \
#         --namespace-name ??? \
#         --resource-group ??? \
#         --max-delivery-count ??? \
#         --default-message-time-to-live ??? \
#         --dead-lettering-on-message-expiration \
#         --output none
#     echo "  Created: $QUEUE_NAME"
# else
#     echo "  Already exists: $QUEUE_NAME"
# fi

# ============================================================
# Step 3: Get Connection String
# ============================================================
echo "Step 3: Getting Connection String..."
# Hint: az servicebus namespace authorization-rule keys list
#
# SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
#     --namespace-name ??? \
#     --resource-group ??? \
#     --name RootManageSharedAccessKey \
#     --query primaryConnectionString -o tsv)
# echo "  Connection string retrieved"

# ============================================================
# Step 4: Configure Function App Connection
# ============================================================
echo "Step 4: Configure Function App..."
# Hint: az functionapp config appsettings set
# Note: Function App must exist from Exercise 08
#
# if [ -n "$SERVICEBUS_CONNECTION" ]; then
#     az functionapp config appsettings set \
#         --name ??? \
#         --resource-group ??? \
#         --settings ServiceBusConnection="$SERVICEBUS_CONNECTION" \
#         --output none
#     echo "  Configured: ServiceBusConnection on $FUNC_NAME"
# else
#     echo "  Skipped: Get connection string first (Step 3)"
# fi

echo ""
echo "=== Infrastructure Complete ==="
echo ""
echo "Fill in the ??? placeholders and uncomment each section."
echo ""
echo "Variables available from env.sh:"
echo "  RESOURCE_GROUP=$RESOURCE_GROUP"
echo "  LOCATION=$LOCATION"
echo "  SERVICEBUS_NAMESPACE=$SERVICEBUS_NAMESPACE"
echo "  QUEUE_NAME=$QUEUE_NAME"
echo "  FUNC_NAME=$FUNC_NAME"
echo ""
echo "Next steps (see README.md):"
echo "  1. Deploy function code:  cd code/dotnet && ./deploy.sh"
echo "  2. Test with Service Bus Explorer in Azure Portal"

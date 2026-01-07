#!/bin/bash
# Exercise 09: Event Grid - Guided Template
#
# Instructions:
# 1. Fill in the ??? placeholders with correct values
# 2. Uncomment each section one at a time
# 3. Run the script - it's safe to run multiple times
#
# Tip: Use $RESOURCE_GROUP, $LOCATION, $STORAGE_NAME, $FUNC_NAME from env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Event Grid Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""

# ============================================================
# Step 1: Create Storage Container for Orders
# ============================================================
echo "Step 1: Orders Container..."
# Hint: az storage container create --name <name> --account-name <storage>
# Note: Storage account should exist from Exercise 08
#
# if ! az storage container show --name "orders" --account-name "$STORAGE_NAME" &>/dev/null 2>&1; then
#     az storage container create \
#         --name ??? \
#         --account-name ??? \
#         --output none
#     echo "  Created: orders container"
# else
#     echo "  Already exists: orders container"
# fi

# ============================================================
# Step 2: Create Dead-letter Container
# ============================================================
echo "Step 2: Dead-letter Container..."
# Hint: Same as above, but for dead-letter events
#
# if ! az storage container show --name "deadletter" --account-name "$STORAGE_NAME" &>/dev/null 2>&1; then
#     az storage container create \
#         --name ??? \
#         --account-name ??? \
#         --output none
#     echo "  Created: deadletter container"
# else
#     echo "  Already exists: deadletter container"
# fi

# ============================================================
# Step 3: Get Storage Account Resource ID
# ============================================================
echo "Step 3: Getting Storage Account ID..."
# Hint: az storage account show --name <name> --resource-group <rg> --query id -o tsv
#
# STORAGE_ID=$(az storage account show \
#     --name ??? \
#     --resource-group ??? \
#     --query id -o tsv)
# echo "  Storage ID: $STORAGE_ID"

# ============================================================
# Step 4: Create Event Grid Subscription
# ============================================================
# IMPORTANT: Deploy function code FIRST before uncommenting this step!
#            Event Grid validates the webhook endpoint during creation.
#
# echo "Step 4: Event Grid Subscription..."
# Hint: az eventgrid event-subscription create
#
FUNC_URL="https://${FUNC_NAME}.azurewebsites.net/api/OrderUploaded"
DEADLETTER_ENDPOINT="${STORAGE_ID}/blobServices/default/containers/deadletter"

# Check if subscription exists
if ! az eventgrid event-subscription show --name "order-uploaded" --source-resource-id "$STORAGE_ID" &>/dev/null 2>&1; then
    az eventgrid event-subscription create \
        --name ??? \
        --source-resource-id ??? \
        --endpoint ??? \
        --endpoint-type webhook \
        --included-event-types ??? \
        --subject-begins-with "/blobServices/default/containers/orders/blobs/" \
        --subject-ends-with ".json" \
        --deadletter-endpoint ??? \
        --output none
    echo "  Created: order-uploaded subscription"
else
    echo "  Already exists: order-uploaded subscription"
fi

echo ""
echo "=== Infrastructure Complete ==="
echo ""
echo "Fill in the ??? placeholders and uncomment each section."
echo ""
echo "Variables available from env.sh:"
echo "  RESOURCE_GROUP=$RESOURCE_GROUP"
echo "  LOCATION=$LOCATION"
echo "  STORAGE_NAME=$STORAGE_NAME"
echo "  FUNC_NAME=$FUNC_NAME"
echo ""
echo "IMPORTANT: Deploy function code BEFORE Step 4!"
echo "  Event Grid validates the webhook endpoint during subscription creation."
echo "  See README.md for the correct order of steps."

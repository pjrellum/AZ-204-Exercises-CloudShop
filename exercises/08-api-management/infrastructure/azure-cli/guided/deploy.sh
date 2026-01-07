#!/bin/bash
# Exercise 08: API Management - Guided Template
#
# Instructions:
# 1. Fill in the ??? placeholders with correct values
# 2. Uncomment each section one at a time
# 3. Run the script - it's safe to run multiple times
#
# Tip: Use $RESOURCE_GROUP, $LOCATION, $STORAGE_NAME, $FUNC_NAME, $APIM_NAME from env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying API Management Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""

# ============================================================
# Step 1: Create Resource Group
# ============================================================
echo "Step 1: Resource Group..."
# Hint: az group create --name <name> --location <location>
#
# if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
#     az group create \
#         --name ??? \
#         --location ??? \
#         --output none
#     echo "  Created: $RESOURCE_GROUP"
# else
#     echo "  Already exists: $RESOURCE_GROUP"
# fi

# ============================================================
# Step 2: Create Storage Account
# ============================================================
echo "Step 2: Storage Account..."
# Hint: az storage account create --name <name> --resource-group <rg> --sku Standard_LRS
#
# if ! az storage account show --name "$STORAGE_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
#     az storage account create \
#         --name ??? \
#         --resource-group ??? \
#         --location ??? \
#         --sku Standard_LRS \
#         --output none
#     echo "  Created: $STORAGE_NAME"
# else
#     echo "  Already exists: $STORAGE_NAME"
# fi

# ============================================================
# Step 3: Create Function App
# ============================================================
echo "Step 3: Function App..."
# Hint: az functionapp create --name <name> --resource-group <rg> --storage-account <storage>
#
# if ! az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
#     az functionapp create \
#         --name ??? \
#         --resource-group ??? \
#         --consumption-plan-location ??? \
#         --runtime dotnet-isolated \
#         --runtime-version 8 \
#         --functions-version 4 \
#         --storage-account ??? \
#         --disable-app-insights true \
#         --output none
#     echo "  Created: $FUNC_NAME"
# else
#     echo "  Already exists: $FUNC_NAME"
# fi

# ============================================================
# Step 4: Create API Management (takes 2-3 minutes)
# ============================================================
echo "Step 4: API Management..."
# Hint: az apim create --name <name> --resource-group <rg> --sku-name Consumption
#
# if ! az apim show --name "$APIM_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null 2>&1; then
#     echo "  Creating APIM (this takes 2-3 minutes)..."
#     az apim create \
#         --name ??? \
#         --resource-group ??? \
#         --publisher-name "CloudShop" \
#         --publisher-email "admin@cloudshop.example" \
#         --sku-name Consumption \
#         --location ??? \
#         --output none
#     echo "  Created: $APIM_NAME"
# else
#     echo "  Already exists: $APIM_NAME"
# fi

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
echo "  APIM_NAME=$APIM_NAME"
echo ""
echo "Next steps (see README.md):"
echo "  1. Deploy function code:  cd code/dotnet && ./deploy.sh"
echo "  2. Create API and operations in APIM (CLI)"
echo "  3. Test the API"

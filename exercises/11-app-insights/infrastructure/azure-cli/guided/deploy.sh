#!/bin/bash
# Exercise 11: Application Insights - Guided Template
#
# Instructions:
# 1. Fill in the ??? placeholders with correct values
# 2. Uncomment each section one at a time
# 3. Run the script - it's safe to run multiple times
#
# Tip: Use $RESOURCE_GROUP, $LOCATION, $APPINSIGHTS_NAME, $FUNC_NAME from env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$SCRIPT_DIR/../../.."

source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying Application Insights Infrastructure ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""

# ============================================================
# Step 1: Create Application Insights
# ============================================================
echo "Step 1: Application Insights..."
# Hint: az monitor app-insights component create --app <name> --application-type web
#
# if ! az monitor app-insights component show --app "$APPINSIGHTS_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null 2>&1; then
#     az monitor app-insights component create \
#         --app ??? \
#         --location ??? \
#         --resource-group ??? \
#         --application-type web \
#         --output none
#     echo "  Created: $APPINSIGHTS_NAME"
# else
#     echo "  Already exists: $APPINSIGHTS_NAME"
# fi

# ============================================================
# Step 2: Get Connection String
# ============================================================
echo "Step 2: Getting Connection String..."
# Hint: az monitor app-insights component show --query connectionString
#
# AI_CONNECTION=$(az monitor app-insights component show \
#     --app ??? \
#     --resource-group ??? \
#     --query connectionString -o tsv)
# echo "  Connection string: ${AI_CONNECTION:0:50}..."

# ============================================================
# Step 3: Connect Function App (Optional)
# ============================================================
echo "Step 3: Connecting Function App..."
# Hint: az functionapp config appsettings set
# Note: Function App must exist from Exercise 08
#
# if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null 2>&1; then
#     az functionapp config appsettings set \
#         --name ??? \
#         --resource-group ??? \
#         --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=???" \
#         --output none
#     echo "  Connected: $FUNC_NAME"
# else
#     echo "  Skipped: Function App not found"
# fi

echo ""
echo "=== Infrastructure Complete ==="
echo ""
echo "Fill in the ??? placeholders and uncomment each section."
echo ""
echo "Variables available from env.sh:"
echo "  RESOURCE_GROUP=$RESOURCE_GROUP"
echo "  LOCATION=$LOCATION"
echo "  APPINSIGHTS_NAME=$APPINSIGHTS_NAME"
echo "  FUNC_NAME=$FUNC_NAME"
echo "  APIM_NAME=$APIM_NAME"
echo ""
echo "Next steps (see README.md):"
echo "  1. Connect APIM (optional):  ./deploy/configure-apim.sh"
echo "  2. Generate traffic and explore in Azure Portal"

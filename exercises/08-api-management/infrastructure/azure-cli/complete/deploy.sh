#!/bin/bash
# =============================================================================
# CloudShop Exercise 08 - Infrastructure Deployment (Azure CLI)
# =============================================================================
# COMPLETE SOLUTION - Ready to run
# =============================================================================

set -e  # Exit on error

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== CloudShop Exercise 08 - Infrastructure Setup ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Unique Suffix: $UNIQUE_SUFFIX"
echo ""

# -----------------------------------------------------------------------------
# Step 1: Create Resource Group
# -----------------------------------------------------------------------------
echo "[1/4] Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

echo "      ✓ Resource group created"

# -----------------------------------------------------------------------------
# Step 2: Create Storage Account
# -----------------------------------------------------------------------------
echo "[2/4] Creating storage account..."
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --output none

echo "      ✓ Storage account created: $STORAGE_ACCOUNT"

# -----------------------------------------------------------------------------
# Step 3: Create Function App
# -----------------------------------------------------------------------------
echo "[3/4] Creating Function App (this may take a minute)..."

# Default to dotnet-isolated, but check for FUNCTION_RUNTIME env var
RUNTIME="${FUNCTION_RUNTIME:-dotnet-isolated}"
RUNTIME_VERSION="${FUNCTION_RUNTIME_VERSION:-8}"

az functionapp create \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --consumption-plan-location "$LOCATION" \
    --runtime "$RUNTIME" \
    --runtime-version "$RUNTIME_VERSION" \
    --functions-version 4 \
    --storage-account "$STORAGE_ACCOUNT" \
    --disable-app-insights true \
    $OS_TYPE \
    --output none

echo "      ✓ Function App created: $FUNCTION_APP"

# -----------------------------------------------------------------------------
# Step 4: Create API Management
# -----------------------------------------------------------------------------
echo "[4/4] Creating API Management instance (Consumption tier, ~2 minutes)..."
az apim create \
    --name "$APIM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --publisher-name "CloudShop" \
    --publisher-email "admin@cloudshop.example.com" \
    --sku-name Consumption \
    --location "$LOCATION" \
    --output none

echo "      ✓ API Management created: $APIM_NAME"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "=== Infrastructure created successfully! ==="
echo ""
echo "Resources:"
echo "  Resource Group:   $RESOURCE_GROUP"
echo "  Storage Account:  $STORAGE_ACCOUNT"
echo "  Function App:     $FUNCTION_APP"
echo "  API Management:   $APIM_NAME"
echo ""
echo "Function URL:  https://$FUNCTION_APP.azurewebsites.net"
echo "APIM URL:      https://$APIM_NAME.azure-api.net"
echo ""
echo "Next steps:"
echo "  1. Deploy your function code:  ./code/.../.../deploy.sh"
echo "  2. Import API into APIM:       See instructions/05-configure-api.md"
echo "  3. Test the API:               ./test/test-api.sh"

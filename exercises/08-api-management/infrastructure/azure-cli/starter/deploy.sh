#!/bin/bash
# =============================================================================
# CloudShop Exercise 08 - Infrastructure Deployment (Azure CLI)
# =============================================================================
# STARTER TEMPLATE - Fill in the TODOs
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
echo ""

# -----------------------------------------------------------------------------
# Step 1: Create Resource Group (if not exists)
# -----------------------------------------------------------------------------
echo "Creating resource group..."
# TODO: Create resource group using az group create
# Hint: az group create --name <name> --location <location>


# -----------------------------------------------------------------------------
# Step 2: Create Storage Account
# -----------------------------------------------------------------------------
echo "Creating storage account..."
# TODO: Create storage account using az storage account create
# Required: --name, --resource-group, --location, --sku Standard_LRS
# Hint: Storage account names must be lowercase, no hyphens, 3-24 characters


# -----------------------------------------------------------------------------
# Step 3: Create Function App
# -----------------------------------------------------------------------------
echo "Creating Function App..."
# TODO: Create function app using az functionapp create
# Required: --name, --resource-group, --consumption-plan-location
#           --runtime, --runtime-version, --functions-version 4
#           --storage-account, --disable-app-insights true
# Hint: For .NET use: --runtime dotnet-isolated --runtime-version 8


# -----------------------------------------------------------------------------
# Step 4: Create API Management
# -----------------------------------------------------------------------------
echo "Creating API Management instance..."
# TODO: Create APIM using az apim create
# Required: --name, --resource-group, --publisher-name, --publisher-email
#           --sku-name Consumption, --location
# Note: Consumption tier takes ~2 minutes to provision


# -----------------------------------------------------------------------------
# Done!
# -----------------------------------------------------------------------------
echo ""
echo "=== Infrastructure created successfully! ==="
echo ""
echo "Next steps:"
echo "1. Deploy your function code (see ../code/ folder)"
echo "2. Import the function into APIM (see instructions/05-configure-api.md)"

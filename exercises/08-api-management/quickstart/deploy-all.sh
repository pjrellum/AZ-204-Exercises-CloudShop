#!/bin/bash
# =============================================================================
# QuickStart: Deploy Everything for Exercise 08
# =============================================================================
# This script deploys all infrastructure and code in one go.
# Use this for demos or if you fall behind.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "========================================="
    echo "First-time setup: Creating env.sh"
    echo "========================================="

    # Generate a random suffix
    RANDOM_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 6)

    cp "$EXERCISE_DIR/env.example.sh" "$EXERCISE_DIR/env.sh"
    sed -i.bak "s/<your-suffix>/$RANDOM_SUFFIX/" "$EXERCISE_DIR/env.sh"
    rm -f "$EXERCISE_DIR/env.sh.bak"

    source "$EXERCISE_DIR/env.sh"
    echo "Generated suffix: $UNIQUE_SUFFIX"
    echo ""
}

echo "========================================="
echo "CloudShop Exercise 08 - QuickStart"
echo "========================================="
echo ""
echo "This will deploy:"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - Storage Account: $STORAGE_ACCOUNT"
echo "  - Function App: $FUNCTION_APP"
echo "  - API Management: $APIM_NAME"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "[1/4] Creating infrastructure..."
"$EXERCISE_DIR/infrastructure/azure-cli/complete/deploy.sh"

echo ""
echo "[2/4] Deploying function code..."
"$EXERCISE_DIR/code/dotnet/complete/deploy.sh"

echo ""
echo "[3/4] Importing API into APIM..."
FUNCTION_URL="https://$FUNCTION_APP.azurewebsites.net/api"

az apim api import \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --api-id orders-api \
    --path orders \
    --display-name "Orders API" \
    --service-url "$FUNCTION_URL" \
    --protocols https \
    --subscription-required true \
    --output none

echo "      ✓ API imported"

echo ""
echo "[4/4] Getting subscription key..."
SUBSCRIPTION_KEY=$(az apim subscription show \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --subscription-id master \
    --query primaryKey -o tsv)

echo ""
echo "========================================="
echo "  QuickStart Complete!"
echo "========================================="
echo ""
echo "Function URL:  https://$FUNCTION_APP.azurewebsites.net/api/orders"
echo "APIM URL:      https://$APIM_NAME.azure-api.net/orders"
echo ""
echo "Subscription Key: $SUBSCRIPTION_KEY"
echo ""
echo "Test directly:"
echo "  curl https://$FUNCTION_APP.azurewebsites.net/api/orders"
echo ""
echo "Test through APIM:"
echo "  curl -H 'Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY' \\"
echo "    https://$APIM_NAME.azure-api.net/orders"
echo ""
echo "Run validation:"
echo "  ./validate/check-all.sh"

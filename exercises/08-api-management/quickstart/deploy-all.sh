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
echo "  - Storage Account: $STORAGE_NAME"
echo "  - Function App: $FUNC_NAME"
echo "  - API Management: $APIM_NAME"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "[1/5] Creating infrastructure..."
"$EXERCISE_DIR/infrastructure/azure-cli/solution/deploy.sh"

echo ""
echo "[2/5] Deploying function code..."
"$EXERCISE_DIR/code/dotnet/deploy.sh"

echo ""
echo "[3/5] Creating API in APIM..."
FUNCTION_URL="https://$FUNC_NAME.azurewebsites.net/api"

az apim api create \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --api-id orders-api \
    --path orders \
    --display-name "Orders API" \
    --service-url "$FUNCTION_URL" \
    --protocols https \
    --subscription-required true \
    --output none

echo "      ✓ API created"

echo ""
echo "[4/5] Adding API operations..."

# GET /orders - List all orders
az apim api operation create \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --api-id orders-api \
    --operation-id get-orders \
    --display-name "Get Orders" \
    --method GET \
    --url-template "/orders" \
    --output none

# POST /orders - Create a new order
az apim api operation create \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --api-id orders-api \
    --operation-id create-order \
    --display-name "Create Order" \
    --method POST \
    --url-template "/orders" \
    --output none

# GET /health - Health check
az apim api operation create \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --api-id orders-api \
    --operation-id health-check \
    --display-name "Health Check" \
    --method GET \
    --url-template "/health" \
    --output none

echo "      ✓ Operations created (GET/POST /orders, GET /health)"

echo ""
echo "[5/5] Getting subscription key..."
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_KEY=$(az rest \
    --method POST \
    --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_NAME/subscriptions/master/listSecrets?api-version=2022-08-01" \
    --query primaryKey -o tsv)

echo ""
echo "========================================="
echo "  QuickStart Complete!"
echo "========================================="
echo ""
echo "Function URL:  https://$FUNC_NAME.azurewebsites.net/api/orders"
echo "APIM Base:     https://$APIM_NAME.azure-api.net/orders"
echo ""
echo "Subscription Key: $SUBSCRIPTION_KEY"
echo ""
echo "Test directly:"
echo "  curl https://$FUNC_NAME.azurewebsites.net/api/orders"
echo ""
echo "Test through APIM:"
echo "  curl -H 'Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY' \\"
echo "    https://$APIM_NAME.azure-api.net/orders/orders"
echo ""
echo "  curl -H 'Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY' \\"
echo "    https://$APIM_NAME.azure-api.net/orders/health"
echo ""
echo "Run validation:"
echo "  ./validate/check-all.sh"

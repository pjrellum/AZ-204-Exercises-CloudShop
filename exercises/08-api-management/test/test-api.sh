#!/bin/bash
# =============================================================================
# Test the Orders API
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

# Check if testing through APIM or directly
USE_APIM="${1:-direct}"

if [ "$USE_APIM" = "apim" ]; then
    BASE_URL="https://$APIM_NAME.azure-api.net/orders"

    # Get subscription key
    SUBSCRIPTION_KEY=$(az apim subscription show \
        --resource-group "$RESOURCE_GROUP" \
        --service-name "$APIM_NAME" \
        --subscription-id master \
        --query primaryKey -o tsv 2>/dev/null)

    if [ -z "$SUBSCRIPTION_KEY" ]; then
        echo "Error: Could not get APIM subscription key"
        exit 1
    fi

    AUTH_HEADER="-H \"Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY\""
    echo "=== Testing through API Management ==="
else
    BASE_URL="https://$FUNCTION_APP.azurewebsites.net/api/orders"
    AUTH_HEADER=""
    echo "=== Testing Function directly ==="
fi

echo "Base URL: $BASE_URL"
echo ""

# Test 1: Health check
echo "--- Test 1: Health Check ---"
HEALTH_URL="${BASE_URL/orders/health}"
echo "GET $HEALTH_URL"
eval "curl -s $AUTH_HEADER '$HEALTH_URL'" | jq . 2>/dev/null || cat
echo ""
echo ""

# Test 2: Get orders (should be empty)
echo "--- Test 2: GET /orders (list) ---"
echo "GET $BASE_URL"
eval "curl -s $AUTH_HEADER '$BASE_URL'" | jq . 2>/dev/null || cat
echo ""
echo ""

# Test 3: Create an order
echo "--- Test 3: POST /orders (create) ---"
ORDER_DATA='{"customer":"Alice","items":[{"sku":"WIDGET-001","quantity":2,"price":29.99}],"total":59.98}'
echo "POST $BASE_URL"
echo "Body: $ORDER_DATA"
eval "curl -s -X POST $AUTH_HEADER -H 'Content-Type: application/json' -d '$ORDER_DATA' '$BASE_URL'" | jq . 2>/dev/null || cat
echo ""
echo ""

# Test 4: Get orders again (should have 1)
echo "--- Test 4: GET /orders (verify) ---"
echo "GET $BASE_URL"
eval "curl -s $AUTH_HEADER '$BASE_URL'" | jq . 2>/dev/null || cat
echo ""

# If using APIM, also test without key
if [ "$USE_APIM" = "apim" ]; then
    echo ""
    echo "--- Test 5: GET without subscription key (should fail) ---"
    echo "GET $BASE_URL (no key)"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL")
    echo "Response: HTTP $HTTP_CODE"
    if [ "$HTTP_CODE" = "401" ]; then
        echo "✓ Correctly returned 401 Unauthorized"
    else
        echo "✗ Expected 401, got $HTTP_CODE"
    fi
fi

echo ""
echo "=== Tests complete ==="

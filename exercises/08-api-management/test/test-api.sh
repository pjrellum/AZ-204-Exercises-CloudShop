#!/bin/bash
# =============================================================================
# Test the Orders API
# =============================================================================
# Usage: ./test-api.sh         # Test Function directly
#        ./test-api.sh apim    # Test through API Management
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="${ENV_FILE:-env.sh}"

# Load environment
source "$EXERCISE_DIR/$ENV_FILE" 2>/dev/null || {
    echo "Error: $ENV_FILE not found. Copy env.example.sh to $ENV_FILE and configure it."
    exit 1
}

# Check if testing through APIM or directly
USE_APIM="${1:-direct}"

if [ "$USE_APIM" = "apim" ]; then
    BASE_URL="https://$APIM_NAME.azure-api.net/orders/orders"
    HEALTH_URL="https://$APIM_NAME.azure-api.net/orders/health"

    # Get subscription key
    echo "Getting APIM subscription key..."
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    SUBSCRIPTION_KEY=$(az rest \
        --method POST \
        --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_NAME/subscriptions/master/listSecrets?api-version=2022-08-01" \
        --query primaryKey -o tsv 2>/dev/null)

    if [ -z "$SUBSCRIPTION_KEY" ]; then
        echo "Error: Could not get APIM subscription key"
        exit 1
    fi

    AUTH_HEADER="-H 'Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY'"
    echo ""
    echo "=== Testing through API Management ==="
else
    BASE_URL="https://$FUNC_NAME.azurewebsites.net/api/orders"
    HEALTH_URL="https://$FUNC_NAME.azurewebsites.net/api/health"
    AUTH_HEADER=""
    echo "=== Testing Function directly ==="
fi

echo "Base URL: $BASE_URL"
echo ""

PASSED=0
FAILED=0

# Test 1: Health check
echo "--- Test 1: Health Check ---"
echo "GET $HEALTH_URL"
RESPONSE=$(eval "curl -s -w '\n%{http_code}' $AUTH_HEADER '$HEALTH_URL'")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Health check passed (HTTP $HTTP_CODE)"
    PASSED=$((PASSED + 1))
else
    echo "✗ Health check failed (HTTP $HTTP_CODE)"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 2: Get orders (should be empty or have existing orders)
echo "--- Test 2: GET /orders (list) ---"
echo "GET $BASE_URL"
RESPONSE=$(eval "curl -s -w '\n%{http_code}' $AUTH_HEADER '$BASE_URL'")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ List orders passed (HTTP $HTTP_CODE)"
    PASSED=$((PASSED + 1))
else
    echo "✗ List orders failed (HTTP $HTTP_CODE)"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 3: Create an order
echo "--- Test 3: POST /orders (create) ---"
ORDER_DATA='{"customer":"Alice","items":[{"sku":"WIDGET-001","quantity":2,"price":29.99}],"total":59.98}'
echo "POST $BASE_URL"
echo "Body: $ORDER_DATA"
RESPONSE=$(eval "curl -s -w '\n%{http_code}' -X POST $AUTH_HEADER -H 'Content-Type: application/json' -d '$ORDER_DATA' '$BASE_URL'")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ]; then
    echo "✓ Create order passed (HTTP $HTTP_CODE)"
    PASSED=$((PASSED + 1))
else
    echo "✗ Create order failed (HTTP $HTTP_CODE)"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 4: Get orders again (should have the new order)
echo "--- Test 4: GET /orders (verify) ---"
echo "GET $BASE_URL"
RESPONSE=$(eval "curl -s -w '\n%{http_code}' $AUTH_HEADER '$BASE_URL'")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Verify orders passed (HTTP $HTTP_CODE)"
    PASSED=$((PASSED + 1))
else
    echo "✗ Verify orders failed (HTTP $HTTP_CODE)"
    FAILED=$((FAILED + 1))
fi
echo ""

# If using APIM, also test without key
if [ "$USE_APIM" = "apim" ]; then
    echo "--- Test 5: GET without subscription key (should fail) ---"
    echo "GET $BASE_URL (no key)"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL")
    echo "Response: HTTP $HTTP_CODE"
    if [ "$HTTP_CODE" = "401" ]; then
        echo "✓ Correctly returned 401 Unauthorized"
        PASSED=$((PASSED + 1))
    else
        echo "✗ Expected 401, got $HTTP_CODE"
        FAILED=$((FAILED + 1))
    fi
    echo ""
fi

echo "=== Tests complete ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi

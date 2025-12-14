#!/bin/bash
# Generate test traffic to populate Application Insights

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Generating Test Traffic ==="
echo ""

# Determine what services are available
HAS_FUNC=false
HAS_APIM=false

if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    HAS_FUNC=true
    FUNC_URL="https://${FUNC_NAME}.azurewebsites.net"
fi

if az apim show --name "$APIM_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    HAS_APIM=true
    APIM_URL="https://${APIM_NAME}.azure-api.net"
fi

REQUEST_COUNT="${1:-20}"

echo "Sending $REQUEST_COUNT requests..."
echo ""

# Send requests to Function App
if [ "$HAS_FUNC" = true ]; then
    echo "=== Function App Requests ==="
    for i in $(seq 1 $((REQUEST_COUNT / 2))); do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${FUNC_URL}/api/orders" 2>/dev/null || echo "000")
        echo "  Request $i: HTTP $HTTP_CODE"
        sleep 0.5
    done
    echo ""
fi

# Send requests to APIM
if [ "$HAS_APIM" = true ]; then
    echo "=== API Management Requests ==="
    # Try without subscription key first (might be allowed)
    for i in $(seq 1 $((REQUEST_COUNT / 2))); do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${APIM_URL}/orders" 2>/dev/null || echo "000")
        echo "  Request $i: HTTP $HTTP_CODE"
        sleep 0.5
    done
    echo ""
fi

# Generate some errors for visibility
echo "=== Generating Error Requests ==="
for i in {1..5}; do
    if [ "$HAS_FUNC" = true ]; then
        curl -s -o /dev/null "${FUNC_URL}/api/nonexistent" 2>/dev/null || true
    fi
    sleep 0.5
done
echo "  Sent 5 requests to nonexistent endpoints"

echo ""
echo "=== Traffic Generation Complete ==="
echo ""
echo "Wait 2-5 minutes for data to appear in Application Insights."
echo ""
echo "View in Azure Portal:"
echo "  1. Go to Application Insights: $APPINSIGHTS_NAME"
echo "  2. Click 'Live Metrics' for real-time data"
echo "  3. Click 'Transaction Search' to find requests"
echo "  4. Click 'Failures' to see error requests"

#!/bin/bash
# Validate Application Insights exercise

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Application Insights Exercise ==="
echo ""

PASS=0
FAIL=0

check() {
    local name="$1"
    local result="$2"
    if [ "$result" == "true" ] || [ -n "$result" ]; then
        echo "[PASS] $name"
        ((PASS++))
    else
        echo "[FAIL] $name"
        ((FAIL++))
    fi
}

# Check Application Insights
echo "Checking Application Insights..."
AI_EXISTS=$(az monitor app-insights component show --app "$APPINSIGHTS_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null || echo "")
check "Application Insights exists" "$AI_EXISTS"

# Check connection string
if [ -n "$AI_EXISTS" ]; then
    AI_CONN=$(az monitor app-insights component show --app "$APPINSIGHTS_NAME" --resource-group "$RESOURCE_GROUP" --query "connectionString" -o tsv 2>/dev/null || echo "")
    check "Connection string available" "$AI_CONN"
fi

# Check if Function App is connected
if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    FUNC_AI=$(az functionapp config appsettings list --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING'].value" -o tsv 2>/dev/null || echo "")
    check "Function App connected to App Insights" "$FUNC_AI"
else
    echo "[SKIP] Function App not found"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

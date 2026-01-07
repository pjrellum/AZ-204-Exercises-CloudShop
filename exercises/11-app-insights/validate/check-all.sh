#!/bin/bash
# Validate Application Insights exercise

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../env.sh" 2>/dev/null || {
    echo "Error: env.sh not found."
    exit 1
}

echo "=== Validating Application Insights Exercise ==="
echo ""

PASS=0
FAIL=0
SKIP=0

check() {
    local name="$1"
    local result="$2"
    if [ "$result" == "true" ] || [ -n "$result" ]; then
        echo "[PASS] $name"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $name"
        FAIL=$((FAIL + 1))
    fi
}

skip() {
    local name="$1"
    local reason="$2"
    echo "[SKIP] $name ($reason)"
    SKIP=$((SKIP + 1))
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
echo ""
echo "Checking Function App connection..."
if az functionapp show --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    FUNC_AI=$(az functionapp config appsettings list --name "$FUNC_NAME" --resource-group "$RESOURCE_GROUP" --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING'].value" -o tsv 2>/dev/null || echo "")
    check "Function App connected to App Insights" "$FUNC_AI"
else
    skip "Function App connection" "Function App not found"
fi

# Check if APIM is connected
echo ""
echo "Checking API Management connection..."
if az apim show --name "$APIM_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null 2>&1; then
    # Use REST API since 'az apim logger' command doesn't exist
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    LOGGER_RESULT=$(az rest --method GET \
        --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_NAME}/loggers/appinsights-logger?api-version=2022-08-01" \
        2>/dev/null || echo "")

    if [ -n "$LOGGER_RESULT" ]; then
        APIM_LOGGER=$(echo "$LOGGER_RESULT" | grep -o '"name": *"[^"]*"' | head -1 | cut -d'"' -f4)
        check "APIM logger exists" "$APIM_LOGGER"

        # Check logger type is Application Insights
        LOGGER_TYPE=$(echo "$LOGGER_RESULT" | grep -o '"loggerType": *"[^"]*"' | cut -d'"' -f4)
        if [ "$LOGGER_TYPE" == "applicationInsights" ]; then
            check "APIM logger type is Application Insights" "true"
        else
            check "APIM logger type is Application Insights" ""
        fi

        # Check if diagnostics are enabled (logger linked to APIs)
        DIAG_RESULT=$(az rest --method GET \
            --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_NAME}/diagnostics/applicationinsights?api-version=2022-08-01" \
            2>/dev/null || echo "")
        if [ -n "$DIAG_RESULT" ]; then
            check "APIM diagnostics enabled" "true"
        else
            check "APIM diagnostics enabled" ""
        fi
    else
        check "APIM logger exists" ""
    fi
else
    skip "APIM connection" "APIM not found - complete Exercise 08 first"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Skipped: $SKIP"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

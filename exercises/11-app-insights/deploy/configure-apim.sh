#!/bin/bash
# Configure API Management to send telemetry to Application Insights

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$SCRIPT_DIR/.."

source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Configuring APIM for Application Insights ==="
echo ""

# Get Application Insights resource ID and instrumentation key
AI_RESOURCE_ID=$(az monitor app-insights component show \
    --app "$APPINSIGHTS_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query id -o tsv 2>/dev/null)

AI_KEY=$(az monitor app-insights component show \
    --app "$APPINSIGHTS_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query instrumentationKey -o tsv 2>/dev/null)

if [ -z "$AI_KEY" ]; then
    echo "Error: Application Insights not found. Run the infrastructure deploy first."
    exit 1
fi

echo "Application Insights: $APPINSIGHTS_NAME"
echo "API Management: $APIM_NAME"
echo ""

# Check if APIM exists
if ! az apim show --name "$APIM_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "API Management $APIM_NAME not found."
    echo "Complete Exercise 08 first, or skip this step."
    exit 0
fi

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create APIM logger using REST API
echo "Creating APIM logger..."
az rest --method PUT \
    --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_NAME}/loggers/appinsights-logger?api-version=2022-08-01" \
    --body "{
        \"properties\": {
            \"loggerType\": \"applicationInsights\",
            \"description\": \"Application Insights logger for CloudShop\",
            \"credentials\": {
                \"instrumentationKey\": \"${AI_KEY}\"
            },
            \"resourceId\": \"${AI_RESOURCE_ID}\"
        }
    }" \
    --output none

echo "Logger created."

# Enable diagnostics on the orders API
echo "Enabling diagnostics on orders API..."
az rest --method PUT \
    --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_NAME}/apis/orders-api/diagnostics/applicationinsights?api-version=2022-08-01" \
    --body "{
        \"properties\": {
            \"loggerId\": \"/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_NAME}/loggers/appinsights-logger\",
            \"alwaysLog\": \"allErrors\",
            \"sampling\": {
                \"samplingType\": \"fixed\",
                \"percentage\": 100
            }
        }
    }" \
    --output none 2>/dev/null || echo "  (orders-api not found or already configured)"

echo ""
echo "=== APIM Configured ==="
echo "Logger: appinsights-logger"
echo "Diagnostics: Enabled on orders API"
echo ""
echo "Telemetry will now flow to Application Insights: $APPINSIGHTS_NAME"
echo ""
echo "To verify in Azure Portal:"
echo "  APIM -> APIs -> [select API] -> Settings -> Diagnostic logs"

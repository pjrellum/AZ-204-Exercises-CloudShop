#!/bin/bash
# Configure API Management to send telemetry to Application Insights

set -e

source ../env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Configuring APIM for Application Insights ==="
echo ""

# Get Application Insights instrumentation key
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

# Create APIM logger
echo "Creating APIM logger..."
az apim logger create \
    --resource-group "$RESOURCE_GROUP" \
    --service-name "$APIM_NAME" \
    --logger-id appinsights-logger \
    --logger-type applicationInsights \
    --instrumentation-key "$AI_KEY" \
    --output none 2>/dev/null || echo "Logger already exists or creation failed"

echo ""
echo "=== APIM Logger Created ==="
echo ""
echo "To enable diagnostics on your API:"
echo "  1. Go to Azure Portal -> APIM -> APIs -> Your API"
echo "  2. Click Settings -> Diagnostics"
echo "  3. Enable Application Insights"
echo "  4. Select appinsights-logger"

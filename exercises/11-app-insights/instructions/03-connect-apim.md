# Task 3: Connect API Management

Configure APIM to send telemetry to Application Insights.

## Prerequisites

- API Management exists from Exercise 08
- Application Insights created (Task 1)

## Steps

### 1. Create APIM Logger

```bash
az apim logger create \
    --resource-group $RESOURCE_GROUP \
    --service-name $APIM_NAME \
    --logger-id appinsights-logger \
    --logger-type applicationInsights \
    --instrumentation-key $AI_KEY
```

<details>
<summary>Why instrumentation key instead of connection string?</summary>

APIM logger currently requires the instrumentation key. The connection string format isn't supported yet for APIM loggers.

</details>

### 2. Enable Diagnostics on API

```bash
# First, get the API ID
API_ID=$(az apim api list \
    --resource-group $RESOURCE_GROUP \
    --service-name $APIM_NAME \
    --query "[0].name" -o tsv)

echo "API ID: $API_ID"
```

Then enable diagnostics in the portal:
1. Go to APIM → APIs → Your API
2. Settings → Diagnostics
3. Enable Application Insights
4. Select the logger

<details>
<summary>CLI method (alternative)</summary>

```bash
az apim api update \
    --resource-group $RESOURCE_GROUP \
    --service-name $APIM_NAME \
    --api-id $API_ID \
    --set properties.diagnostics.applicationInsights.enabled=true
```

</details>

### 3. What APIM Logs

With Application Insights enabled, APIM logs:
- Request/response headers (configurable)
- Request/response body (configurable, watch for PII)
- Backend duration
- Client IP
- Subscription ID
- Error details

## Correlation

APIM automatically propagates trace context to backends, enabling:
- End-to-end transaction tracing
- APIM → Function → Storage chain visibility
- Dependency mapping

## Verify Logger

```bash
az apim logger show \
    --resource-group $RESOURCE_GROUP \
    --service-name $APIM_NAME \
    --logger-id appinsights-logger
```

## Next Step

Continue to [04-generate-traffic.md](04-generate-traffic.md)

# Task 2: Connect Azure Functions

Configure your Function App to send telemetry to Application Insights.

## Prerequisites

- Function App exists from Exercise 08 or 09a
- Application Insights created (Task 1)

## Steps

### 1. Set Application Insights Connection String

```bash
az functionapp config appsettings set \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CONNECTION"
```

<details>
<summary>What telemetry is collected?</summary>

With this setting, Functions automatically collects:
- **Requests** - HTTP trigger invocations
- **Dependencies** - Calls to storage, databases, HTTP
- **Exceptions** - Unhandled errors
- **Traces** - Log statements (ILogger, logging)
- **Performance** - Duration, memory, CPU

</details>

### 2. Verify Setting

```bash
az functionapp config appsettings list \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING'].value" -o tsv
```

### 3. Trigger Some Activity

Call your function to generate telemetry:

```bash
# For HTTP trigger functions
curl "https://${FUNC_NAME}.azurewebsites.net/api/orders"
```

## Wait for Telemetry

Telemetry can take **2-5 minutes** to appear in the portal. This is normal.

## Verify in Portal

1. Go to Azure Portal → Application Insights → `ai-cloudshop-xxx`
2. Click **Live Metrics**
3. You should see:
   - Server requests
   - Request duration
   - Dependency calls

## Troubleshooting

<details>
<summary>No telemetry appearing</summary>

1. Wait 5 minutes (ingestion delay)
2. Verify connection string is correct
3. Check Function App is running: `az functionapp show --name $FUNC_NAME --resource-group $RESOURCE_GROUP --query state`
4. Restart Function App: `az functionapp restart --name $FUNC_NAME --resource-group $RESOURCE_GROUP`

</details>

## Next Step

Continue to [03-connect-apim.md](03-connect-apim.md)

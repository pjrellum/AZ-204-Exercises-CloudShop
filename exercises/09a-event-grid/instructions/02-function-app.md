# Task 2: Create Function App

Create an Azure Function App to serve as the Event Grid webhook endpoint.

## What You'll Create

- Function App: `func-cloudshop-processor-{suffix}`
- Runtime: Python 3.11 (or your preferred language)
- Plan: Consumption (serverless)

## Steps

### 1. Create Function App

```bash
az functionapp create \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_NAME \
    --consumption-plan-location $LOCATION \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --os-type Linux \
    --disable-app-insights true
```

<details>
<summary>Why Consumption plan?</summary>

Consumption plan is serverless - you only pay when your function runs. Perfect for event-driven workloads where traffic is unpredictable.

</details>

<details>
<summary>Using a different language?</summary>

For .NET:
```bash
--runtime dotnet-isolated --runtime-version 8.0
```

For Node.js:
```bash
--runtime node --runtime-version 20
```

</details>

### 2. Get Function App URL

```bash
FUNC_URL=$(az functionapp show \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "defaultHostName" -o tsv)

echo "Function URL: https://${FUNC_URL}"
```

## Validation

```bash
# Check function app exists and is running
az functionapp show \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "{name:name, state:state, url:defaultHostName}"
```

Expected output:
```json
{
  "name": "func-cloudshop-processor-xxx",
  "state": "Running",
  "url": "func-cloudshop-processor-xxx.azurewebsites.net"
}
```

## Next Step

Continue to [03-deploy-code.md](03-deploy-code.md)

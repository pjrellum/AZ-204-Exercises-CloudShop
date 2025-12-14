# Task 1: Create Application Insights

Create an Application Insights resource for monitoring.

## What You'll Create

- Application Insights: `ai-cloudshop-{suffix}`
- Type: Web application

## Steps

### 1. Create Application Insights

```bash
az monitor app-insights component create \
    --app $APPINSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --application-type web
```

### 2. Get Connection String

```bash
AI_CONNECTION=$(az monitor app-insights component show \
    --app $APPINSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query connectionString -o tsv)

echo "Connection String: $AI_CONNECTION"
```

### 3. Get Instrumentation Key

```bash
AI_KEY=$(az monitor app-insights component show \
    --app $APPINSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey -o tsv)

echo "Instrumentation Key: $AI_KEY"
```

> **Save both** - Connection string is preferred for new SDKs, but some services still need the instrumentation key.

## Connection String vs Instrumentation Key

| Property | When to Use |
|----------|-------------|
| Connection String | Modern SDKs, Function Apps, new integrations |
| Instrumentation Key | Older SDKs, APIM logger, some Azure services |

## Validation

```bash
az monitor app-insights component show \
    --app $APPINSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "{name:name, type:applicationType, connectionString:connectionString}"
```

## Next Step

Continue to [02-connect-functions.md](02-connect-functions.md)

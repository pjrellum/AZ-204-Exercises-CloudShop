# Task 5: Import and Configure API

## Objective

Import your Function App as an API in API Management and configure authentication.

## Requirements

| Setting | Value |
|---------|-------|
| API ID | `orders-api` |
| Display Name | Orders API |
| Path | `orders` |
| Subscription Required | Yes |

## What You Need to Do

1. Import the Function App as an API in APIM
2. Configure the API to require subscription keys
3. Note down your subscription key for testing

## Validation

```bash
# List APIs in your APIM instance
az apim api list --resource-group $RESOURCE_GROUP --service-name $APIM_NAME --query "[].{name:name, path:path}"
```

Expected output:
```json
[
  {
    "name": "orders-api",
    "path": "orders"
  }
]
```

---

## Hints

<details>
<summary>Hint: How do I import an API?</summary>

There are two approaches:

1. **Import from Function App** - APIM can discover and import functions automatically
2. **Create blank API** - Manually define operations and point to the backend

For Functions, the import approach is easier. Use `az apim api import` with the function app URL.

</details>

<details>
<summary>Hint: What about the subscription key?</summary>

APIM has a built-in subscription called "master" that you can use for testing. To get the key:

```bash
az apim subscription show \
  --resource-group $RESOURCE_GROUP \
  --service-name $APIM_NAME \
  --subscription-id master \
  --query primaryKey -o tsv
```

</details>

<details>
<summary>Hint: What's the API endpoint after import?</summary>

Your API will be accessible at:
```
https://{apim-name}.azure-api.net/{api-path}
```

For example:
```
https://apim-cloudshop-abc123.azure-api.net/orders
```

</details>

<details>
<summary>Hint: Bicep approach</summary>

You'll need these resources:
1. `Microsoft.ApiManagement/service/apis` - The API definition
2. `Microsoft.ApiManagement/service/apis/operations` - Each operation (GET, POST)
3. `Microsoft.ApiManagement/service/backends` - Link to your Function App

</details>

<details>
<summary>Show CLI solution</summary>

```bash
# Get the Function URL
FUNCTION_URL="https://$FUNCTION_APP.azurewebsites.net/api"

# Import/create the API
az apim api import \
  --resource-group $RESOURCE_GROUP \
  --service-name $APIM_NAME \
  --api-id orders-api \
  --path orders \
  --display-name "Orders API" \
  --service-url $FUNCTION_URL \
  --protocols https \
  --subscription-required true

# Get subscription key for testing
SUBSCRIPTION_KEY=$(az apim subscription show \
  --resource-group $RESOURCE_GROUP \
  --service-name $APIM_NAME \
  --subscription-id master \
  --query primaryKey -o tsv)

echo "Your subscription key: $SUBSCRIPTION_KEY"
```

</details>

---

## [Challenge] Add Rate Limiting

Add a rate-limit policy to restrict API calls.

**Goal:** Limit to 10 calls per minute per subscription key.

<details>
<summary>Hint: Rate limiting policies</summary>

APIM uses XML policies. The `rate-limit-by-key` policy is what you need.

```xml
<policies>
  <inbound>
    <rate-limit-by-key calls="10" renewal-period="60"
      counter-key="@(context.Subscription.Id)" />
  </inbound>
</policies>
```

Apply using `az apim api policy` or the Azure Portal.

</details>

<details>
<summary>Show rate limiting solution</summary>

Create a file `policy.xml`:
```xml
<policies>
  <inbound>
    <base />
    <rate-limit-by-key calls="10" renewal-period="60"
      counter-key="@(context.Subscription.Id)"
      increment-condition="@(context.Response.StatusCode == 200)" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
```

Apply it:
```bash
az apim api policy set \
  --resource-group $RESOURCE_GROUP \
  --service-name $APIM_NAME \
  --api-id orders-api \
  --policy-file policy.xml
```

</details>

---

**Previous:** [04-create-apim.md](04-create-apim.md) | **Next:** [06-test-api.md](06-test-api.md)

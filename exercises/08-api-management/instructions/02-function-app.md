# Task 2: Create Function App

## Objective

Create an Azure Function App that will serve as the Orders API backend.

## Requirements

| Setting | Value |
|---------|-------|
| Name | `func-cloudshop-orders-{your-suffix}` |
| Runtime | .NET 8 |
| Hosting | Consumption plan |
| Storage | The storage account from Task 1 |

## What You Need to Do

1. Create a Function App with your chosen runtime
2. Ensure it uses the Consumption plan (serverless)
3. Connect it to your storage account

## Runtime Reference

| Language | Runtime Value | Version |
|----------|---------------|---------|
| .NET | `dotnet-isolated` | 8 |

## Validation

```bash
# Should return the Function App details
az functionapp show --name $FUNCTION_APP --resource-group $RESOURCE_GROUP --query "state"
# Expected: "Running"
```

---

## Hints

<details>
<summary>Hint: What command creates a Function App?</summary>

Use `az functionapp create`. This single command creates both the hosting plan (if using consumption) and the Function App.

</details>

<details>
<summary>Hint: Key parameters for az functionapp create</summary>

Essential parameters:
- `--name` - Your function app name
- `--resource-group` - Your resource group
- `--consumption-plan-location` - Region (use this for Consumption tier)
- `--runtime` - The runtime stack
- `--runtime-version` - Version number
- `--functions-version` - Azure Functions runtime version (use 4)
- `--storage-account` - Your storage account name
- `--disable-app-insights true` - Skip automatic App Insights creation

</details>

<details>
<summary>Hint: Bicep approach</summary>

You'll need two resources:
1. `Microsoft.Web/serverfarms` - The hosting plan
   - `sku.name`: `Y1` (Consumption)
   - `kind`: `functionapp`
2. `Microsoft.Web/sites` - The Function App
   - `kind`: `functionapp`
   - Reference the server farm and storage account

</details>

<details>
<summary>Show CLI solution (.NET)</summary>

```bash
az functionapp create \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $LOCATION \
  --runtime dotnet-isolated \
  --runtime-version 8 \
  --functions-version 4 \
  --storage-account $STORAGE_ACCOUNT \
  --disable-app-insights true
```

</details>

---

**Previous:** [01-storage-account.md](01-storage-account.md) | **Next:** [03-deploy-code.md](03-deploy-code.md)

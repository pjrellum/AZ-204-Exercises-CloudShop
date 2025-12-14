# Task 1: Create Resource Group and Storage Account

## Objective

Create an Azure Resource Group and Storage Account that will be used by the Function App.

## Requirements

| Resource | Setting | Value |
|----------|---------|-------|
| Resource Group | Name | `rg-cloudshop-{your-suffix}` |
| Storage Account | Name | `stcloudshop{your-suffix}` (no hyphens, lowercase) |
| Storage Account | SKU | Standard_LRS |

## What You Need to Do

1. Create a resource group for this exercise
2. Create a storage account in your resource group
3. Verify both were created successfully

## Validation

```bash
# Should return the storage account details
az storage account show --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP
```

---

## Hints

<details>
<summary>Hint: How do I create a resource group?</summary>

Use `az group create` with `--name` and `--location` parameters.

</details>

<details>
<summary>Hint: What Azure CLI command creates storage accounts?</summary>

Look into `az storage account create`. Run `az storage account create --help` to see available parameters.

</details>

<details>
<summary>Hint: What parameters do I need?</summary>

You'll need to specify:
- `--name` - Your storage account name
- `--resource-group` - Your resource group
- `--location` - Azure region
- `--sku` - The redundancy option (Standard_LRS for this exercise)

</details>

<details>
<summary>Hint: Bicep approach</summary>

Create a `storageAccount` resource of type `Microsoft.Storage/storageAccounts@2023-01-01`.

Key properties:
- `kind`: `StorageV2`
- `sku.name`: `Standard_LRS`

</details>

<details>
<summary>Show CLI solution</summary>

```bash
# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS
```

</details>

---

**Next:** [02-function-app.md](02-function-app.md)

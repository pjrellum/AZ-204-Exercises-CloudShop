# Task 4: Create API Management Instance

## Objective

Create an Azure API Management instance that will serve as the gateway for the Orders API.

## Requirements

| Setting | Value |
|---------|-------|
| Name | `apim-cloudshop-{your-suffix}` |
| SKU | Consumption |
| Publisher Name | CloudShop |
| Publisher Email | Your email or `admin@cloudshop.example.com` |

## What You Need to Do

1. Create an API Management instance
2. Use the Consumption tier for fast provisioning (~2 minutes)
3. Wait for provisioning to complete

> ⏱️ **Note:** Consumption tier creates in ~2 minutes. Developer/Basic/Standard tiers take 30-45 minutes.

## Validation

```bash
# Should return the APIM details
az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP --query "provisioningState"
# Expected: "Succeeded"
```

---

## Hints

<details>
<summary>Hint: What command creates APIM?</summary>

Use `az apim create`. Run `az apim create --help` to see available parameters.

</details>

<details>
<summary>Hint: Key parameters</summary>

Required parameters:
- `--name` - Globally unique name for your APIM instance
- `--resource-group` - Your resource group
- `--publisher-name` - Organization name (shows in developer portal)
- `--publisher-email` - Contact email
- `--sku-name` - Pricing tier (use `Consumption`)
- `--location` - Azure region

</details>

<details>
<summary>Hint: Why Consumption tier?</summary>

For this workshop, Consumption tier is ideal because:
- Creates in ~2 minutes (vs 30-45 min for other tiers)
- Pay-per-call pricing (low cost for testing)
- No idle costs when not in use

Limitations: No developer portal, no built-in cache, no VNet integration.

</details>

<details>
<summary>Hint: Bicep approach</summary>

Create a resource of type `Microsoft.ApiManagement/service@2023-03-01-preview`.

Key properties:
- `sku.name`: `Consumption`
- `sku.capacity`: `0` (required for Consumption)
- `properties.publisherName`
- `properties.publisherEmail`

</details>

<details>
<summary>Show CLI solution</summary>

```bash
az apim create \
  --name $APIM_NAME \
  --resource-group $RESOURCE_GROUP \
  --publisher-name "CloudShop" \
  --publisher-email "admin@cloudshop.example.com" \
  --sku-name Consumption \
  --location $LOCATION
```

</details>

---

**Previous:** [03-deploy-code.md](03-deploy-code.md) | **Next:** [05-configure-api.md](05-configure-api.md)

# Task 1: Create Storage Account

Create a storage account with containers for orders and dead-letter events.

## What You'll Create

- Storage Account: `stcloudshop{suffix}`
- Container: `orders/` - for uploaded order files
- Container: `deadletter/` - for failed event deliveries

## Steps

### 1. Create Storage Account

```bash
az storage account create \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS
```

<details>
<summary>What does this do?</summary>

Creates a general-purpose v2 storage account with locally redundant storage (LRS). This is the most cost-effective option for development.

</details>

### 2. Create Orders Container

```bash
az storage container create \
    --name orders \
    --account-name $STORAGE_NAME
```

<details>
<summary>Why "orders"?</summary>

Event Grid will watch this container for new blob uploads. When a `.json` file is uploaded here, it triggers the processing pipeline.

</details>

### 3. Create Dead-Letter Container

```bash
az storage container create \
    --name deadletter \
    --account-name $STORAGE_NAME
```

<details>
<summary>What's a dead-letter container?</summary>

When Event Grid can't deliver an event (webhook down, too many retries), the event goes to the dead-letter container. This ensures no events are lost.

</details>

## Validation

```bash
# Verify storage account exists
az storage account show --name $STORAGE_NAME --resource-group $RESOURCE_GROUP --query name

# List containers
az storage container list --account-name $STORAGE_NAME --query "[].name" -o tsv
```

Expected output:
```
deadletter
orders
```

## Next Step

Continue to [02-function-app.md](02-function-app.md)

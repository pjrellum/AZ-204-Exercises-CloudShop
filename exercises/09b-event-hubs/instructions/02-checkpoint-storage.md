# Task 2: Create Checkpoint Storage

Create a storage account for consumer checkpoints.

## What You'll Create

- Storage Account: `stcloudshop{suffix}` (if not exists)
- Container: `checkpoints`

## Why Checkpoints?

When a consumer reads events, it needs to track its position in each partition. Checkpoints:
- Store the last processed event offset per partition
- Enable resuming from where you left off after restart
- Prevent reprocessing events

## Steps

### 1. Create Storage Account (if needed)

```bash
az storage account create \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS
```

### 2. Create Checkpoints Container

```bash
az storage container create \
    --name checkpoints \
    --account-name $STORAGE_NAME
```

### 3. Get Storage Connection String

```bash
STORAGE_CONNECTION=$(az storage account show-connection-string \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query connectionString -o tsv)

echo "Storage Connection: $STORAGE_CONNECTION"
```

> **Save this connection string** - you'll need it for the consumer.

## How Checkpoints Work

```
Consumer reads from Event Hub
         │
         ▼
┌─────────────────────┐
│ Process Event       │
│ (partition 0, #42)  │
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│ Update Checkpoint   │
│ partition-0: 42     │
└─────────────────────┘
         │
         ▼
  checkpoints/
  └── {consumer-group}/
      └── {partition-id}
          └── checkpoint.json
```

## Validation

```bash
# Check container exists
az storage container exists \
    --name checkpoints \
    --account-name $STORAGE_NAME \
    --query exists
```

## Next Step

Continue to [03-send-events.md](03-send-events.md)

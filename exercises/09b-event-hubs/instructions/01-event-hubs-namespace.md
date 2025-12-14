# Task 1: Create Event Hubs Namespace

Create an Event Hubs namespace and hub for streaming clickstream data.

## What You'll Create

- Event Hubs Namespace: `evhns-cloudshop-{suffix}`
- Event Hub: `clickstream`
- Partitions: 4 (for parallel processing)

## Steps

### 1. Create Event Hubs Namespace

```bash
az eventhubs namespace create \
    --name $EVENTHUB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard
```

<details>
<summary>Why Standard SKU?</summary>

Standard tier is required for:
- Capture (archiving to blob storage)
- More than 1 consumer group
- Higher throughput

Basic tier is cheaper but limited to 1 consumer group.

</details>

### 2. Create Event Hub

```bash
az eventhubs eventhub create \
    --name $EVENTHUB_NAME \
    --namespace-name $EVENTHUB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --partition-count 4 \
    --message-retention 1
```

<details>
<summary>Why 4 partitions?</summary>

- Each partition can have 1 active consumer per consumer group
- 4 partitions = up to 4 parallel consumers
- More partitions = higher throughput, but more complexity
- Cannot be changed after creation!

</details>

### 3. Get Connection String

```bash
EVENTHUB_CONNECTION=$(az eventhubs namespace authorization-rule keys list \
    --namespace-name $EVENTHUB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo "Connection String: $EVENTHUB_CONNECTION"
```

> **Save this connection string** - you'll need it for the producer and consumer.

## Validation

```bash
# Check namespace exists
az eventhubs namespace show \
    --name $EVENTHUB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "{name:name, sku:sku.name}"

# Check hub exists with 4 partitions
az eventhubs eventhub show \
    --name $EVENTHUB_NAME \
    --namespace-name $EVENTHUB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "{name:name, partitions:partitionCount, retention:messageRetentionInDays}"
```

## Next Step

Continue to [02-checkpoint-storage.md](02-checkpoint-storage.md)

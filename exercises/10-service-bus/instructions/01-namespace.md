# Task 1: Create Service Bus Namespace

Create a Service Bus namespace for reliable message queuing.

## What You'll Create

- Service Bus Namespace: `sb-cloudshop-{suffix}`
- SKU: Standard (required for topics)

## Service Bus vs Event Hubs

| Feature | Service Bus | Event Hubs |
|---------|-------------|------------|
| Pattern | Queue/Pub-Sub | Event streaming |
| Delivery | At-least-once guaranteed | At-least-once |
| Message size | Up to 256KB (Standard) | Up to 1MB |
| Ordering | FIFO with sessions | Per partition |
| Dead-letter | Built-in | Manual |

## Steps

### 1. Create Service Bus Namespace

```bash
az servicebus namespace create \
    --name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard
```

<details>
<summary>Why Standard SKU?</summary>

Standard tier is required for:
- Topics and subscriptions
- Duplicate detection
- Sessions (FIFO)
- Scheduled messages

Basic tier only supports queues with limited features.

</details>

### 2. Get Connection String

```bash
SERVICEBUS_CONNECTION=$(az servicebus namespace authorization-rule keys list \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

echo "Connection String: $SERVICEBUS_CONNECTION"
```

> **Save this connection string** - you'll need it for sender and receiver.

## Validation

```bash
az servicebus namespace show \
    --name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "{name:name, sku:sku.name, state:status}"
```

## Next Step

Continue to [02-queue.md](02-queue.md)

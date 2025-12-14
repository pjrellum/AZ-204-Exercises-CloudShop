# Task 2: Create Order Processing Queue

Create a queue for order messages with dead-letter configuration.

## What You'll Create

- Queue: `order-processing`
- Max delivery count: 3 (then dead-letter)
- TTL: 1 day

## Steps

### 1. Create Queue

```bash
az servicebus queue create \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --max-delivery-count 3 \
    --default-message-time-to-live P1D
```

<details>
<summary>What do these settings mean?</summary>

- `--max-delivery-count 3`: After 3 failed processing attempts, message goes to dead-letter queue
- `--default-message-time-to-live P1D`: Messages expire after 1 day if not processed (ISO 8601 duration)

</details>

### 2. View Queue Properties

```bash
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "{
        name:name,
        maxDeliveryCount:maxDeliveryCount,
        ttl:defaultMessageTimeToLive,
        deadLettering:deadLetteringOnMessageExpiration
    }"
```

## Queue Behavior

```
Message sent → Queue → Receiver picks up
                          │
                          ├─→ Complete() → Message removed ✓
                          │
                          ├─→ Abandon() → Back to queue (retry)
                          │     (delivery count +1)
                          │
                          └─→ After 3 failures → Dead-letter queue
```

## Dead-Letter Queue

Every queue automatically has a dead-letter sub-queue:
- Path: `order-processing/$deadletterqueue`
- Receives messages that:
  - Exceed max delivery count
  - Expire (TTL reached)
  - Are explicitly dead-lettered

## Validation

```bash
# Check queue exists
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query name

# Check dead-letter is enabled
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query deadLetteringOnMessageExpiration
```

## Next Step

Continue to [03-send-messages.md](03-send-messages.md)

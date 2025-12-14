# Task 5: Explore Dead-Letter Queue

Understand how failed messages end up in the dead-letter queue.

## What is Dead-Letter Queue?

The DLQ is a sub-queue that holds messages that couldn't be processed:
- Exceeded max delivery attempts
- Expired (TTL reached)
- Explicitly dead-lettered by receiver

## Check Dead-Letter Count

```bash
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "countDetails.deadLetterMessageCount"
```

## Simulate a Failure

### 1. Create a "Poison" Message

Send a message that will fail processing:

```bash
# Send invalid JSON that will cause processing error
az servicebus queue send \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --queue-name $QUEUE_NAME \
    --body "invalid json {{{" \
    --content-type "application/json"
```

### 2. Run Receiver

The receiver will fail to parse JSON and abandon the message.
After 3 attempts, it goes to dead-letter.

### 3. Check Dead-Letter Queue

```bash
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "countDetails.deadLetterMessageCount"
```

## Reading from Dead-Letter Queue

To process dead-lettered messages, receive from the DLQ path:

```python
# DLQ path format
dlq_path = f"{queue_name}/$deadletterqueue"

# Create receiver for DLQ
dlq_receiver = client.get_queue_receiver(
    queue_name=dlq_path
)

# Read and handle failed messages
async with dlq_receiver:
    messages = await dlq_receiver.receive_messages()
    for message in messages:
        print(f"Dead-letter reason: {message.dead_letter_reason}")
        print(f"Body: {str(message)}")
        # Fix and resubmit, or log and complete
        await dlq_receiver.complete_message(message)
```

## Dead-Letter Properties

Each dead-lettered message has:
- `dead_letter_reason`: Why it was dead-lettered
- `dead_letter_error_description`: Error details
- Original message properties preserved

## Validation Checklist

- [ ] Queue created with max-delivery-count 3
- [ ] Sender sends messages successfully
- [ ] Receiver processes and completes messages
- [ ] Failed messages go to dead-letter after 3 attempts
- [ ] Can read from dead-letter queue

## Run Validation Script

```bash
cd ../validate
./check-all.sh
```

## Complete!

You've successfully:
1. Created Service Bus namespace
2. Created queue with dead-letter configuration
3. Sent order messages
4. Processed messages with proper settlement
5. Explored dead-letter queue behavior

## Next Steps

- Complete the [Challenge](../challenge.md) for Topics with filtered subscriptions
- Continue to [Exercise 11: Application Insights](../../11-app-insights/README.md)

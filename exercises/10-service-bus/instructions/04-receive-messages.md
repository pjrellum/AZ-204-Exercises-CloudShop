# Task 4: Receive and Process Messages

Receive order messages and complete them after processing.

## Prerequisites

Set environment variable:
```bash
export SERVICEBUS_CONNECTION_STRING="<your-connection-string>"
export QUEUE_NAME="order-processing"
```

## Steps

### Run the Receiver

```bash
cd ../code/python/complete
python receiver.py
```

## Expected Output

```
Listening for orders on queue: order-processing
Press Ctrl+C to stop

==================================================
ORDER RECEIVED
==================================================
Order ID: ORD-A1B2C3D4
Customer: Customer-1
Total: $74.99
Items: 2
Message ID: ORD-A1B2C3D4
Delivery Count: 1
Status: COMPLETED
==================================================
```

## Message Settlement

After receiving a message, you must **settle** it:

| Action | Effect |
|--------|--------|
| `complete_message()` | Remove from queue (success) |
| `abandon_message()` | Return to queue for retry |
| `dead_letter_message()` | Move to DLQ immediately |
| `defer_message()` | Set aside for later |

<details>
<summary>View settlement code</summary>

```python
async with receiver:
    messages = await receiver.receive_messages(max_message_count=10)
    for message in messages:
        try:
            # Process the order
            order = json.loads(str(message))
            process_order(order)

            # Success - complete the message
            await receiver.complete_message(message)

        except Exception as e:
            # Failure - abandon for retry
            await receiver.abandon_message(message)
```

</details>

## Test Retry Behavior

1. Modify receiver to always abandon (simulating failure)
2. Send a message
3. Watch delivery count increase: 1 → 2 → 3
4. After 3rd attempt, message goes to dead-letter

## Verify Queue is Empty

```bash
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "countDetails.activeMessageCount"
```

Should show: `0` (all messages processed)

## Next Step

Continue to [05-dead-letter.md](05-dead-letter.md)

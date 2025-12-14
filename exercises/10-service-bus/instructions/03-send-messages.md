# Task 3: Send Order Messages

Send order messages to the Service Bus queue.

## Prerequisites

Set environment variable:
```bash
export SERVICEBUS_CONNECTION_STRING="<your-connection-string>"
export QUEUE_NAME="order-processing"
```

## Steps

### Run the Sender

```bash
cd ../code/python/complete
pip install -r requirements.txt
python sender.py --count 5
```

## Expected Output

```
Sent order: ORD-A1B2C3D4 ($74.99)
Sent order: ORD-E5F6G7H8 ($99.99)
Sent order: ORD-I9J0K1L2 ($124.99)
Sent order: ORD-M3N4O5P6 ($74.99)
Sent order: ORD-Q7R8S9T0 ($149.99)

Total orders sent: 5
```

## What the Sender Does

Each message contains an order:

```json
{
    "orderId": "ORD-A1B2C3D4",
    "customer": "Customer-1",
    "items": [
        {"sku": "WIDGET-001", "quantity": 2, "price": 25.00},
        {"sku": "GADGET-002", "quantity": 1, "price": 49.99}
    ],
    "total": 99.99,
    "timestamp": "2024-01-15T10:30:00Z"
}
```

## Message Properties

The sender sets important properties:

```python
message = ServiceBusMessage(
    body=json.dumps(order),
    content_type="application/json",
    subject="new-order",
    message_id=order["orderId"],  # For duplicate detection
    application_properties={
        "total": order["total"],
        "priority": "high" if order["total"] > 100 else "normal"
    }
)
```

<details>
<summary>Why application properties?</summary>

Application properties enable:
- Filtering in topic subscriptions
- Message routing decisions
- Custom metadata without parsing body

</details>

## Verify Messages in Queue

```bash
az servicebus queue show \
    --name $QUEUE_NAME \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "countDetails.activeMessageCount"
```

Should show: `5` (or however many you sent)

## Next Step

Continue to [04-receive-messages.md](04-receive-messages.md)

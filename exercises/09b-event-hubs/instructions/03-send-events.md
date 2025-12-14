# Task 3: Send Events (Producer)

Run the producer to send click events to Event Hubs.

## Prerequisites

Set environment variables:
```bash
export EVENTHUB_CONNECTION_STRING="<your-connection-string>"
export EVENTHUB_NAME="clickstream"
```

## Steps

### Option A: Use Python Producer

```bash
cd ../code/python/complete
pip install -r requirements.txt
python producer.py --count 100
```

### Option B: Use .NET Producer

```bash
cd ../code/dotnet/complete
dotnet run producer --connection "$EVENTHUB_CONNECTION_STRING" --count 100
```

## Expected Output

```
Created 10 events...
Created 20 events...
...
Sent batch of events
Total events sent: 100
```

## What the Producer Does

Each event simulates a website click:

```json
{
    "sessionId": "abc-123-def",
    "userId": "user-42",
    "page": "/products/widget-001",
    "action": "view",
    "timestamp": "2024-01-15T10:30:00Z",
    "metadata": {
        "browser": "Chrome",
        "device": "desktop"
    }
}
```

<details>
<summary>How batching works</summary>

The producer uses batching for efficiency:

```python
batch = await producer.create_batch()
for event in events:
    try:
        batch.add(event)
    except ValueError:
        # Batch full, send and create new
        await producer.send_batch(batch)
        batch = await producer.create_batch()
        batch.add(event)
```

Batching reduces network calls and improves throughput.

</details>

## Troubleshooting

<details>
<summary>Connection refused</summary>

1. Check connection string is correct
2. Verify namespace exists and is running
3. Check firewall settings in Azure Portal

</details>

<details>
<summary>Authorization error</summary>

The connection string needs `Send` permission. The default `RootManageSharedAccessKey` has all permissions.

</details>

## Next Step

Continue to [04-receive-events.md](04-receive-events.md)

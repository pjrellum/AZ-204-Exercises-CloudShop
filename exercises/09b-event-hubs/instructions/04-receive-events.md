# Task 4: Receive Events (Consumer)

Run the consumer to read events with checkpointing.

## Prerequisites

Set environment variables:
```bash
export EVENTHUB_CONNECTION_STRING="<your-eventhub-connection>"
export EVENTHUB_NAME="clickstream"
export STORAGE_CONNECTION_STRING="<your-storage-connection>"
```

## Steps

### Option A: Use Python Consumer

```bash
cd ../code/python/complete
python consumer.py
```

### Option B: Use .NET Consumer

```bash
cd ../code/dotnet/complete
dotnet run consumer --connection "$EVENTHUB_CONNECTION_STRING" --storage "$STORAGE_CONNECTION_STRING"
```

## Expected Output

```
Starting consumer for clickstream...
Press Ctrl+C to stop

Starting to receive from partition 0
Starting to receive from partition 1
Starting to receive from partition 2
Starting to receive from partition 3

[Partition 0] Event received:
  Session: abc-123...
  User: user-42
  Page: /products/widget-001
  Action: view

[Partition 2] Event received:
  Session: def-456...
  ...
```

## Understanding the Output

Events come from **different partitions** because:
- Producer distributes events across partitions (round-robin by default)
- Consumer receives from all partitions in parallel
- Order is only guaranteed within a partition

## Checkpointing Behavior

The consumer checkpoints after each event:

```python
async def on_event(partition_context, event):
    # Process event
    print(f"Event: {event.body_as_str()}")

    # Update checkpoint - "I processed up to here"
    await partition_context.update_checkpoint(event)
```

<details>
<summary>What happens on restart?</summary>

1. Consumer starts
2. Reads checkpoint from blob storage
3. Resumes from last checkpointed position
4. No duplicate processing!

</details>

## Test Checkpoint Recovery

1. Run consumer, receive some events
2. Press Ctrl+C to stop
3. Restart consumer
4. Observer: starts from where it left off, not from beginning

## Next Step

Continue to [05-verify.md](05-verify.md)

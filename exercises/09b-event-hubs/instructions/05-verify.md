# Task 5: Verify Partition Distribution

Verify events are distributed across partitions and checkpoints are working.

## Steps

### 1. Check Partition IDs

```bash
az eventhubs eventhub show \
    --name $EVENTHUB_NAME \
    --namespace-name $EVENTHUB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query partitionIds
```

Expected: `["0", "1", "2", "3"]`

### 2. Check Checkpoint Blobs

```bash
az storage blob list \
    --account-name $STORAGE_NAME \
    --container-name checkpoints \
    --output table
```

You should see checkpoint files for each partition.

### 3. View a Checkpoint

```bash
# Download and view a checkpoint
az storage blob download \
    --account-name $STORAGE_NAME \
    --container-name checkpoints \
    --name "\$Default/checkpoint/0" \
    --file /tmp/checkpoint.json 2>/dev/null

cat /tmp/checkpoint.json
```

Checkpoint contains:
```json
{
    "offset": "1234",
    "sequence_number": 42,
    "partition_id": "0"
}
```

### 4. Monitor Event Hub Metrics (Portal)

In Azure Portal:
1. Go to Event Hubs namespace
2. Click on `clickstream` hub
3. View **Metrics**:
   - Incoming Messages
   - Outgoing Messages
   - Throttled Requests

## Validation Checklist

- [ ] Event Hub has 4 partitions
- [ ] Producer sends events successfully
- [ ] Consumer receives from all partitions
- [ ] Checkpoints are created in blob storage
- [ ] Consumer resumes correctly after restart

## Run Validation Script

```bash
cd ../validate
./check-all.sh
```

## Complete!

You've successfully:
1. Created Event Hubs namespace with Standard tier
2. Created hub with 4 partitions
3. Sent events using producer
4. Consumed events with checkpointing
5. Verified partition distribution

## Next Steps

- Complete the [Challenge](../challenge.md) to enable Capture
- Continue to [Exercise 10: Service Bus](../../10-service-bus/README.md)

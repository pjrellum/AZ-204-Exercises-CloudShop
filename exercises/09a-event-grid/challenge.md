# Challenge 02: Smart Filtering & Dead-Letter

## Scenario

The orders container receives various file types, but we only want to process JSON files. Also, we need to handle failed deliveries gracefully.

## Requirements

1. Filter events to only `.json` files
2. Filter to only the `orders/` container path
3. Configure dead-letter storage for failed events
4. Test failure handling

## Part 1: Subject Filtering

Update the subscription to filter by subject:

```bash
# Delete existing subscription
az eventgrid event-subscription delete \
  --name order-uploaded \
  --source-resource-id $STORAGE_ID

# Create with filters
az eventgrid event-subscription create \
  --name order-uploaded \
  --source-resource-id $STORAGE_ID \
  --endpoint $WEBHOOK_URL \
  --endpoint-type webhook \
  --included-event-types Microsoft.Storage.BlobCreated \
  --subject-begins-with "/blobServices/default/containers/orders/blobs/" \
  --subject-ends-with ".json"
```

### Test Filtering

```bash
# This should trigger (JSON file)
echo '{"test": true}' > test.json
az storage blob upload --account-name stcloudshoporders$UNIQUE_SUFFIX \
  --container-name orders --name test.json --file test.json

# This should NOT trigger (TXT file)
echo 'not json' > test.txt
az storage blob upload --account-name stcloudshoporders$UNIQUE_SUFFIX \
  --container-name orders --name test.txt --file test.txt

# This should NOT trigger (wrong container)
az storage container create --name archive --account-name stcloudshoporders$UNIQUE_SUFFIX
echo '{"test": true}' > archived.json
az storage blob upload --account-name stcloudshoporders$UNIQUE_SUFFIX \
  --container-name archive --name archived.json --file archived.json
```

## Part 2: Dead-Letter Configuration

Configure dead-letter storage for failed events:

```bash
# Create dead-letter container
az storage container create \
  --name deadletter \
  --account-name stcloudshoporders$UNIQUE_SUFFIX

# Get container resource ID
DL_CONTAINER="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/stcloudshoporders$UNIQUE_SUFFIX/blobServices/default/containers/deadletter"

# Update subscription with dead-letter
az eventgrid event-subscription update \
  --name order-uploaded \
  --source-resource-id $STORAGE_ID \
  --deadletter-endpoint $DL_CONTAINER
```

### Test Dead-Letter

1. Make the webhook fail temporarily (return 500)
2. Upload a file
3. Wait for retries to exhaust (check Azure Portal for retry attempts)
4. Check dead-letter container for the failed event

## Advanced: Event Schema

View the event schema to understand what data you receive:

```json
{
  "id": "unique-event-id",
  "eventType": "Microsoft.Storage.BlobCreated",
  "subject": "/blobServices/default/containers/orders/blobs/order001.json",
  "eventTime": "2024-01-15T10:30:00Z",
  "data": {
    "api": "PutBlob",
    "blobType": "BlockBlob",
    "contentLength": 128,
    "contentType": "application/json",
    "url": "https://stcloudshoporders.../orders/order001.json"
  }
}
```

## Validation

- [ ] Only `.json` files trigger events
- [ ] Only `orders/` container triggers events
- [ ] Dead-letter endpoint is configured
- [ ] Failed events appear in dead-letter container

## Solution

See [solution/challenge-solution.md](solution/challenge-solution.md) for complete implementation.

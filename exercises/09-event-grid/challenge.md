# Challenge: Explore Filtering & Dead-Letter Handling

## Scenario

The CloudShop Event Grid subscription is pre-configured with:
1. **Subject filtering** - only JSON files in the orders container trigger events
2. **Dead-letter storage** - failed events are stored for investigation

This challenge explores how these features work.

## Learning Objectives

- Understand subject-based event filtering (exam topic)
- Verify and explore dead-letter storage configuration
- Understand Event Grid retry and failure handling

## Prerequisites

Complete the main exercise first - you need a working Event Grid subscription.

## Part 1: Verify Subject Filtering

Subject filtering is already configured by the main deployment. Only JSON files in the orders container trigger events.

### Step 1: View Current Subscription Filters

```bash
# Get the storage account resource ID
STORAGE_ID=$(az storage account show \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query id -o tsv)

# View subscription with filter details
az eventgrid event-subscription show \
    --name order-upload-sub \
    --source-resource-id $STORAGE_ID \
    --query "{name:name, subjectBeginsWith:filter.subjectBeginsWith, subjectEndsWith:filter.subjectEndsWith}"
```

**Expected:** Should show filters for `/blobServices/default/containers/orders/blobs/` and `.json`.

### Step 2: Test the Filters

```bash
# Create test files
echo '{"orderId": "TEST-001", "customer": "Test"}' > /tmp/order.json
echo 'This is not JSON' > /tmp/notes.txt

# Upload JSON to orders/ - SHOULD trigger
az storage blob upload \
    --account-name $STORAGE_NAME \
    --container-name orders \
    --name "order-filter-test.json" \
    --file /tmp/order.json \
    --auth-mode login

# Upload TXT to orders/ - should NOT trigger
az storage blob upload \
    --account-name $STORAGE_NAME \
    --container-name orders \
    --name "notes.txt" \
    --file /tmp/notes.txt \
    --auth-mode login

# Check function logs
az functionapp logs tail --name $FUNC_NAME --resource-group $RESOURCE_GROUP
```

**Expected:** Only the JSON upload appears in function logs. The TXT file is ignored due to the `.json` filter.

## Part 2: Verify Dead-Letter Configuration

Dead-letter storage is already configured by the main deployment. When event delivery fails (webhook down, function errors), events go to the `deadletter` container.

### Step 1: Verify Dead-Letter is Configured

```bash
# Check the subscription's dead-letter destination
az eventgrid event-subscription show \
    --name order-upload-sub \
    --source-resource-id $STORAGE_ID \
    --query "deadLetterDestination"
```

**Expected:** Should show the `deadletter` container as the destination.

### Step 2: Verify Dead-Letter Container Exists

```bash
# List containers - should see 'deadletter'
az storage container list \
    --account-name $STORAGE_NAME \
    --auth-mode login \
    --query "[].name" -o tsv
```

### Step 3: View Dead-Lettered Events (if any)

```bash
# List any dead-lettered events
az storage blob list \
    --account-name $STORAGE_NAME \
    --container-name deadletter \
    --auth-mode login \
    --output table
```

**Note:** You'll only see events here if delivery has failed. To test, you could temporarily stop the Function App, upload a file, wait for retries to exhaust, then check this container.

## Validation Checklist

- [ ] Verified `.json` filter is configured
- [ ] Verified `orders/` container filter is configured
- [ ] Verified dead-letter endpoint is configured
- [ ] Tested that TXT uploads are ignored

## Event Grid Filtering Options

| Filter Type | Example | Use Case |
|-------------|---------|----------|
| Event Types | `Microsoft.Storage.BlobCreated` | Only specific event types |
| Subject Begins With | `/blobServices/.../orders/` | Container/path filtering |
| Subject Ends With | `.json` | File extension filtering |
| Advanced Filters | `data.contentLength > 1000` | Property-based filtering |

## Common Exam Topics

- Subject filtering uses the event's `subject` field (blob path for storage events)
- Dead-letter requires a storage blob container
- Event Grid guarantees at-least-once delivery
- Maximum retry period is 24 hours
- Events expire after 24 hours if not delivered
- Retry policy: immediate → 10s → 30s → 1min → 5min intervals (max 24 hours)

# Task 4: Create Event Grid Subscription

Create an Event Grid subscription to route blob events to your function.

## What You'll Create

- Event Grid System Topic (auto-created)
- Event Subscription: `order-uploaded`
- Filter: BlobCreated events for `.json` files in `orders/`

## Steps

### 1. Get Storage Account Resource ID

```bash
STORAGE_ID=$(az storage account show \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query id -o tsv)

echo "Storage ID: $STORAGE_ID"
```

### 2. Get Webhook URL

```bash
WEBHOOK_URL="https://${FUNC_NAME}.azurewebsites.net/api/OrderUploaded"
echo "Webhook URL: $WEBHOOK_URL"
```

### 3. Create Event Grid Subscription

```bash
az eventgrid event-subscription create \
    --name order-uploaded \
    --source-resource-id $STORAGE_ID \
    --endpoint $WEBHOOK_URL \
    --endpoint-type webhook \
    --included-event-types Microsoft.Storage.BlobCreated \
    --subject-begins-with "/blobServices/default/containers/orders/blobs/" \
    --subject-ends-with ".json"
```

<details>
<summary>What do the filters do?</summary>

- `--included-event-types`: Only BlobCreated events (not deleted, etc.)
- `--subject-begins-with`: Only blobs in the `orders/` container
- `--subject-ends-with`: Only `.json` files

This prevents triggering on irrelevant uploads.

</details>

<details>
<summary>Subscription creation fails?</summary>

Common issues:
1. **Function not deployed** - Event Grid validates the webhook
2. **Wrong URL** - Check the function name matches
3. **Function returning errors** - Check function logs

```bash
az functionapp logs tail --name $FUNC_NAME --resource-group $RESOURCE_GROUP
```

</details>

### 4. (Optional) Add Dead-Letter

```bash
az eventgrid event-subscription update \
    --name order-uploaded \
    --source-resource-id $STORAGE_ID \
    --deadletter-endpoint "${STORAGE_ID}/blobServices/default/containers/deadletter"
```

## Validation

```bash
# Check subscription exists
az eventgrid event-subscription show \
    --name order-uploaded \
    --source-resource-id $STORAGE_ID \
    --query "{name:name, endpoint:destination.endpointUrl, filter:filter}"
```

Expected output shows your webhook URL and filters.

## Next Step

Continue to [05-test.md](05-test.md)

# Task 5: Test the Integration

Upload a test file and verify Event Grid triggers your function.

## Steps

### 1. Create Test Order File

```bash
cat > /tmp/order-test.json << 'EOF'
{
    "orderId": "ORD-TEST-001",
    "customer": "Test Customer",
    "items": [
        {"sku": "WIDGET-001", "quantity": 2, "price": 25.00},
        {"sku": "GADGET-002", "quantity": 1, "price": 49.99}
    ],
    "total": 99.99,
    "timestamp": "2024-01-15T10:30:00Z"
}
EOF
```

### 2. Upload to Blob Storage

```bash
az storage blob upload \
    --account-name $STORAGE_NAME \
    --container-name orders \
    --name order-test.json \
    --file /tmp/order-test.json \
    --overwrite
```

### 3. Check Function Logs

```bash
az functionapp logs tail \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP
```

You should see output like:
```
[Information] ORDER FILE UPLOADED
[Information] Subject: /blobServices/default/containers/orders/blobs/order-test.json
[Information] Blob URL: https://stcloudshop.../orders/order-test.json
[Information] Content Type: application/json
```

### 4. Test Filtering (Optional)

Verify that non-.json files don't trigger:

```bash
# This should NOT trigger the function
echo "not json" > /tmp/test.txt
az storage blob upload \
    --account-name $STORAGE_NAME \
    --container-name orders \
    --name test.txt \
    --file /tmp/test.txt
```

Check logs - no event should appear for `.txt` files.

## Troubleshooting

<details>
<summary>No logs appearing</summary>

1. Wait 30 seconds - there can be a delay
2. Check Event Grid subscription is active
3. Verify function is deployed: `az functionapp function list --name $FUNC_NAME --resource-group $RESOURCE_GROUP`

</details>

<details>
<summary>Event received but errors in processing</summary>

Check the function code handles:
1. Validation events (`SubscriptionValidationEvent`)
2. Blob events (`BlobCreated`)
3. JSON parsing

</details>

## Validation Checklist

- [ ] Test file uploaded successfully
- [ ] Function logs show event received
- [ ] Event details (URL, content type) are logged
- [ ] Non-.json files don't trigger events

## Complete!

You've successfully:
1. Created storage with orders and dead-letter containers
2. Deployed a Function App with webhook handler
3. Created Event Grid subscription with filters
4. Tested the end-to-end flow

## Next Steps

- Complete the [Challenge](../challenge.md) for advanced filtering
- Continue to [Exercise 09b: Event Hubs](../../09b-event-hubs/README.md)

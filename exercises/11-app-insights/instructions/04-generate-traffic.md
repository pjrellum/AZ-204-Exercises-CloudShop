# Task 4: Generate Test Traffic

Generate traffic to populate Application Insights with data.

## Steps

### 1. Send API Requests

```bash
# Send 20 requests through APIM
for i in {1..20}; do
    curl -s -w "%{http_code}\n" \
        -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
        "https://${APIM_NAME}.azure-api.net/orders" \
        -o /dev/null
    sleep 1
done
```

### 2. Send Direct Function Requests

```bash
# Send 10 requests directly to Function
for i in {1..10}; do
    curl -s "https://${FUNC_NAME}.azurewebsites.net/api/orders" -o /dev/null
    echo "Request $i sent"
    sleep 1
done
```

### 3. Trigger Some Errors (Optional)

```bash
# Send requests that will fail (invalid route)
for i in {1..5}; do
    curl -s "https://${FUNC_NAME}.azurewebsites.net/api/nonexistent" -o /dev/null
    sleep 1
done
```

### 4. Upload Test Files (If Event Grid configured)

```bash
for i in {1..5}; do
    echo "{\"orderId\": \"ORD-$(date +%s)-$i\", \"test\": true}" > /tmp/order-$i.json
    az storage blob upload \
        --account-name $STORAGE_NAME \
        --container-name orders \
        --name "order-$i.json" \
        --file /tmp/order-$i.json \
        --overwrite \
        --output none
    echo "Uploaded order-$i.json"
done
```

## Wait for Data

Application Insights typically shows data within **2-5 minutes**.

## Quick Verification

```bash
# Check Live Metrics in portal
echo "Open: https://portal.azure.com/#@/resource/subscriptions/.../resourceGroups/$RESOURCE_GROUP/providers/microsoft.insights/components/$APPINSIGHTS_NAME/LiveStream"
```

## Next Step

Continue to [05-explore-portal.md](05-explore-portal.md)

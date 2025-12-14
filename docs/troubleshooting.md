# Troubleshooting Guide

Common issues and solutions for the CloudShop Pipeline workshop.

## General Issues

### "Subscription not found" or "No subscription set"

**Problem:** Azure CLI doesn't know which subscription to use.

**Solution:**
```bash
# List available subscriptions
az account list --output table

# Set the correct subscription
az account set --subscription "Your Subscription Name"

# Verify
az account show
```

### "Resource provider not registered"

**Problem:** Required Azure services aren't enabled in your subscription.

**Solution:**
```bash
# Register all required providers
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.EventGrid
az provider register --namespace Microsoft.EventHub
az provider register --namespace Microsoft.ServiceBus
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.Web

# Check registration status
az provider show --namespace Microsoft.ApiManagement --query registrationState
```

### Permission Denied on Scripts

**Problem:** Shell scripts aren't executable.

**Solution:**
```bash
chmod +x scripts/*.sh
```

---

## Exercise 08: API Management

### APIM Takes Too Long to Create

**Problem:** Developer/Standard tier takes 30-45 minutes.

**Solution:** Use Consumption tier for faster provisioning:
```bash
az apim create ... --sku-name Consumption
```

### "API import failed"

**Problem:** Function App isn't accessible or doesn't have the expected endpoints.

**Solution:**
1. Verify Function App is running:
   ```bash
   az functionapp show --name func-cloudshop-$UNIQUE_SUFFIX --query state
   ```
2. Check function URL works:
   ```bash
   curl https://func-cloudshop-$UNIQUE_SUFFIX.azurewebsites.net/api/health
   ```
3. Ensure function has HTTP triggers with correct routes

---

## Exercise 09a: Event Grid

### "Webhook validation failed"

**Problem:** Event Grid can't validate your webhook endpoint.

**Solution:** Your webhook must handle the validation request:
```csharp
[Function("OrderUploaded")]
public async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req)
{
    // Handle Event Grid validation
    if (req.Headers.TryGetValue("aeg-event-type", out var eventType))
    {
        if (eventType == "SubscriptionValidation")
        {
            var body = await req.ReadFromJsonAsync<List<EventGridEvent>>();
            var validationCode = body[0].Data.GetProperty("validationCode").GetString();
            return new OkObjectResult(new { validationResponse = validationCode });
        }
    }

    // Handle normal events
    // ...
}
```

### "No events received"

**Problem:** Blob uploads don't trigger events.

**Solution:**
1. Verify subscription exists and is active:
   ```bash
   az eventgrid event-subscription show --name order-uploaded --source-resource-id $STORAGE_ID
   ```
2. Check filters aren't too restrictive:
   ```bash
   az eventgrid event-subscription show --name order-uploaded --source-resource-id $STORAGE_ID --query filter
   ```
3. Ensure you're uploading to the correct container

---

## Exercise 09b: Event Hubs

### "Consumer not receiving events"

**Problem:** Event Processor doesn't receive any events.

**Solution:**
1. Verify events were sent (check namespace metrics in Portal)
2. Check connection string includes the hub name or is namespace-level
3. Ensure checkpoint container exists:
   ```bash
   az storage container create --name checkpoints --account-name $STORAGE_ACCOUNT
   ```
4. Verify consumer group exists:
   ```bash
   az eventhubs eventhub consumer-group list --hub-name clickstream \
     --namespace-name evhns-cloudshop-$UNIQUE_SUFFIX --resource-group $RESOURCE_GROUP
   ```

### "Capture not creating files"

**Problem:** No Avro files appear in the archive container.

**Solution:**
1. Capture only triggers when interval OR size limit is reached
2. Send enough events or wait for the interval (default 5 min)
3. Check capture is enabled:
   ```bash
   az eventhubs eventhub show --name clickstream \
     --namespace-name evhns-cloudshop-$UNIQUE_SUFFIX \
     --resource-group $RESOURCE_GROUP \
     --query captureDescription
   ```

---

## Exercise 10: Service Bus

### "Message not appearing in queue"

**Problem:** Sent messages don't show up.

**Solution:**
1. Check queue exists:
   ```bash
   az servicebus queue show --name order-processing \
     --namespace-name sb-cloudshop-$UNIQUE_SUFFIX --resource-group $RESOURCE_GROUP
   ```
2. Verify message count:
   ```bash
   az servicebus queue show ... --query countDetails.activeMessageCount
   ```
3. Check if messages went to dead-letter:
   ```bash
   az servicebus queue show ... --query countDetails.deadLetterMessageCount
   ```

### "Subscription filter not working"

**Problem:** SQL filter doesn't match expected messages.

**Solution:** SQL filters work on **ApplicationProperties**, not message body:
```csharp
// WRONG - filter won't see this
var message = new ServiceBusMessage(JsonSerializer.Serialize(new { total = 150 }));

// CORRECT - filter can access this
var message = new ServiceBusMessage(...);
message.ApplicationProperties["total"] = 150;
```

---

## Exercise 11: Application Insights

### "No telemetry appearing"

**Problem:** App Insights shows no data.

**Solution:**
1. Verify connection string is set:
   ```bash
   az functionapp config appsettings list --name func-cloudshop-$UNIQUE_SUFFIX \
     --resource-group $RESOURCE_GROUP --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"
   ```
2. Wait 2-5 minutes for telemetry to appear
3. Check Live Metrics to verify connection
4. Restart the Function App:
   ```bash
   az functionapp restart --name func-cloudshop-$UNIQUE_SUFFIX --resource-group $RESOURCE_GROUP
   ```

### "Application Map is empty"

**Problem:** No services appear in the map.

**Solution:**
1. Generate traffic through the system
2. Wait 5-10 minutes for map to populate
3. Ensure all services have the same App Insights instance

---

## Cost Issues

### "Unexpected charges"

**Prevention:**
1. Use Consumption tier for APIM
2. Use Standard tier for Event Hubs/Service Bus (minimum required)
3. Delete resources after workshop:
   ```bash
   ./scripts/cleanup.sh
   ```

### "Resource deletion failed"

**Problem:** Can't delete resource group.

**Solution:**
1. Check for delete locks:
   ```bash
   az lock list --resource-group $RESOURCE_GROUP
   ```
2. Delete locks first:
   ```bash
   az lock delete --name LockName --resource-group $RESOURCE_GROUP
   ```
3. Some resources (like APIM) take time to delete - wait and retry

---

## Still Stuck?

1. Check Azure Service Health: [status.azure.com](https://status.azure.com)
2. Review Azure CLI output with `--debug` flag
3. Check resource activity logs in Azure Portal
4. Open an issue on the [GitHub repository]({{ repo_url }}/issues)

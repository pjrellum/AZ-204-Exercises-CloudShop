# Task 3: Deploy Function Code

Deploy the Event Grid webhook handler to your Function App.

## Choose Your Language

| Language | Folder |
|----------|--------|
| Python | `code/python/complete/` |
| .NET | `code/dotnet/complete/` |
| Node.js | `code/node/complete/` |

## Steps

### Option A: Use Deploy Script

```bash
cd ../deploy
./deploy-code.sh python complete
```

### Option B: Manual Deployment

#### Python

```bash
cd ../code/python/complete
func azure functionapp publish $FUNC_NAME --python
```

#### .NET

```bash
cd ../code/dotnet/complete
dotnet publish -c Release
func azure functionapp publish $FUNC_NAME
```

#### Node.js

```bash
cd ../code/node/complete
npm install
func azure functionapp publish $FUNC_NAME --javascript
```

## What the Function Does

The `OrderUploaded` function:

1. **Handles validation** - When Event Grid creates a subscription, it sends a validation request. The function must return the validation code.

2. **Processes BlobCreated events** - When a file is uploaded to the orders container, Event Grid sends an event with details about the blob.

3. **Logs event details** - For this exercise, we log the event. In production, you'd forward to Service Bus.

<details>
<summary>View the core logic (Python)</summary>

```python
@app.route(route="OrderUploaded", methods=["POST", "OPTIONS"])
def order_uploaded(req):
    # Handle validation handshake
    if event_type == "Microsoft.EventGrid.SubscriptionValidationEvent":
        return {"validationResponse": validation_code}

    # Handle blob created
    if event_type == "Microsoft.Storage.BlobCreated":
        logging.info(f"Blob URL: {event['data']['url']}")
```

</details>

## Validation

```bash
# Check function is deployed
az functionapp function list \
    --name $FUNC_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "[].name" -o tsv
```

Expected output:
```
OrderUploaded
```

## Next Step

Continue to [04-event-grid.md](04-event-grid.md)

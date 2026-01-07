# Function Code

.NET 8 implementation with the complete CloudShop order pipeline.

## Functions Included

| Function | Trigger | Description |
|----------|---------|-------------|
| OrdersApi | HTTP | Orders REST API → Service Bus |
| OrderUploadHandler | HTTP (Event Grid) | Blob events → Service Bus |
| OrderProcessor | Service Bus | Processes orders from queue |

## Service Bus Integration

Both `OrdersApi` and `OrderUploadHandler` send messages to Service Bus.
`OrderProcessor` receives and processes them.

Orders over $10,000 are sent to dead-letter queue for demo purposes.

## Deploying

```bash
cd code/dotnet
func azure functionapp publish func-cloudshop-<your-suffix>
```

## Local Development

1. Set your Service Bus connection string in `local.settings.json`
2. Run the functions:
   ```bash
   cd code/dotnet
   func start
   ```

3. Test:
   ```bash
   curl -X POST http://localhost:7071/api/orders \
     -H "Content-Type: application/json" \
     -d '{"customer": "Test", "total": 99.99}'
   ```

# Function Code

.NET 8 implementation with Orders API + Event Grid handler.

## Functions Included

| Function | Trigger | Description |
|----------|---------|-------------|
| OrdersApi | HTTP | Orders REST API (from Exercise 08) |
| OrderUploadHandler | HTTP (Event Grid) | Handles blob upload events |

## Deploying

```bash
cd code/dotnet
func azure functionapp publish func-cloudshop-<your-suffix>
```

## Local Development

```bash
cd code/dotnet
func start
```

Test Event Grid handler:
```bash
curl -X POST http://localhost:7071/api/OrderUploaded \
  -H "Content-Type: application/json" \
  -d @../test/sample-event.json
```

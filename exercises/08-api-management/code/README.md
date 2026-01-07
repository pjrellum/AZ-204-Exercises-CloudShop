# Function Code

.NET 8 implementation for the Orders API.

## What the Function Does

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/orders` | GET | Returns API status |
| `/api/orders` | POST | Receives an order (acknowledged) |
| `/api/health` | GET | Health check endpoint |

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

Then test at: `http://localhost:7071/api/orders`

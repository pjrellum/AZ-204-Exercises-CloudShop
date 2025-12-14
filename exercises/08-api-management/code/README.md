# Function Code

.NET implementation for the Orders API function.

## Folder Structure

```
dotnet/
├── starter/      # Template with TODOs
└── complete/     # Full working solution
```

## What the Function Does

The Orders API function handles:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/orders` | GET | List orders (returns sample data) |
| `/api/orders` | POST | Create a new order |

## Deploying

### Option 1: Use the Deploy Script

```bash
# From the exercise root
./deploy/deploy-code.sh dotnet
```

### Option 2: Azure Functions Core Tools

```bash
cd code/dotnet/complete
func azure functionapp publish $FUNCTION_APP
```

### Option 3: VS Code

1. Open the function folder in VS Code
2. Install Azure Functions extension
3. Right-click on the folder → Deploy to Function App

## Local Development

```bash
cd code/dotnet/complete
func start
```

Then test at: `http://localhost:7071/api/orders`

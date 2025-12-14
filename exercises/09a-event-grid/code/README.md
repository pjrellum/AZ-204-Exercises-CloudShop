# Event Grid Function Code

.NET implementation for the webhook handler that receives Event Grid events.

## Structure

```
code/
└── dotnet/
    ├── starter/      # Template with TODOs
    └── complete/     # Working solution
```

## Choose Your Version

- **starter/** - Has TODO comments, you write the implementation
- **complete/** - Full working solution for reference

## What the Function Does

1. Receives HTTP POST from Event Grid
2. Handles subscription validation handshake
3. Processes `BlobCreated` events
4. Logs order file details

## Deploying

```bash
# From the exercise root
cd deploy
./deploy-code.sh dotnet complete
```

Or manually:

```bash
cd dotnet/complete
dotnet publish -c Release
func azure functionapp publish $FUNC_NAME
```

## Local Development

```bash
# Install Azure Functions Core Tools first
# https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local

cd dotnet/complete
func start
```

Then send test events:
```bash
curl -X POST http://localhost:7071/api/OrderUploaded \
  -H "Content-Type: application/json" \
  -d @../../../test/sample-event.json
```

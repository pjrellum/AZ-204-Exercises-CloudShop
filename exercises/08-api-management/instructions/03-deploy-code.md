# Task 3: Deploy Function Code

## Objective

Deploy the Orders API function code to your Function App.

## Requirements

Create and deploy a function with:

| Setting | Value |
|---------|-------|
| Function Name | `Orders` |
| Trigger | HTTP (GET and POST) |
| Auth Level | Anonymous (APIM will handle auth) |

The function should:
- Accept GET requests to list orders (return sample data)
- Accept POST requests to create an order (return the created order)

## What You Need to Do

1. Choose your language folder: `code/{dotnet|node|python|powershell}/`
2. Use the `starter/` template or create your own
3. Deploy to your Function App
4. Test the function directly (before adding APIM)

## Validation

```bash
# Test the function directly (replace with your function URL)
curl https://$FUNCTION_APP.azurewebsites.net/api/orders
```

Expected response (something like):
```json
{
  "message": "Orders API is running",
  "orders": []
}
```

---

## Hints

<details>
<summary>Hint: What does the function need to do?</summary>

For this exercise, a simple function is enough:

**GET /api/orders** - Return a list (can be empty or sample data)
**POST /api/orders** - Accept JSON body, return confirmation

The real logic will come in later exercises. For now, focus on getting the HTTP endpoints working.

</details>

<details>
<summary>Hint: How do I deploy?</summary>

There are several ways:
1. **Azure Functions Core Tools:** `func azure functionapp publish $FUNCTION_APP`
2. **VS Code:** Use the Azure Functions extension
3. **ZIP Deploy:** Package and deploy via CLI
4. **GitHub Actions:** CI/CD pipeline (for production)

For this exercise, the Core Tools method is quickest.

</details>

<details>
<summary>Hint: Where's the starter code?</summary>

Check these folders:
- .NET: `code/dotnet/starter/`
- Node.js: `code/node/starter/`
- Python: `code/python/starter/`
- PowerShell: `code/powershell/starter/`

Each has a template with TODOs marked.

</details>

<details>
<summary>Show deployment command</summary>

```bash
# Navigate to your code folder (e.g., for .NET)
cd code/dotnet/complete

# Deploy using Azure Functions Core Tools
func azure functionapp publish $FUNCTION_APP
```

Or use the deploy script:
```bash
./deploy/deploy-code.sh dotnet  # or: node, python, powershell
```

</details>

---

**Previous:** [02-function-app.md](02-function-app.md) | **Next:** [04-create-apim.md](04-create-apim.md)

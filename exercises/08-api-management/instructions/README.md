# Exercise 08: Instructions

Complete these tasks in order. Each task tells you **what** to accomplish - use the hints if you need guidance on **how**.

## Prerequisites

Before starting:
- [ ] Azure CLI installed and logged in (`az login`)
- [ ] Environment configured (`cp env.example.sh env.sh` then edit and `source env.sh`)

## Tasks

| # | Task | Time | Description |
|---|------|------|-------------|
| 1 | [Create Resource Group & Storage](01-storage-account.md) | 5 min | Resource group and storage |
| 2 | [Create Function App](02-function-app.md) | 10 min | Orders API backend |
| 3 | [Deploy Function Code](03-deploy-code.md) | 10 min | .NET for now |
| 4 | [Create API Management](04-create-apim.md) | 5 min | API gateway |
| 5 | [Import & Configure API](05-configure-api.md) | 10 min | Connect APIM to Function |
| 6 | [Test the API](06-test-api.md) | 5 min | Validate everything works |

## Validation Checklist

After completing all tasks, verify:

- [ ] Resource group exists
- [ ] Storage account exists
- [ ] Function App is running
- [ ] Function responds to HTTP requests
- [ ] APIM instance is provisioned
- [ ] API is imported into APIM
- [ ] Requests with valid subscription key succeed
- [ ] Requests without key return 401

Run the validation script:
```bash
./validate/check-all.sh
```

## Need Help?

- **Hints:** Expand the hint sections in each task file
- **Starter files:** Check `infrastructure/*/starter/` or `code/*/starter/`
- **Solutions:** Check `infrastructure/*/complete/` or `code/*/complete/`
- **Quick deploy:** Run `./quickstart/deploy-all.sh` to see a working example

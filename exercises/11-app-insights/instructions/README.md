# Instructions Overview

This exercise has 5 main tasks:

| Task | Description | Time |
|------|-------------|------|
| [01-create-appinsights](01-create-appinsights.md) | Create Application Insights resource | 5 min |
| [02-connect-functions](02-connect-functions.md) | Connect Azure Functions | 5 min |
| [03-connect-apim](03-connect-apim.md) | Connect API Management | 5 min |
| [04-generate-traffic](04-generate-traffic.md) | Generate test traffic | 5 min |
| [05-explore-portal](05-explore-portal.md) | Explore Application Insights features | 10 min |

## Prerequisites

- Azure subscription with permissions to create resources
- Azure CLI installed and logged in
- Previous exercises completed (Function App, APIM deployed)
- Environment configured (`source ../env.sh`)

## Quick Reference

```bash
# Load environment
source ../env.sh

# Deploy infrastructure
cd ../infrastructure/azure-cli/complete
./deploy.sh

# Generate traffic
cd ../test
./generate-traffic.sh
```

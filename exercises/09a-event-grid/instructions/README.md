# Instructions Overview

This exercise has 5 main tasks:

| Task | Description | Time |
|------|-------------|------|
| [01-storage-account](01-storage-account.md) | Create storage account and containers | 5 min |
| [02-function-app](02-function-app.md) | Create Function App for webhook | 5 min |
| [03-deploy-code](03-deploy-code.md) | Deploy the event processor function | 5 min |
| [04-event-grid](04-event-grid.md) | Create Event Grid subscription | 10 min |
| [05-test](05-test.md) | Test the integration | 5 min |

## Prerequisites

- Azure subscription with permissions to create resources
- Azure CLI installed and logged in
- Environment configured (`source ../env.sh`)

## Quick Reference

```bash
# Load environment
source ../env.sh

# Deploy infrastructure
cd ../infrastructure/azure-cli/complete
./deploy.sh

# Deploy code
cd ../deploy
./deploy-code.sh python complete

# Test
cd ../test
./test-eventgrid.sh
```

# Instructions Overview

This exercise has 5 main tasks:

| Task | Description | Time |
|------|-------------|------|
| [01-namespace](01-namespace.md) | Create Service Bus namespace | 5 min |
| [02-queue](02-queue.md) | Create order processing queue | 5 min |
| [03-send-messages](03-send-messages.md) | Send order messages | 10 min |
| [04-receive-messages](04-receive-messages.md) | Process and complete messages | 10 min |
| [05-dead-letter](05-dead-letter.md) | Explore dead-letter queue | 5 min |

## Prerequisites

- Azure subscription with permissions to create resources
- Azure CLI installed and logged in
- Python 3.11+ or .NET 8.0+ installed
- Environment configured (`source ../env.sh`)

## Quick Reference

```bash
# Load environment
source ../env.sh

# Deploy infrastructure
cd ../infrastructure/azure-cli/complete
./deploy.sh

# Run sender
cd ../code/python/complete
pip install -r requirements.txt
python sender.py --count 5

# Run receiver (in another terminal)
python receiver.py
```

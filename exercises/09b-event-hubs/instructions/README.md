# Instructions Overview

This exercise has 5 main tasks:

| Task | Description | Time |
|------|-------------|------|
| [01-event-hubs-namespace](01-event-hubs-namespace.md) | Create Event Hubs namespace and hub | 5 min |
| [02-checkpoint-storage](02-checkpoint-storage.md) | Create storage for checkpoints | 5 min |
| [03-send-events](03-send-events.md) | Run producer to send events | 10 min |
| [04-receive-events](04-receive-events.md) | Run consumer with checkpointing | 10 min |
| [05-verify](05-verify.md) | Verify partition distribution | 5 min |

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

# Run producer
cd ../code/python/complete
pip install -r requirements.txt
python producer.py --count 100

# Run consumer (in another terminal)
python consumer.py
```

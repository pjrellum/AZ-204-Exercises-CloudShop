#!/bin/bash
# Quick deployment - deploys everything for Service Bus exercise

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

source env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== CloudShop Service Bus - Quick Deploy ==="
echo "This will deploy all infrastructure and run a quick test."
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Service Bus Namespace: $SERVICEBUS_NAMESPACE"
echo "Queue Name: $QUEUE_NAME"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Deploy infrastructure
echo ""
echo "=== Step 1: Deploying Infrastructure ==="
cd infrastructure/azure-cli/complete
chmod +x deploy.sh
./deploy.sh

# Wait for resources to be ready
echo ""
echo "Waiting for resources to be ready..."
sleep 10

# Validate
echo ""
echo "=== Step 2: Validating Deployment ==="
cd ../../../validate
chmod +x check-all.sh
./check-all.sh || true

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "  1. Open Azure Portal -> Service Bus namespace -> Queues -> $QUEUE_NAME"
echo "  2. Click 'Service Bus Explorer' to send and receive test messages"
echo "  3. Try sending a JSON message and receiving it"

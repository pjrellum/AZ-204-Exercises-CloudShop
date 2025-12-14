#!/bin/bash
# Quick deployment - deploys everything for Event Hubs exercise

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

source env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== CloudShop Event Hubs - Quick Deploy ==="
echo "This will deploy all infrastructure and run a quick test."
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Event Hub Namespace: $EVENTHUB_NAMESPACE"
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
sleep 15

# Run quick test
echo ""
echo "=== Step 2: Running Quick Test ==="
cd ../../../code/dotnet/complete
chmod +x run.sh
./run.sh producer 5

# Validate
echo ""
echo "=== Step 3: Validating Deployment ==="
cd ../../../validate
chmod +x check-all.sh
./check-all.sh || true

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run producer: cd code/dotnet/complete && ./run.sh producer 100"
echo "  2. Run consumer: cd code/dotnet/complete && ./run.sh consumer"
echo ""
echo "Open two terminal windows to see producer and consumer in action!"

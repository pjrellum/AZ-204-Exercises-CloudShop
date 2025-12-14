#!/bin/bash
# Quick deployment - deploys everything for Application Insights exercise

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

source env.sh 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== CloudShop Application Insights - Quick Deploy ==="
echo "This will create Application Insights and connect existing services."
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Application Insights: $APPINSIGHTS_NAME"
echo ""
echo "This exercise connects to existing services from earlier exercises."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Deploy infrastructure (creates App Insights and connects Function)
echo ""
echo "=== Step 1: Deploying Application Insights ==="
cd infrastructure/azure-cli/complete
chmod +x deploy.sh
./deploy.sh

# Configure APIM (if available)
echo ""
echo "=== Step 2: Configuring API Management (if available) ==="
cd ../../../deploy
chmod +x configure-apim.sh
./configure-apim.sh || true

# Generate traffic
echo ""
echo "=== Step 3: Generating Test Traffic ==="
cd ../test
chmod +x generate-traffic.sh
./generate-traffic.sh 20

# Validate
echo ""
echo "=== Step 4: Validating Deployment ==="
cd ../validate
chmod +x check-all.sh
./check-all.sh || true

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "  1. Open Azure Portal -> Application Insights -> $APPINSIGHTS_NAME"
echo "  2. Explore Application Map, Live Metrics, Transaction Search"
echo "  3. Try KQL queries in the Logs section"
echo ""
echo "Generate more traffic:"
echo "  cd test && ./generate-traffic.sh 50"

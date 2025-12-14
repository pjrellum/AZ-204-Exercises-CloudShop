#!/bin/bash
# =============================================================================
# Deploy .NET Function Code to Azure
# =============================================================================
# Usage: ./deploy.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Load environment
source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying .NET function to $FUNCTION_APP ==="
echo ""

cd "$SCRIPT_DIR"

echo "Building .NET project..."
dotnet build --configuration Release

echo ""
echo "Deploying to Azure..."
func azure functionapp publish "$FUNCTION_APP"

echo ""
echo "=== Deployment complete! ==="
echo ""
echo "Function URL: https://$FUNCTION_APP.azurewebsites.net/api/orders"
echo ""
echo "Test with:"
echo "  curl https://$FUNCTION_APP.azurewebsites.net/api/orders"

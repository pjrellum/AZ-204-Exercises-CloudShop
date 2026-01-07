#!/bin/bash
# =============================================================================
# Deploy .NET Function Code to Azure
# =============================================================================
# Usage: ./deploy.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load environment
source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

echo "=== Deploying .NET function to $FUNC_NAME ==="
echo ""

cd "$SCRIPT_DIR"

echo "Building .NET project..."
dotnet publish -c Release

echo ""
echo "Deploying to Azure..."
func azure functionapp publish "$FUNC_NAME"

echo ""
echo "=== Deployment complete! ==="
echo ""
echo "The ProcessOrder function will automatically process messages from the '$QUEUE_NAME' queue."
echo ""
echo "To test:"
echo "  1. Send a message to the queue using Service Bus Explorer in the Azure Portal"
echo "  2. View function logs: func azure functionapp logstream $FUNC_NAME"

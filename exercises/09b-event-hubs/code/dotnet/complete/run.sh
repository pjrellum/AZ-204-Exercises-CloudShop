#!/bin/bash
# =============================================================================
# Run Event Hubs Producer/Consumer
# =============================================================================
# Usage: ./run.sh [producer|consumer] [count]
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Load environment
source "$EXERCISE_DIR/env.sh" 2>/dev/null || {
    echo "Error: env.sh not found. Copy env.example.sh to env.sh and configure it."
    exit 1
}

MODE="${1:-producer}"
COUNT="${2:-10}"

# Get connection strings
echo "Fetching connection strings..."
EVENTHUB_CONNECTION=$(az eventhubs namespace authorization-rule keys list \
    --namespace-name "$EVENTHUB_NAMESPACE" \
    --resource-group "$RESOURCE_GROUP" \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString -o tsv)

STORAGE_CONNECTION=$(az storage account show-connection-string \
    --name "$STORAGE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)

export EVENTHUB_CONNECTION_STRING="$EVENTHUB_CONNECTION"
export EVENTHUB_NAME="$EVENTHUB_NAME"
export STORAGE_CONNECTION_STRING="$STORAGE_CONNECTION"
export STORAGE_CONTAINER_NAME="checkpoints"

cd "$SCRIPT_DIR"
dotnet restore -q

echo ""
if [ "$MODE" == "producer" ]; then
    echo "=== Running Producer (sending $COUNT events) ==="
    dotnet run producer "$COUNT"
elif [ "$MODE" == "consumer" ]; then
    echo "=== Running Consumer ==="
    dotnet run consumer
else
    echo "Usage: $0 [producer|consumer] [event-count]"
    echo ""
    echo "Examples:"
    echo "  $0 producer 10   # Send 10 events"
    echo "  $0 consumer      # Start consuming events"
    exit 1
fi

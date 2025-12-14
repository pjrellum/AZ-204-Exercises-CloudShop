# Challenge 03: Enable Capture for Analytics Archive

## Scenario

The analytics team wants to run batch queries on historical click data. Enable Event Hubs Capture to automatically archive events to blob storage in Avro format.

## Requirements

1. Create archive container in storage
2. Enable Capture on the Event Hub
3. Configure capture interval and size
4. Verify Avro files are created

## Part 1: Enable Capture

```bash
# Create archive container
az storage container create \
  --name analytics-archive \
  --account-name stcloudshoporders$UNIQUE_SUFFIX

# Get storage account ID
STORAGE_ID=$(az storage account show \
  --name stcloudshoporders$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

# Enable Capture
az eventhubs eventhub update \
  --name clickstream \
  --namespace-name evhns-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP \
  --enable-capture true \
  --capture-destination-name "EventHubArchive.AzureBlockBlob" \
  --storage-account $STORAGE_ID \
  --blob-container "analytics-archive" \
  --capture-interval 60 \
  --capture-size-limit 10485760 \
  --skip-empty-archives true
```

## Part 2: Generate Events and Wait

Send a batch of events:

```bash
cd solution/src/EventProducer
dotnet run -- --connection "$EVENTHUB_CONNECTION" --hub "clickstream" --count 500
```

Wait for the capture interval (60 seconds) to pass.

## Part 3: Verify Archive Files

Check the blob container for Avro files:

```bash
az storage blob list \
  --account-name stcloudshoporders$UNIQUE_SUFFIX \
  --container-name analytics-archive \
  --output table
```

Expected folder structure:
```
analytics-archive/
└── evhns-cloudshop-xxx/
    └── clickstream/
        └── 0/                    <- partition
            └── 2024/
                └── 01/
                    └── 15/
                        └── 10/
                            └── 30/
                                └── capture.avro
```

## Part 4: Read Avro Files (Optional)

Download and inspect an Avro file:

```bash
# Download a capture file
az storage blob download \
  --account-name stcloudshoporders$UNIQUE_SUFFIX \
  --container-name analytics-archive \
  --name "evhns-cloudshop-.../clickstream/0/2024/01/15/10/30/capture.avro" \
  --file capture.avro

# Use avro-tools or Python to read
pip install fastavro
python -c "
import fastavro
with open('capture.avro', 'rb') as f:
    reader = fastavro.reader(f)
    for record in reader:
        print(record)
"
```

## Advanced: Query with Azure Synapse

If you have Azure Synapse, you can query Avro files directly:

```sql
SELECT
    JSON_VALUE(Body, '$.page') as page,
    JSON_VALUE(Body, '$.action') as action,
    COUNT(*) as event_count
FROM OPENROWSET(
    BULK 'https://stcloudshoporders.../analytics-archive/**/*.avro',
    FORMAT = 'PARQUET'
) AS events
GROUP BY
    JSON_VALUE(Body, '$.page'),
    JSON_VALUE(Body, '$.action')
ORDER BY event_count DESC
```

## Validation

- [ ] Capture is enabled on the Event Hub
- [ ] Events are archived to blob storage
- [ ] Avro files appear in the expected folder structure
- [ ] Capture interval is 60 seconds

## Capture Settings Explained

| Setting | Value | Description |
|---------|-------|-------------|
| `capture-interval` | 60 | Archive every 60 seconds |
| `capture-size-limit` | 10MB | Archive when 10MB accumulated |
| `skip-empty-archives` | true | Don't create empty files |

Capture happens when EITHER time OR size limit is reached.

## Solution

See [solution/challenge-solution.md](solution/challenge-solution.md) for complete implementation.

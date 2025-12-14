# Task 5: Explore Application Insights

Explore the key features of Application Insights in the Azure Portal.

## Navigate to Application Insights

1. Go to Azure Portal
2. Search for "Application Insights"
3. Select `ai-cloudshop-{suffix}`

## Key Features to Explore

### 1. Application Map

**Location:** Investigate → Application Map

Shows:
- All connected services
- Dependencies between services
- Health status (green/yellow/red)
- Request counts and failure rates

**What to look for:**
- APIM → Function → Storage chain
- Any red (failing) connections
- Latency between components

### 2. Live Metrics

**Location:** Investigate → Live Metrics

Shows real-time:
- Incoming request rate
- Request duration
- Failure rate
- Server health (CPU, memory)

**Try this:** Generate traffic while watching Live Metrics.

### 3. Transaction Search

**Location:** Investigate → Transaction Search

Search for:
- Specific request IDs
- Failed requests
- Requests to specific URLs

**Try this:** Click on a request to see the full trace.

### 4. Failures

**Location:** Investigate → Failures

Shows:
- Failed operations by exception type
- Failure trends over time
- Dependency failures

**Try this:** Click on an exception to see stack trace.

### 5. Performance

**Location:** Investigate → Performance

Shows:
- Response time percentiles (50th, 95th, 99th)
- Slowest operations
- Dependency performance

**Try this:** Identify the slowest endpoint.

## KQL Queries

**Location:** Monitoring → Logs

Try these queries:

### Recent Requests
```kusto
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
| render piechart
```

### Slowest Requests
```kusto
requests
| where timestamp > ago(1h)
| top 10 by duration
| project timestamp, name, duration, resultCode
```

### Failed Requests
```kusto
requests
| where success == false
| where timestamp > ago(1h)
| project timestamp, name, resultCode, url
```

### Dependencies
```kusto
dependencies
| where timestamp > ago(1h)
| summarize count() by target, type
| render barchart
```

## Validation Checklist

- [ ] Application Insights created
- [ ] Function App connected and sending telemetry
- [ ] APIM connected (if configured)
- [ ] Application Map shows services
- [ ] Can search transactions
- [ ] Can query logs with KQL

## Run Validation Script

```bash
cd ../validate
./check-all.sh
```

## Complete!

You've successfully:
1. Created Application Insights
2. Connected Azure Functions
3. Connected API Management
4. Generated test traffic
5. Explored monitoring features

## Next Steps

- Complete the [Challenge](../challenge.md) for custom telemetry and alerts
- Review all exercises in the CloudShop pipeline!

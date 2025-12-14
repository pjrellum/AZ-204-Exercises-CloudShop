# Challenge 05: Custom Telemetry & Alerts

## Scenario

Operations wants to:
1. Track **order processing duration** as a custom metric
2. Get **alerted when processing is slow** (>5 seconds)
3. See a **dashboard** with business metrics

## Requirements

1. Add custom telemetry to track order processing time
2. Create an alert rule for slow processing
3. Build a workbook/dashboard with key metrics

## Part 1: Add Custom Telemetry

Add the TelemetryClient to your order processor:

```csharp
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using System.Diagnostics;

public class OrderProcessor
{
    private readonly TelemetryClient _telemetry;

    public OrderProcessor(TelemetryConfiguration config)
    {
        _telemetry = new TelemetryClient(config);
    }

    public async Task ProcessOrder(Order order)
    {
        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Process the order...
            await ValidateOrder(order);
            await CheckInventory(order);
            await ProcessPayment(order);

            stopwatch.Stop();

            // Track custom metric
            _telemetry.TrackMetric("OrderProcessingTime", stopwatch.ElapsedMilliseconds);

            // Track custom event with properties
            _telemetry.TrackEvent("OrderProcessed", new Dictionary<string, string>
            {
                ["orderId"] = order.Id,
                ["customer"] = order.Customer,
                ["itemCount"] = order.Items.Count.ToString()
            }, new Dictionary<string, double>
            {
                ["total"] = order.Total,
                ["processingTimeMs"] = stopwatch.ElapsedMilliseconds
            });
        }
        catch (Exception ex)
        {
            stopwatch.Stop();

            // Track failure
            _telemetry.TrackException(ex, new Dictionary<string, string>
            {
                ["orderId"] = order.Id,
                ["stage"] = "processing"
            });

            throw;
        }
    }
}
```

## Part 2: Create Alert Rule

Create an alert for slow order processing:

```bash
# Create action group (email notification)
az monitor action-group create \
  --name ag-cloudshop-ops \
  --resource-group $RESOURCE_GROUP \
  --short-name CloudShopOps \
  --action email ops-email ops@cloudshop.example.com

# Create metric alert
az monitor metrics alert create \
  --name "Slow Order Processing" \
  --resource-group $RESOURCE_GROUP \
  --scopes $(az monitor app-insights component show \
    --app ai-cloudshop-$UNIQUE_SUFFIX \
    --resource-group $RESOURCE_GROUP \
    --query id -o tsv) \
  --condition "avg customMetrics/OrderProcessingTime > 5000" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action ag-cloudshop-ops \
  --description "Order processing is taking longer than 5 seconds"
```

## Part 3: Query Custom Metrics

Use Kusto queries to analyze your custom telemetry:

```kusto
// Average processing time per hour
customMetrics
| where name == "OrderProcessingTime"
| summarize avg(value) by bin(timestamp, 1h)
| render timechart

// Orders processed per customer
customEvents
| where name == "OrderProcessed"
| summarize count() by tostring(customDimensions.customer)
| render piechart

// Slow orders (>3 seconds)
customEvents
| where name == "OrderProcessed"
| where todouble(customMeasurements.processingTimeMs) > 3000
| project timestamp, orderId=customDimensions.orderId,
          processingTime=customMeasurements.processingTimeMs
| order by processingTime desc
```

## Part 4: Create Workbook

Create a workbook with business metrics:

1. Azure Portal → Application Insights → Workbooks
2. Create new workbook
3. Add these visualizations:

**Orders per Hour:**
```kusto
customEvents
| where name == "OrderProcessed"
| summarize Orders=count() by bin(timestamp, 1h)
| render timechart
```

**Average Order Value:**
```kusto
customEvents
| where name == "OrderProcessed"
| summarize AvgValue=avg(todouble(customMeasurements.total)) by bin(timestamp, 1h)
| render timechart
```

**Processing Time Distribution:**
```kusto
customEvents
| where name == "OrderProcessed"
| summarize count() by bin(todouble(customMeasurements.processingTimeMs), 500)
| render columnchart
```

**Top Customers:**
```kusto
customEvents
| where name == "OrderProcessed"
| summarize TotalSpent=sum(todouble(customMeasurements.total)),
            OrderCount=count()
    by Customer=tostring(customDimensions.customer)
| top 10 by TotalSpent
| render table
```

## Validation

- [ ] Custom metric `OrderProcessingTime` appears in App Insights
- [ ] Custom event `OrderProcessed` appears with properties
- [ ] Alert rule is created and active
- [ ] Workbook displays business metrics

## Telemetry Types

| Type | Use Case | Example |
|------|----------|---------|
| `TrackMetric` | Numeric measurements | Response time, queue depth |
| `TrackEvent` | Business events | Order placed, user signup |
| `TrackException` | Error logging | Processing failures |
| `TrackTrace` | Diagnostic logs | Debug information |
| `TrackDependency` | External calls | Database, API calls |

## Solution

See [solution/challenge-solution.md](solution/challenge-solution.md) for complete implementation.

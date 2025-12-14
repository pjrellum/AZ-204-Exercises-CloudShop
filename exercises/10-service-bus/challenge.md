# Challenge 04: Topics with Multiple Subscribers

## Scenario

Order events need to reach multiple services:
- **Inventory Service** - checks stock for all orders
- **Shipping Service** - only cares about orders > $100

Implement this using a Service Bus **Topic** with filtered **Subscriptions**.

## Requirements

1. Create a topic for order events
2. Create subscription for Inventory (receives all)
3. Create subscription for Shipping (filter: total > 100)
4. Test that filtering works correctly

## Part 1: Create Topic and Subscriptions

```bash
# Create topic
az servicebus topic create \
  --name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP

# Subscription for inventory (receives all orders)
az servicebus topic subscription create \
  --name inventory-sub \
  --topic-name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP

# Subscription for shipping (only high-value orders)
az servicebus topic subscription create \
  --name shipping-sub \
  --topic-name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP
```

## Part 2: Add Filter to Shipping Subscription

```bash
# Remove default "match all" rule
az servicebus topic subscription rule delete \
  --name '$Default' \
  --subscription-name shipping-sub \
  --topic-name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP

# Add filter for high-value orders
az servicebus topic subscription rule create \
  --name high-value-orders \
  --subscription-name shipping-sub \
  --topic-name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP \
  --filter-sql-expression "total > 100"
```

## Part 3: Send Test Messages

Send messages with different totals:

```csharp
var sender = client.CreateSender("order-events");

// Low-value order (only inventory receives)
var lowValue = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(
    new { orderId = "ORD-LOW", total = 50.00 }
));
lowValue.ApplicationProperties["total"] = 50.00;
await sender.SendMessageAsync(lowValue);

// High-value order (both receive)
var highValue = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(
    new { orderId = "ORD-HIGH", total = 150.00 }
));
highValue.ApplicationProperties["total"] = 150.00;
await sender.SendMessageAsync(highValue);
```

> **Important:** SQL filters work on **ApplicationProperties**, not message body!

## Part 4: Verify Message Distribution

Check message counts in each subscription:

```bash
# Inventory should have 2 messages
az servicebus topic subscription show \
  --name inventory-sub \
  --topic-name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP \
  --query "countDetails.activeMessageCount"

# Shipping should have 1 message (only high-value)
az servicebus topic subscription show \
  --name shipping-sub \
  --topic-name order-events \
  --namespace-name sb-cloudshop-$UNIQUE_SUFFIX \
  --resource-group $RESOURCE_GROUP \
  --query "countDetails.activeMessageCount"
```

## Architecture Result

```
                          ┌─────────────────┐
                          │  Topic:         │
                          │  order-events   │
                          └────────┬────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    ▼                             ▼
           ┌───────────────┐            ┌───────────────┐
           │ inventory-sub │            │ shipping-sub  │
           │ (all orders)  │            │ (total > 100) │
           └───────────────┘            └───────────────┘
                    │                             │
                    ▼                             ▼
           ┌───────────────┐            ┌───────────────┐
           │   Inventory   │            │   Shipping    │
           │    Service    │            │    Service    │
           └───────────────┘            └───────────────┘
```

## Validation

- [ ] Topic created successfully
- [ ] Two subscriptions exist
- [ ] Shipping subscription has SQL filter
- [ ] Low-value orders only reach inventory
- [ ] High-value orders reach both services

## Filter Types

| Type | Use Case | Example |
|------|----------|---------|
| SQL Filter | Property-based | `total > 100 AND region = 'US'` |
| Correlation Filter | Header matching | Match `Subject` or custom properties |
| True Filter | Match all | Default behavior |
| False Filter | Match none | Disable subscription temporarily |

## Solution

See [solution/challenge-solution.md](solution/challenge-solution.md) for complete implementation.

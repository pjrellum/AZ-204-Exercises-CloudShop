# Challenge: Order Notifications with Topics

## Scenario

After CloudShop processes an order, multiple services need to be notified:
- **Email Service** - sends confirmation to all customers
- **Shipping Service** - only needs orders over $50

This is a classic **pub/sub** pattern - one publisher, multiple subscribers with different filters.

## Learning Objectives

- Create Service Bus Topics and Subscriptions
- Apply SQL filters to subscriptions (exam topic)
- Understand the difference between Queues and Topics

## Prerequisites

Complete the main exercise first - you need a working Service Bus namespace.

## Architecture

```
                     ┌──────────────────┐
                     │  order-events    │
                     │     (Topic)      │
                     └────────┬─────────┘
                              │
           ┌──────────────────┴──────────────────┐
           ▼                                     ▼
  ┌─────────────────┐                  ┌─────────────────┐
  │   email-sub     │                  │  shipping-sub   │
  │  (all orders)   │                  │ (total > 50)    │
  └─────────────────┘                  └─────────────────┘
           │                                     │
           ▼                                     ▼
  ┌─────────────────┐                  ┌─────────────────┐
  │  Email Service  │                  │Shipping Service │
  └─────────────────┘                  └─────────────────┘
```

## Part 1: Create Topic and Subscriptions

### Step 1: Create the Topic

```bash
az servicebus topic create \
    --name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP
```

### Step 2: Create Email Subscription (receives all)

```bash
az servicebus topic subscription create \
    --name email-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP
```

### Step 3: Create Shipping Subscription (filtered)

```bash
# Create subscription
az servicebus topic subscription create \
    --name shipping-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP

# Remove the default "match all" rule
az servicebus topic subscription rule delete \
    --name '$Default' \
    --subscription-name shipping-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP

# Add filter for high-value orders only
az servicebus topic subscription rule create \
    --name high-value-only \
    --subscription-name shipping-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --filter-sql-expression "total > 50"
```

## Part 2: Send Test Messages

Messages must have the filter property in **ApplicationProperties** (not body).

1. Go to Service Bus namespace > Topics > order-events
2. Click "Service Bus Explorer"
3. Send messages with custom properties:

**Low-value order:**
- Body: `{"orderId": "ORD-001", "customer": "Alice"}`
- Custom Property: `total` = `25`

**High-value order:**
- Body: `{"orderId": "ORD-002", "customer": "Bob"}`
- Custom Property: `total` = `150`

## Part 3: Verify Message Distribution

Check how messages were distributed:

```bash
# Email subscription should have 2 messages (all orders)
az servicebus topic subscription show \
    --name email-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "countDetails.activeMessageCount"

# Shipping subscription should have 1 message (only high-value)
az servicebus topic subscription show \
    --name shipping-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "countDetails.activeMessageCount"
```

**Expected:**
- Email: 2 messages
- Shipping: 1 message (only the $150 order)

## Part 4: View the Filter

```bash
# Show the filter rule
az servicebus topic subscription rule show \
    --name high-value-only \
    --subscription-name shipping-sub \
    --topic-name order-events \
    --namespace-name $SERVICEBUS_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "sqlFilter"
```

## Validation Checklist

- [ ] Topic `order-events` exists
- [ ] Subscription `email-sub` receives all messages
- [ ] Subscription `shipping-sub` has SQL filter `total > 50`
- [ ] Low-value orders only reach email subscription
- [ ] High-value orders reach both subscriptions

## Queue vs Topic

| Feature | Queue | Topic |
|---------|-------|-------|
| Consumers | One | Multiple (subscriptions) |
| Message fate | Consumed once | Copied to each subscription |
| Filtering | No | Yes (per subscription) |
| Use case | Work distribution | Pub/sub, notifications |

## SQL Filter Syntax

```sql
-- Numeric comparison
total > 100

-- String matching
region = 'EU'

-- Logical operators
total > 100 AND priority = 'high'

-- IN clause
category IN ('electronics', 'books')

-- LIKE pattern
customer LIKE 'VIP-%'
```

## Common Exam Topics

- Filters work on **ApplicationProperties**, not message body
- Default rule `$Default` matches all - delete it before adding filters
- Each subscription gets its own copy of the message
- Correlation filters are faster than SQL filters for simple matching
- Messages have a 256 KB limit (1 MB for Premium)

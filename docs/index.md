# CloudShop Order Pipeline

A hands-on workshop for **AZ-204 Day 4** covering API Management, Events, Messaging, and Monitoring.

## The Story

**CloudShop** is a growing e-commerce company. They need to modernize their order processing system to handle:

- **Partner integrations** - External systems submitting orders via API
- **Batch uploads** - Large order files dropped into storage
- **Reliable processing** - Orders must never be lost
- **Observability** - Application monitoring with Application Insights

You'll build this system piece by piece, learning Azure's integration services along the way.

## Architecture

![CloudShop Pipeline](images/cloudshop-overview-azure.drawio.png)

## Exercises

### [Exercise 08: API Management]({{ exercises_url }}/08-api-management)

**Secure API gateway with rate limiting**

Create the entry point for CloudShop's partner integrations. Set up an API Management instance to authenticate partners, apply rate limiting, and forward requests to the Orders API.

| Services | Skills |
|----------|--------|
| APIM, Functions | Policies, subscriptions, OpenAPI |

---

### [Exercise 09: Event Grid]({{ exercises_url }}/09-event-grid)

**React to blob uploads automatically**

Configure Event Grid to detect when order files are uploaded to blob storage and trigger processing. Enable the batch upload workflow with filtering and dead-letter handling.

| Services | Skills |
|----------|--------|
| Event Grid, Storage, Functions | Subscriptions, filters, webhooks |

---

### [Exercise 10: Service Bus]({{ exercises_url }}/10-service-bus)

**Reliable message processing**

Set up Service Bus for guaranteed order delivery. Implement queues with dead-lettering, and explore topics with filtered subscriptions for multi-service delivery.

| Services | Skills |
|----------|--------|
| Service Bus | Queues, topics, subscriptions, DLQ |

---

### [Exercise 11: Application Insights]({{ exercises_url }}/11-app-insights)

**Application monitoring**

Connect Application Insights to monitor the Function App and API Management. View distributed traces and explore the Application Map.

| Services | Skills |
|----------|--------|
| Application Insights | Telemetry, tracing, KQL queries |

---

## Recommended Order

1. **Start with 08** - Creates the base infrastructure (storage, functions, APIM)
2. **Then 09** - Adds Event Grid on top of existing storage
3. **Then 10** - Service Bus for reliable order processing
4. **Finish with 11** - Add Application Insights monitoring

Each exercise can also be done independently using the quickstart scripts.

## Catching Up

If you fall behind or want to skip ahead:

```bash
cd exercises/09-event-grid
./quickstart/deploy-all.sh
```

This deploys all prerequisites so you can explore the working system.

## Next Steps

- [Getting Started](getting-started.md) - Prerequisites and setup

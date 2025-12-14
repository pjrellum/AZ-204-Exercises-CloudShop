# Exercises

The CloudShop workshop consists of five exercises that build upon each other, creating a complete order processing pipeline.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CLOUDSHOP ORDER PIPELINE                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Partners ──▶ [APIM Gateway] ──▶ Orders API ──┐                           │
│                   (Ex 08)          (Function)   │                           │
│                                                 ▼                           │
│   Batch    ──▶ [Blob Storage] ──▶ [Event Grid] ──▶ [Service Bus] ──▶ Workers│
│   Upload          orders/           (Ex 09a)        (Ex 10)                 │
│                                                                             │
│   Website  ──▶ [Event Hubs] ──▶ Capture                                    │
│   (clicks)      (Ex 09b)        (archive)                                   │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │              Application Insights (Ex 11) - monitors all            │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Exercise List

### [Exercise 08: API Management]({{ exercises_url }}/08-api-management)

**Secure API gateway with rate limiting**

Create the entry point for CloudShop's partner integrations. You'll set up an API Management instance to authenticate partners, apply rate limiting, and forward requests to the Orders API.

| Duration | Services | Skills |
|----------|----------|--------|
| 30-45 min | APIM, Functions | Policies, subscriptions, OpenAPI |

---

### [Exercise 09a: Event Grid]({{ exercises_url }}/09a-event-grid)

**React to blob uploads automatically**

Configure Event Grid to detect when order files are uploaded to blob storage and trigger processing. Enable the batch upload workflow with filtering and dead-letter handling.

| Duration | Services | Skills |
|----------|----------|--------|
| 25-35 min | Event Grid, Storage, Functions | Subscriptions, filters, webhooks |

---

### [Exercise 09b: Event Hubs]({{ exercises_url }}/09b-event-hubs)

**Stream analytics with capture**

Create an Event Hubs namespace to stream website clickstream data for real-time analytics. Implement producers, consumers with checkpointing, and enable Capture for archiving.

| Duration | Services | Skills |
|----------|----------|--------|
| 30-40 min | Event Hubs, Storage | Partitions, consumer groups, Capture |

---

### [Exercise 10: Service Bus]({{ exercises_url }}/10-service-bus)

**Reliable message processing**

Set up Service Bus for guaranteed order delivery to worker services. Implement queues with dead-lettering, and explore topics with filtered subscriptions for multi-service delivery.

| Duration | Services | Skills |
|----------|----------|--------|
| 30-40 min | Service Bus | Queues, topics, subscriptions, DLQ |

---

### [Exercise 11: Application Insights]({{ exercises_url }}/11-app-insights)

**End-to-end monitoring**

Connect Application Insights to monitor the entire CloudShop pipeline. View distributed traces, set up availability tests, and explore the Application Map.

| Duration | Services | Skills |
|----------|----------|--------|
| 25-35 min | Application Insights | Telemetry, tracing, KQL queries |

---

## Time Summary

| Exercise | Core Lab | Challenge | Total |
|----------|----------|-----------|-------|
| 08 - API Management | 30 min | 15 min | 45 min |
| 09a - Event Grid | 25 min | 15 min | 40 min |
| 09b - Event Hubs | 30 min | 20 min | 50 min |
| 10 - Service Bus | 30 min | 20 min | 50 min |
| 11 - App Insights | 25 min | 20 min | 45 min |
| **Total** | **2h 20m** | **1h 30m** | **~4 hours** |

## Recommended Order

The exercises are designed to be completed in sequence:

1. **Start with 08** - Creates the base infrastructure (storage, functions)
2. **Then 09a** - Adds Event Grid on top of existing storage
3. **Then 09b** - Separate Event Hubs namespace for analytics
4. **Then 10** - Service Bus for reliable order processing
5. **Finish with 11** - Connect everything to monitoring

However, each exercise can also be done independently if you use the quickstart scripts to deploy prerequisites.

## Catching Up

If you fall behind or want to skip ahead:

```bash
# Each exercise has a quickstart script
cd exercises/09a-event-grid
./quickstart/deploy-all.sh
```

This deploys all prerequisites and the exercise infrastructure so you can explore the working system.

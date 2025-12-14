# CloudShop Exercises

Hands-on labs for AZ-204 Day 4: API Management, Events, Messaging & Monitoring.

## Quick Start

```bash
# Start with API Management
cd 08-api-management
cat README.md
```

## Exercises

| # | Exercise | Service | Duration |
|---|----------|---------|----------|
| 08 | [API Management](08-api-management/) | APIM | 30-45 min |
| 09a | [Event Grid](09a-event-grid/) | Event Grid | 25-35 min |
| 09b | [Event Hubs](09b-event-hubs/) | Event Hubs | 30-40 min |
| 10 | [Service Bus](10-service-bus/) | Service Bus | 30-40 min |
| 11 | [Application Insights](11-app-insights/) | App Insights | 25-35 min |

## Architecture

All exercises build the CloudShop order processing pipeline:

```
Partners ──► [APIM] ──► Orders API ──┐
               08        (Function)   │
                                      ▼
Batch    ──► [Blob] ──► [Event Grid] ──► [Service Bus] ──► Workers
Upload        orders        09a              10

Website  ──► [Event Hubs] ──► Capture
(clicks)        09b          (archive)

└─────────── Application Insights (11) ───────────┘
```

## Exercise Structure

Each exercise follows this pattern:

```
exercises/08-api-management/
├── README.md           # Start here - overview
├── instructions/       # Step-by-step tasks
├── infrastructure/     # Azure CLI & Bicep scripts
│   ├── azure-cli/
│   │   ├── starter/    # Commands with TODOs
│   │   └── complete/   # Ready-to-run
│   └── bicep/
├── code/               # Function code
│   └── dotnet/
├── validate/           # Verification scripts
├── test/               # Test tools
└── quickstart/         # One-click deployment
```

## Falling Behind?

Each exercise has a quickstart script:

```bash
cd 09a-event-grid
./quickstart/deploy-all.sh
```

## Documentation

Full documentation: https://pjrellum.github.io/az-204-exercises-cloudshop/

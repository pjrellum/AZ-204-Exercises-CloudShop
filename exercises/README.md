# CloudShop Exercises

Hands-on labs for AZ-204 Day 4: API Management, Events, Messaging & Monitoring.

## Quick Start

```bash
# Start with API Management
cd 08-api-management
cat README.md
```

## Exercises

| # | Exercise | Service |
|---|----------|---------|
| 08 | [API Management](08-api-management/) | APIM |
| 09 | [Event Grid](09-event-grid/) | Event Grid |
| 10 | [Service Bus](10-service-bus/) | Service Bus |
| 11 | [Application Insights](11-app-insights/) | App Insights |

## Architecture

All exercises build the CloudShop order processing pipeline:

```
Partners ──► [APIM] ──► Orders API ──┐
               08        (Function)   │
                                      ▼
Batch    ──► [Blob] ──► [Event Grid] ──► [Service Bus] ──► Workers
Upload        orders        09               10

└─────────── Application Insights (11) ───────────┘
```

## Exercise Structure

Each exercise follows this pattern:

```
exercises/08-api-management/
├── code/               # Function code (ready to deploy)
│   └── dotnet/
├── infrastructure/     # Azure CLI & Bicep scripts
│   ├── azure-cli/
│   │   ├── solution/   # Ready-to-run
│   │   └── guided/     # Fill-in-the-blanks learning
│   └── bicep/
│       └── solution/
├── quickstart/         # One-click deployment
├── test/               # Test tools
├── validate/           # Validation scripts
├── env.example.sh      # Environment template
└── README.md           # Start here - step-by-step guide
```

## Workflow Options

**Learning Mode** (recommended)

1. Follow the Step-by-Step Guide in each README
2. Use `infrastructure/azure-cli/guided/` for hands-on practice
3. Check `solution/` folders when stuck

**Quick Mode**

1. Run `infrastructure/*/solution/` scripts
2. Deploy function code with `code/dotnet/deploy.sh`

**Demo Mode**

1. Run `./quickstart/deploy-all.sh`
2. Explore the working system

## Falling Behind?

Each exercise has a quickstart script:

```bash
cd 09-event-grid  # or 10-service-bus, etc.
./quickstart/deploy-all.sh
```

## Documentation

Full documentation: https://pjrellum.github.io/az-204-exercises-cloudshop/

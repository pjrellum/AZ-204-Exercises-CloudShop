# CloudShop Order Pipeline

[![AZ-204](https://img.shields.io/badge/Azure-AZ--204-0078d4)](https://learn.microsoft.com/en-us/certifications/exams/az-204)
[![Day 4](https://img.shields.io/badge/Day-4-green)](docs/index.md)

Hands-on exercises for **AZ-204 Day 4** - building an e-commerce order processing pipeline with Azure's messaging and integration services.

## The Story

**CloudShop** is modernizing their order processing to handle:
- Partner API integrations
- Batch file uploads
- Real-time website analytics
- Reliable order processing

You'll build this system step-by-step, learning Azure services along the way.

## Architecture

```
┌──────────┐      ┌─────────────┐      ┌───────────────┐
│ Partners │─────▶│    APIM     │─────▶│  Orders API   │
└──────────┘      │  (Mod 08)   │      │   (Function)  │
                  └─────────────┘      └───────┬───────┘
                                               │
┌──────────┐      ┌─────────────┐              ▼
│  Batch   │─────▶│    Blob     │──▶ Event Grid (Mod 09)
│  Upload  │      │   Storage   │              │
└──────────┘      └─────────────┘              ▼
                                       Service Bus (Mod 10)
┌──────────┐      ┌─────────────┐              │
│ Website  │─────▶│ Event Hubs  │              ▼
│ (clicks) │      │  (Mod 09)   │       Worker Services
└──────────┘      └─────────────┘

              ┌─────────────────────────────────┐
              │   Application Insights (Mod 11) │
              └─────────────────────────────────┘
```

## Exercises

| Folder | Module | Topic | Time |
|--------|--------|-------|------|
| [08-api-management](exercises/08-api-management/) | 08 | API Management Gateway | 45 min |
| [09a-event-grid](exercises/09a-event-grid/) | 09 | Event Grid | 40 min |
| [09b-event-hubs](exercises/09b-event-hubs/) | 09 | Event Hubs | 50 min |
| [10-service-bus](exercises/10-service-bus/) | 10 | Service Bus | 50 min |
| [11-app-insights](exercises/11-app-insights/) | 11 | Application Insights | 45 min |

**Total:** ~4 hours (including challenges)

## Quick Start

```bash
# Clone and navigate
git clone https://github.com/pjrellum/az-204-exercises-cloudshop.git
cd az-204-exercises-cloudshop

# Login to Azure
az login

# Start with Module 08
cd exercises/08-api-management
cat README.md
```

## Exercise Structure

Each exercise offers **choices** - pick your preferred approach:

```
exercises/08-api-management/
├── README.md              # Start here - overview
├── instructions/          # WHAT to build (with hints)
├── infrastructure/
│   ├── azure-cli/        # Option A: CLI commands
│   └── bicep/            # Option B: Infrastructure as Code
├── code/
│   └── dotnet/           # .NET implementation
├── validate/             # Check your work
└── quickstart/           # One-click deploy
```

**In each folder:**
- `starter/` = Templates with TODOs (for learning)
- `complete/` = Full solutions (for reference)

## Prerequisites

- Azure subscription ([free trial](https://azure.microsoft.com/free/))
- [Pre-configured Codespace](https://codespaces.new/pjrellum/AZ-204-codespace) (recommended), or install locally:
  - Azure CLI 2.50+
  - .NET 8 SDK
  - VS Code with Azure extensions

## Documentation

- [Getting Started](docs/getting-started.md) - Setup instructions
- [Architecture](docs/architecture.md) - Design decisions
- [Troubleshooting](docs/troubleshooting.md) - Common issues

## Cleanup

```bash
./scripts/cleanup.sh
```

Estimated cost: ~$5-10 (using Consumption tiers)

## License

MIT - See [LICENSE](LICENSE)

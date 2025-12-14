# Event Grid Infrastructure

Deploy the infrastructure for the Event Grid exercise.

## Options

| Approach | Description | Folder |
|----------|-------------|--------|
| **Azure CLI** | Imperative commands, great for learning | [azure-cli/](azure-cli/) |
| **Bicep** | Infrastructure as Code, declarative | [bicep/](bicep/) |

## Which Should I Choose?

### Azure CLI
- (+) Quick to run and iterate
- (+) Easy to understand what's happening
- (+) Good for learning Azure commands
- (-) Harder to reproduce consistently

### Bicep
- (+) Declarative and repeatable
- (+) Version control friendly
- (+) Supports what-if deployments
- (-) Slightly more setup required

## Folder Structure

```
infrastructure/
├── azure-cli/
│   ├── starter/          # Scripts with TODOs
│   │   └── deploy.sh
│   └── complete/         # Working scripts
│       └── deploy.sh
└── bicep/
    ├── starter/          # Templates with TODOs
    │   └── main.bicep
    └── complete/         # Working templates
        ├── main.bicep
        └── deploy.sh
```

## Prerequisites

Ensure your environment is configured:

```bash
source ../env.sh  # Load environment variables
```

## Resources Created

- Storage Account (`stcloudshop{suffix}`)
  - `orders/` container
  - `deadletter/` container
- Function App (`func-cloudshop-processor-{suffix}`)
- Event Grid System Topic
- Event Grid Subscription

# Infrastructure

Choose your approach for provisioning Azure resources:

| Approach | Description | Folder |
|----------|-------------|--------|
| **Azure CLI** | Imperative commands, great for learning | [azure-cli/](azure-cli/) |
| **Bicep** | Infrastructure as Code, declarative, repeatable | [bicep/](bicep/) |

## Which Should I Choose?

### Azure CLI
- (+) Quick to run and iterate
- (+) Easy to understand what's happening
- (+) Good for learning Azure commands
- (-) Harder to reproduce consistently
- (-) No state management

### Bicep
- (+) Declarative and repeatable
- (+) Version control friendly
- (+) Supports what-if deployments
- (+) Better for production scenarios
- (-) Slightly more setup required
- (-) Need to understand IaC concepts

## Folder Structure

```
infrastructure/
├── azure-cli/
│   ├── solution/         # Ready-to-run scripts
│   │   └── deploy.sh     # Full solution
│   └── guided/          # Scripts with placeholders
│       └── deploy.sh     # Fill in the TODOs
└── bicep/
    ├── solution/         # Full templates
    │   ├── main.bicep
    │   └── main.parameters.json
    └── guided/          # Templates with TODOs
        ├── main.bicep
        └── main.parameters.json
```

## Prerequisites

Ensure your environment is configured:

```bash
source ../env.sh
```

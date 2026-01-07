# Getting Started

## Prerequisites

### Azure Subscription

You need an Azure subscription with permissions to create resources (resource groups, storage, functions, messaging services).

> A [free Azure account](https://azure.microsoft.com/free/) includes $200 credit - more than enough for these exercises.

### Development Environment

**Recommended:** Use GitHub Codespaces - no local installation required:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/pjrellum/AZ-204-codespace)

Includes: .NET 8, Azure CLI, Bicep, Azure Functions Core Tools, and VS Code extensions.

**Alternative:** Run locally with Docker/Podman using the [Dev Container](https://github.com/pjrellum/AZ-204-codespace), or install tools manually (.NET 8, Azure CLI, Azure Functions Core Tools).

## Quick Start

```bash
# Clone and navigate
git clone {{ repo_url }}.git
cd {{ github_repo }}

# Login to Azure
az login

# Start with the first exercise
cd exercises/08-api-management
cat README.md
```

Each exercise folder contains its own README with detailed instructions.

## Next Steps

- [Back to Home](index.md) - See all exercises

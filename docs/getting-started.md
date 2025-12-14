# Getting Started

This guide walks you through setting up your environment for the CloudShop exercises.

## Prerequisites

### Azure Subscription

You need an Azure subscription with permissions to create:

- Resource groups
- API Management (Consumption tier)
- Storage accounts
- Function Apps
- Event Grid subscriptions
- Event Hubs namespace
- Service Bus namespace
- Application Insights

> A [free Azure account](https://azure.microsoft.com/free/) includes $200 credit - more than enough for these exercises.

### Development Tools

**Option 1: GitHub Codespaces (Recommended)**

The fastest way to get started - no local installation required:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/pjrellum/AZ-204-codespace)

This includes:

| Category | What's Included |
|----------|-----------------|
| **Runtime** | .NET 8.0 SDK |
| **Azure Tools** | Azure CLI, Bicep, Azure Functions Core Tools |
| **VS Code Extensions** | C#, Azure Functions, Azure Storage, Azure Resources, REST Client |

After the codespace starts, run `az login` to authenticate with Azure.

**Option 2: Local Dev Container**

Run the same pre-configured environment locally using Docker or Podman:

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop) or [Podman](https://podman.io/)
2. Install VS Code with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Clone [pjrellum/AZ-204-codespace](https://github.com/pjrellum/AZ-204-codespace)
4. Open in VS Code and click **Reopen in Container** when prompted

> **Enterprise users:** Podman is a free alternative to Docker Desktop that doesn't require a commercial license.

This gives you the same environment as Option 1, but running locally.

**Option 3: Install Tools Locally**

| Tool | Required | Installation |
|------|----------|--------------|
| Azure CLI | 2.50+ | [Install guide](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| Azure Functions Core Tools | 4.x | [Install guide](https://docs.microsoft.com/azure/azure-functions/functions-run-local) |
| VS Code | Latest | [Download](https://code.visualstudio.com/) |
| Git | 2.30+ | [Download](https://git-scm.com/) |

**Plus:**

| Runtime | Version | Installation |
|---------|---------|--------------|
| .NET SDK | 8.0+ | [Download](https://dotnet.microsoft.com/download) |

## Setup

### 1. Clone the Repository

```bash
git clone {{ repo_url }}.git
cd {{ github_repo }}
```

### 2. Login to Azure

```bash
az login
az account show  # Verify correct subscription
```

### 3. Navigate to First Exercise

```bash
cd exercises/08-api-management
```

## Exercise Folder Structure

Each exercise follows this pattern:

```
exercises/08-api-management/
├── README.md                 # Start here - overview and decision guide
├── env.example.sh            # Environment template (copy to env.sh)
│
├── instructions/             # WHAT to build (step-by-step)
│   ├── README.md             # Task overview
│   ├── 01-storage-account.md
│   ├── 02-function-app.md
│   └── ...
│
├── infrastructure/           # HOW to provision (choose your path)
│   ├── azure-cli/
│   │   ├── starter/          # Commands with TODOs
│   │   └── complete/         # Ready-to-run scripts
│   └── bicep/
│       ├── starter/          # Templates with TODOs
│       └── complete/         # Full IaC
│
├── code/                     # Function code
│   └── dotnet/
│       ├── starter/          # Skeleton with TODOs
│       └── complete/         # Working solution
│
├── deploy/                   # Deployment scripts
├── validate/                 # Verification scripts
├── test/                     # Test tools and sample data
└── quickstart/               # One-click deployment (demos/catch-up)
```

## How to Use an Exercise

### Step 1: Configure Environment

```bash
cd exercises/08-api-management

# Copy and edit the environment file
cp env.example.sh env.sh
# Edit env.sh - set your UNIQUE_SUFFIX (e.g., your initials + random: "pm42")
```

### Step 2: Follow Instructions

Open `instructions/README.md` and work through each task. The instructions tell you **what** to build.

When you need help with **how**:
1. Expand the hints in each instruction file
2. Check the `starter/` folders for templates
3. Check the `complete/` folders for full solutions

### Step 3: Choose Your Path

**Infrastructure:** Azure CLI or Bicep
**Code:** .NET

### Step 4: Validate

```bash
./validate/check-all.sh
```

### Falling Behind?

Use quickstart to catch up:

```bash
./quickstart/deploy-all.sh
```

## Workflow Options

### Option A: Learning Mode (Recommended)

1. Read the instructions
2. Try to implement yourself
3. Use hints when stuck
4. Check solutions only if needed

### Option B: Follow Along Mode

1. Read the instructions
2. Copy from `complete/` folders
3. Understand what each step does

### Option C: Demo Mode

1. Run `./quickstart/deploy-all.sh`
2. Explore the working system
3. Review the code afterward

## Next Steps

Ready to start? After cloning the repo:

```bash
cd exercises
cat README.md
```

Or browse on GitHub: [exercises/]({{ exercises_url }})

// =============================================================================
// CloudShop Exercise 08 - API Management (Bicep)
// =============================================================================
// STARTER TEMPLATE - Fill in the TODOs
// =============================================================================

// Parameters
param location string = resourceGroup().location
param uniqueSuffix string

// TODO: Add parameters for:
// - functionRuntime (string, default: 'dotnet-isolated')
// - functionRuntimeVersion (string, default: '8')

// Derived names
var storageAccountName = 'stcloudshop${uniqueSuffix}'
var functionAppName = 'func-cloudshop-orders-${uniqueSuffix}'
var apimName = 'apim-cloudshop-${uniqueSuffix}'

// =============================================================================
// Storage Account
// =============================================================================
// TODO: Create a storage account resource
// Type: Microsoft.Storage/storageAccounts@2023-01-01
// Properties needed:
//   - name: storageAccountName
//   - location: location
//   - sku: { name: 'Standard_LRS' }
//   - kind: 'StorageV2'


// =============================================================================
// App Service Plan (Consumption)
// =============================================================================
// TODO: Create an App Service Plan for the Function App
// Type: Microsoft.Web/serverfarms@2023-01-01
// Properties needed:
//   - name: 'plan-cloudshop-${uniqueSuffix}'
//   - location: location
//   - sku: { name: 'Y1', tier: 'Dynamic' }
//   - kind: 'functionapp'


// =============================================================================
// Function App
// =============================================================================
// TODO: Create a Function App resource
// Type: Microsoft.Web/sites@2023-01-01
// Properties needed:
//   - name: functionAppName
//   - location: location
//   - kind: 'functionapp'
//   - properties:
//       - serverFarmId: (reference to app service plan)
//       - siteConfig:
//           - appSettings: (storage connection, runtime settings)


// =============================================================================
// API Management
// =============================================================================
// TODO: Create an API Management resource
// Type: Microsoft.ApiManagement/service@2023-03-01-preview
// Properties needed:
//   - name: apimName
//   - location: location
//   - sku: { name: 'Consumption', capacity: 0 }
//   - properties:
//       - publisherEmail: 'admin@cloudshop.example.com'
//       - publisherName: 'CloudShop'


// =============================================================================
// Outputs
// =============================================================================
output storageAccountName string = storageAccountName
output functionAppName string = functionAppName
output apimName string = apimName
// TODO: Add output for Function URL
// TODO: Add output for APIM URL

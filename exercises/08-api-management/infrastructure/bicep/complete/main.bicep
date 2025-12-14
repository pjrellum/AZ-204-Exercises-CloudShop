// =============================================================================
// CloudShop Exercise 08 - API Management (Bicep)
// =============================================================================
// COMPLETE SOLUTION
// =============================================================================

// Parameters
param location string = resourceGroup().location
param uniqueSuffix string
param functionRuntime string = 'dotnet-isolated'
param functionRuntimeVersion string = '8'
param publisherEmail string = 'admin@cloudshop.example.com'
param publisherName string = 'CloudShop'

// Derived names
var storageAccountName = 'stcloudshop${uniqueSuffix}'
var functionAppName = 'func-cloudshop-orders-${uniqueSuffix}'
var hostingPlanName = 'plan-cloudshop-${uniqueSuffix}'
var apimName = 'apim-cloudshop-${uniqueSuffix}'

// =============================================================================
// Storage Account
// =============================================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// =============================================================================
// App Service Plan (Consumption)
// =============================================================================
resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  kind: 'functionapp'
  properties: {
    reserved: functionRuntime == 'python' // Linux required for Python
  }
}

// =============================================================================
// Function App
// =============================================================================
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  kind: functionRuntime == 'python' ? 'functionapp,linux' : 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
      ]
    }
  }
}

// =============================================================================
// API Management
// =============================================================================
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apimName
  location: location
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

// =============================================================================
// Outputs
// =============================================================================
output storageAccountName string = storageAccount.name
output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output apimName string = apim.name
output apimGatewayUrl string = apim.properties.gatewayUrl
output resourceGroupName string = resourceGroup().name

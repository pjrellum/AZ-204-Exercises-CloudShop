// =============================================================================
// CloudShop Exercise 10 - Service Bus (Bicep)
// =============================================================================
// Deploys Service Bus and configures Function App connection
// NOTE: Assumes Function App exists from Exercise 08
// =============================================================================

@description('Unique suffix for resource names')
param uniqueSuffix string

@description('Azure region for resources')
param location string = resourceGroup().location

// Derived names
var storageAccountName = 'stcloudshop${uniqueSuffix}'
var functionAppName = 'func-cloudshop-${uniqueSuffix}'
var serviceBusNamespaceName = 'sbns-cloudshop-${uniqueSuffix}'
var queueName = 'orders'

// =============================================================================
// Reference existing resources from Exercise 08
// =============================================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: functionAppName
}

// =============================================================================
// Service Bus Namespace
// =============================================================================
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

// =============================================================================
// Service Bus Queue
// =============================================================================
resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: queueName
  properties: {
    maxDeliveryCount: 3
    defaultMessageTimeToLive: 'P1D'  // 1 day
    lockDuration: 'PT1M'             // 1 minute
    deadLetteringOnMessageExpiration: true
  }
}

// =============================================================================
// Get Service Bus connection string
// =============================================================================
var serviceBusEndpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, serviceBusNamespace.apiVersion).primaryConnectionString

// =============================================================================
// Update Function App with Service Bus connection
// =============================================================================
resource functionAppSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
    WEBSITE_CONTENTSHARE: toLower(functionAppName)
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    ServiceBusConnection: serviceBusConnectionString
  }
}

// =============================================================================
// Outputs
// =============================================================================
output serviceBusNamespaceName string = serviceBusNamespace.name
output queueName string = serviceBusQueue.name
output serviceBusEndpoint string = serviceBusNamespace.properties.serviceBusEndpoint
output functionAppName string = functionApp.name

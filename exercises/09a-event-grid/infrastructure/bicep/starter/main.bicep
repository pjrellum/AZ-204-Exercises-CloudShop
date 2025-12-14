// Exercise 09a: Event Grid - Starter Bicep Template
// TODO: Fill in the missing properties

@description('Unique suffix for resource names')
param uniqueSuffix string

@description('Azure region for resources')
param location string = resourceGroup().location

// TODO 1: Create Storage Account
// Hint: Use Microsoft.Storage/storageAccounts@2023-01-01
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stcloudshop${uniqueSuffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    // TODO: Add properties for HTTPS-only, TLS 1.2, etc.
  }
}

// Blob Services
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// TODO 2: Create Orders Container
resource ordersContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'orders'
  properties: {
    // TODO: Set public access to None
  }
}

// TODO 3: Create App Service Plan (Consumption tier for Functions)
// Hint: Use Microsoft.Web/serverfarms with sku Y1
resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'plan-cloudshop-processor-${uniqueSuffix}'
  location: location
  sku: {
    // TODO: Use Y1 (Dynamic/Consumption) tier
    name: '???'
    tier: '???'
  }
  kind: 'functionapp'
  properties: {
    reserved: true // Linux
  }
}

// TODO 4: Create Function App
// Hint: Use Microsoft.Web/sites with kind 'functionapp,linux'
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'func-cloudshop-processor-${uniqueSuffix}'
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        // TODO: Add required app settings:
        // - AzureWebJobsStorage
        // - FUNCTIONS_EXTENSION_VERSION
        // - FUNCTIONS_WORKER_RUNTIME
      ]
    }
    httpsOnly: true
  }
}

// TODO 5: Create Event Grid System Topic
// Hint: Use Microsoft.EventGrid/systemTopics
// Set source to storage account, topicType to Microsoft.Storage.StorageAccounts
resource eventGridSystemTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: 'evgt-cloudshop-orders-${uniqueSuffix}'
  location: location
  properties: {
    source: storageAccount.id
    topicType: '???'
  }
}

// TODO 6: Create Event Grid Subscription
// Hint: Use Microsoft.EventGrid/systemTopics/eventSubscriptions
// - Filter to BlobCreated events
// - Filter subject to orders/*.json
resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = {
  parent: eventGridSystemTopic
  name: 'order-uploaded'
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: 'https://${functionApp.properties.defaultHostName}/api/OrderUploaded'
      }
    }
    filter: {
      includedEventTypes: [
        // TODO: Add correct event type
      ]
      // TODO: Add subject filters
    }
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output functionAppName string = functionApp.name

// =============================================================================
// CloudShop Exercise 09b - Event Hubs (Bicep)
// =============================================================================
// COMPLETE SOLUTION
// =============================================================================

@description('Unique suffix for resource names')
param uniqueSuffix string

@description('Azure region for resources')
param location string = resourceGroup().location

// Derived names
var storageAccountName = 'stcloudshop${uniqueSuffix}'
var eventHubNamespaceName = 'evhns-cloudshop-${uniqueSuffix}'
var eventHubName = 'clickstream'

// =============================================================================
// Storage Account (for checkpoints)
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

// Blob Services
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// Checkpoints Container
resource checkpointsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'checkpoints'
  properties: {
    publicAccess: 'None'
  }
}

// =============================================================================
// Event Hubs Namespace
// =============================================================================
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
  }
}

// =============================================================================
// Event Hub
// =============================================================================
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    partitionCount: 4
    messageRetentionInDays: 1
  }
}

// =============================================================================
// Outputs
// =============================================================================
output storageAccountName string = storageAccount.name
output eventHubNamespaceName string = eventHubNamespace.name
output eventHubName string = eventHub.name
output eventHubNamespaceEndpoint string = eventHubNamespace.properties.serviceBusEndpoint

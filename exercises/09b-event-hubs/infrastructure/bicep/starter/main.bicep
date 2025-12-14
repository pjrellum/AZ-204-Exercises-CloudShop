// =============================================================================
// CloudShop Exercise 09b - Event Hubs (Bicep)
// =============================================================================
// STARTER TEMPLATE - Fill in the TODOs
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
// TODO 1: Create a storage account for checkpoint storage
// Type: Microsoft.Storage/storageAccounts@2023-01-01
// Properties needed:
//   - name: storageAccountName
//   - location: location
//   - sku: { name: 'Standard_LRS' }
//   - kind: 'StorageV2'
//   - properties: supportsHttpsTrafficOnly, minimumTlsVersion


// TODO 2: Create blob services and checkpoints container
// Hint: Microsoft.Storage/storageAccounts/blobServices
// Hint: Microsoft.Storage/storageAccounts/blobServices/containers


// =============================================================================
// Event Hubs Namespace
// =============================================================================
// TODO 3: Create an Event Hubs namespace
// Type: Microsoft.EventHub/namespaces@2024-01-01
// Properties needed:
//   - name: eventHubNamespaceName
//   - location: location
//   - sku: { name: 'Standard', tier: 'Standard', capacity: 1 }


// =============================================================================
// Event Hub
// =============================================================================
// TODO 4: Create an Event Hub inside the namespace
// Type: Microsoft.EventHub/namespaces/eventhubs@2024-01-01
// Properties needed:
//   - parent: (reference to namespace)
//   - name: eventHubName
//   - properties: partitionCount: 4, messageRetentionInDays: 1


// =============================================================================
// Outputs
// =============================================================================
// TODO 5: Add outputs for:
// - storageAccountName
// - eventHubNamespaceName
// - eventHubName
output storageAccountName string = storageAccountName
output eventHubNamespaceName string = eventHubNamespaceName
output eventHubName string = eventHubName

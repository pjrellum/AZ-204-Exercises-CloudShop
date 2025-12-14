// =============================================================================
// CloudShop Exercise 10 - Service Bus (Bicep)
// =============================================================================
// COMPLETE SOLUTION
// =============================================================================

@description('Unique suffix for resource names')
param uniqueSuffix string

@description('Azure region for resources')
param location string = resourceGroup().location

// Derived names
var serviceBusNamespaceName = 'sbns-cloudshop-${uniqueSuffix}'
var queueName = 'order-processor'

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
// Outputs
// =============================================================================
output serviceBusNamespaceName string = serviceBusNamespace.name
output queueName string = serviceBusQueue.name
output serviceBusEndpoint string = serviceBusNamespace.properties.serviceBusEndpoint

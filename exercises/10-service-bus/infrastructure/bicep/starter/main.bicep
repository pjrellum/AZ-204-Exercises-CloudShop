// =============================================================================
// CloudShop Exercise 10 - Service Bus (Bicep)
// =============================================================================
// STARTER TEMPLATE - Fill in the TODOs
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
// TODO 1: Create a Service Bus namespace
// Type: Microsoft.ServiceBus/namespaces@2022-10-01-preview
// Properties needed:
//   - name: serviceBusNamespaceName
//   - location: location
//   - sku: { name: 'Standard', tier: 'Standard' }


// =============================================================================
// Service Bus Queue
// =============================================================================
// TODO 2: Create a Service Bus queue
// Type: Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview
// Properties needed:
//   - parent: (reference to namespace)
//   - name: queueName
//   - properties:
//       - maxDeliveryCount: 3
//       - defaultMessageTimeToLive: 'P1D' (1 day ISO 8601 format)
//       - lockDuration: 'PT1M' (1 minute)
//       - deadLetteringOnMessageExpiration: true


// =============================================================================
// Outputs
// =============================================================================
// TODO 3: Add outputs for:
// - serviceBusNamespaceName
// - queueName
output serviceBusNamespaceName string = serviceBusNamespaceName
output queueName string = queueName

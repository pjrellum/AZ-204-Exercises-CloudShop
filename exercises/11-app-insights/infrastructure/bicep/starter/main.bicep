// =============================================================================
// CloudShop Exercise 11 - Application Insights (Bicep)
// =============================================================================
// STARTER TEMPLATE - Fill in the TODOs
// =============================================================================

@description('Unique suffix for resource names')
param uniqueSuffix string

@description('Azure region for resources')
param location string = resourceGroup().location

// Derived names
var appInsightsName = 'ai-cloudshop-${uniqueSuffix}'
var logAnalyticsName = 'log-cloudshop-${uniqueSuffix}'

// =============================================================================
// Log Analytics Workspace
// =============================================================================
// TODO 1: Create a Log Analytics workspace
// Type: Microsoft.OperationalInsights/workspaces@2022-10-01
// Properties needed:
//   - name: logAnalyticsName
//   - location: location
//   - properties: sku with name 'PerGB2018', retentionInDays: 30


// =============================================================================
// Application Insights
// =============================================================================
// TODO 2: Create Application Insights connected to Log Analytics
// Type: Microsoft.Insights/components@2020-02-02
// Properties needed:
//   - name: appInsightsName
//   - location: location
//   - kind: 'web'
//   - properties:
//       - Application_Type: 'web'
//       - WorkspaceResourceId: (reference to Log Analytics)
//       - IngestionMode: 'LogAnalytics'


// =============================================================================
// Outputs
// =============================================================================
// TODO 3: Add outputs for:
// - appInsightsName
// - connectionString (from appInsights.properties.ConnectionString)
// - instrumentationKey (from appInsights.properties.InstrumentationKey)
output appInsightsName string = appInsightsName
output logAnalyticsWorkspaceName string = logAnalyticsName

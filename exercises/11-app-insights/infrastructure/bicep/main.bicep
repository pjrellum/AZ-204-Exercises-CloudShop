// =============================================================================
// CloudShop Exercise 11 - Application Insights (Bicep)
// =============================================================================
// COMPLETE SOLUTION
// =============================================================================

@description('Unique suffix for resource names')
param uniqueSuffix string

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Optional: Existing Function App name to connect')
param functionAppName string = ''

// Derived names
var appInsightsName = 'ai-cloudshop-${uniqueSuffix}'
var logAnalyticsName = 'log-cloudshop-${uniqueSuffix}'

// =============================================================================
// Log Analytics Workspace
// =============================================================================
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// =============================================================================
// Application Insights
// =============================================================================
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
  }
}

// =============================================================================
// Connect to existing Function App (if provided)
// =============================================================================
resource existingFunctionApp 'Microsoft.Web/sites@2023-01-01' existing = if (!empty(functionAppName)) {
  name: functionAppName
}

resource functionAppSettings 'Microsoft.Web/sites/config@2023-01-01' = if (!empty(functionAppName)) {
  parent: existingFunctionApp
  name: 'appsettings'
  properties: {
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
  }
}

// =============================================================================
// Outputs
// =============================================================================
output appInsightsName string = appInsights.name
output connectionString string = appInsights.properties.ConnectionString
output instrumentationKey string = appInsights.properties.InstrumentationKey
output logAnalyticsWorkspaceName string = logAnalytics.name

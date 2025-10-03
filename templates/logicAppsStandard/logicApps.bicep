param createdDate string = utcNow('yyyy-MM-dd')
param location string = resourceGroup().location
param environment string
param ephemeral string
param refedataStorageAccountName string
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param privateEndpointSubnet string
param comparams object
param resourceGroupName string
param primaryRegionResourceGroupName string
param dynamicsOrgName string
param commonApiContName string
param storageApiContName string
param serviceBusApiContName string
param subnetName string
param logAnalyticsWorkspace string
param vnetName string
param vnetResourceGroupName string
param logicApps string

var logicAppsArray = json(logicApps)
var logAnalyticsModule = resourceId(
  resourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspace
)

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: subnetName
  }
  resource privateEndpoint 'subnets@2024-05-01' existing = {
    name: privateEndpointSubnet
  }
}
resource storageModule 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: refedataStorageAccountName
  scope: resourceGroup(primaryRegionResourceGroupName)
}
resource appInsightsModule 'Microsoft.Insights/components@2020-02-02' existing = {
  name: toUpper(comparams.appInsightsName)
  scope: resourceGroup(resourceGroupName)
}

module logicApp 'br/avm:web/site:0.15.1' = [
  for logicApp in logicAppsArray: {
    name: logicApp.Name
    params: {
      name: logicApp.Name
      location: location
      kind: 'functionapp,workflowapp'
      managedIdentities: {
        systemAssigned: true
      }
      tags: {
        ServiceCode: 'FES'
        ServiceName: 'MMO'
        ServiceType: 'LOB'
        CreatedDate: createdDate
        Environment: environment
        Tier: 'WORKFLOW-APP'
        Location: location
        Purpose: 'FESMMO-APP'
        type: 'LogicApp'
        Ephemeral: ephemeral
      }
      serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', logicApp.ASP)
      httpsOnly: true
      appInsightResourceId: appInsightsModule.id
      appSettingsKeyValuePairs: {
        APP_KIND: 'workflowApp'
        APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsModule.properties.InstrumentationKey
        COMMON_API_CONNECTION_NAME: toUpper(commonApiContName)
        REFDATA_STORAGE_CONNECTION_NAME: toUpper(storageApiContName)
        SERVICE_BUS_CONNECTION_NAME: toUpper(serviceBusApiContName)
        FUNCTIONS_WORKER_RUNTIME: 'dotnet'
        FUNCTIONS_EXTENSION_VERSION: '~4'
        WORKFLOWS_SUBSCRIPTION_ID: subscription().subscriptionId
        WEBSITE_NODE_DEFAULT_VERSION: '~22'
        ORG_NAME: dynamicsOrgName
        STORAGEACCOUNT_URL: substring(
          storageModule.properties.primaryEndpoints.table,
          0,
          length(storageModule.properties.primaryEndpoints.table) - 1
        )
        RESOURCEGROUP_LOCATION: resourceGroup().location
        RESOURCEGROUP_NAME: resourceGroup().name
      }
      publicNetworkAccess: 'Disabled'
      privateEndpoints: [
        {
          name: toUpper('${logicApp.Name}-PE')
          service: 'sites'
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: ukSouthDnsZoneId
                name: 'uks-privatelink-sites'
              }
              {
                privateDnsZoneResourceId: northEuDnsZoneId
                name: 'neu-privatelink-sites'
              }
              {
                privateDnsZoneResourceId: westEuDnsZoneId
                name: 'weu-privatelink-sites'
              }
              {
                privateDnsZoneResourceId: ukWestDnsZoneId
                name: 'ukw-privatelink-sites'
              }
            ]
          }
          subnetResourceId: vnet::privateEndpoint.id
          tags: {
            name: toUpper('${logicApp.Name}-PE')
            Environment: environment
            Ephemeral: ephemeral
          }
        }
      ]
      storageAccountRequired: false
      virtualNetworkSubnetId: vnet::subnet.id
      vnetContentShareEnabled: false
      vnetRouteAllEnabled: false
      diagnosticSettings: [
        {
          name: '${logicApp.Name}-diagnosticSettings'
          metricCategories: [
            {
              category: 'AllMetrics'
              enabled: true
            }
          ]
          workspaceResourceId: logAnalyticsModule
        }
      ]
    }
  }
]

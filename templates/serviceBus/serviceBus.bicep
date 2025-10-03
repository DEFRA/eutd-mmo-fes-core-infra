param serviceBusName string
param environment string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param queuesNames array = [
  'mmo-dyn-ecc-res-queue'
  'mmo-ecc-dyn-req-queue'
]
param logAnalyticsName string
param resourceGroupName string
param messageLockDuration string = 'PT2M'
param serviceBusZoneRedundant string

var serviceBusdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'Web'
  Location: location
}

var logAnalyticsModule = resourceId(
  resourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsName
)

var authorizationRules = [
  {
    name: 'RootManageSharedAccessKey'
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
  {
    name: 'mmo-auth'
    rights: [
      'Listen'
      'Send'
    ]
  }
]

module serviceBusNamespace 'br/avm:service-bus/namespace:0.14.1' = {
  name: '${serviceBusName}-${deploymentDate}'
  params: {
    name: serviceBusName
    skuObject: {
      name: 'Standard'
    }
    disableLocalAuth: false
    minimumTlsVersion: '1.2'
    zoneRedundant: bool(serviceBusZoneRedundant)
    tags: serviceBusdefaultTags
    managedIdentities: {
      systemAssigned: true
    }

    publicNetworkAccess: 'Enabled'
    diagnosticSettings: [
      {
        name: '${serviceBusName}-diagnosticSettings'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        storageAccountResourceId: null
        workspaceResourceId: logAnalyticsModule
      }
    ]
    queues: [
      for queueName in queuesNames: {
        name: queueName
        lockDuration: messageLockDuration
        requiresSession: true
        autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
        maxMessageSizeInKilobytes: 2048
        authorizationRules: authorizationRules
        roleAssignments: []
      }
    ]
  }
}

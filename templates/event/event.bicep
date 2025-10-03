param eventHubNamespaceName string
param location string = resourceGroup().location
param environment string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param eventHubName string
param logAnalyticsName string
param ehbZoneRedundant string

param authorizationRules array = [
  {
    name: 'RootManageSharedAccessKey'
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
  {
    name: 'QRADAR_APP'
    rights: [
      'Listen'
      'Send'
    ]
  }
]

param eHubAuthorizationRules array = [
  {
    name: 'PreviewDataPolicy'
    rights: [
      'Listen'
    ]
  }
  {
    name: 'QRADAR_APP'
    rights: [
      'Listen'
      'Send'
    ]
  }
]

var eventHubdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'Web'
}

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

module primaryNamespace 'br/avm:event-hub/namespace:0.10.2' = {
  name: '${eventHubNamespaceName}-${deploymentDate}'
  params: {
    name: toUpper(eventHubNamespaceName)
    location: location
    tags: union(eventHubdefaultTags, {
      Location: location
    })
    skuCapacity: 2
    skuName: 'Standard'
    publicNetworkAccess: 'Enabled'
    authorizationRules: authorizationRules
    disableLocalAuth: false
    isAutoInflateEnabled: true
    maximumThroughputUnits: 2
    zoneRedundant: bool(ehbZoneRedundant)
    kafkaEnabled: true
    diagnosticSettings: [
      {
        name: '${eventHubNamespaceName}-diagnosticSettings'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        workspaceResourceId: law.id
      }
    ]
    eventhubs: [
      {
        name: eventHubName
        messageRetentionInDays: 7
        retentionDescriptionCleanupPolicy: 'Delete'
        retentionDescriptionRetentionTimeInHours: 168
        partitionCount: 2
        status: 'Active'
        authorizationRules: eHubAuthorizationRules
      }
    ]
    managedIdentities: {
      systemAssigned: true
    }
  }
}

param logicApps string
param location string = resourceGroup().location
param environment string
param ephemeral string
param skuCapacity string
param zoneRedundant string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param logAnalyticsWorkspace string
param resourceGroupName string
param skuName string
param maxElasticWorkerCount string

var logicAppsArray = json(logicApps)
var aspNamesArray = union(map(logicAppsArray, la => la.ASP), [])
var aspdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: skuName
  Location: location
  Ephemeral: ephemeral
}

var customTagsForasp = [
  for asp in aspNamesArray: {
    name: asp
    Purpose: 'FESMMO-LOGICAPPS-ASP'
    type: 'ASP'
  }
]

var logAnalyticsModule = resourceId(
  resourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspace
)

module appServicePlan 'br/avm:web/serverfarm:0.4.0' = [
  for asp in aspNamesArray: {
    name: '${asp}-${deploymentDate}'
    params: {
      name: toUpper(asp)
      location: location
      kind: 'elastic'
      zoneRedundant: bool(zoneRedundant)
      skuName: skuName
      skuCapacity: int(skuCapacity)
      elasticScaleEnabled: true
      maximumElasticWorkerCount: int(maxElasticWorkerCount)
      tags: union(aspdefaultTags, filter(customTagsForasp, x => toLower(x.name) == toLower(asp))[0])
      diagnosticSettings: [
        {
          name: '${asp}-diagnosticSettings'
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

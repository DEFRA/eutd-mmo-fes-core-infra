param aspNames string
param location string = resourceGroup().location
param environment string
param ephemeral string
param skuCapacity string
param zoneRedundant string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param logAnalyticsWorkspace string
param resourceGroupName string

var aspNamesArray = json(aspNames)
var aspdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'ASP'
  Location: location
  Ephemeral: ephemeral
}

var customTagsForasp = [
  for (asp, i) in aspNamesArray: {
    name: asp.Name
    Purpose: 'FESMMO-ASP'
    type: 'ASP'
  }
]

var logAnalyticsModule = resourceId(
  resourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspace
)

module appServicePlan 'br/avm:web/serverfarm:0.4.0' = [
  for (asp, i) in aspNamesArray: {
    name: '${asp.Name}-${deploymentDate}'
    params: {
      name: toUpper(asp.Name)
      location: location
      kind: 'linux'
      zoneRedundant: bool(zoneRedundant)
      reserved: true
      perSiteScaling: true
      skuName: asp.SkuName
      skuCapacity: int(skuCapacity)
      tags: union(aspdefaultTags, customTagsForasp[i])
      diagnosticSettings: [
        {
          name: '${asp.Name}-diagnosticSettings'
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

@description('Autoscale setting for App Service Plan')
resource autoscalingSettings 'Microsoft.Insights/autoscalesettings@2022-10-01' = [
  for (asp, i) in aspNamesArray: {
    name: '${asp.Name}-autoscale'
    location: location
    tags: {
      ServiceCode: 'FES'
      ServiceName: 'MMO'
      ServiceType: 'LOB'
      CreatedDate: createdDate
      Environment: environment
      Location: location
      Ephemeral: ephemeral
    }
    properties: any({
      profiles: [
        {
          name: 'DefaultAutoscaleProfile'
          capacity: {
            minimum: '1' // Need to be revisited
            maximum: '3'
            default: '1'
          }
          rules: [
            {
              metricTrigger: {
                metricName: 'CpuPercentage'
                metricNamespace: 'Microsoft.Web/serverfarms'
                metricResourceUri: appServicePlan[i].outputs.resourceId
                timeGrain: 'PT1M'
                statistic: 'Average'
                timeWindow: 'PT10M'
                timeAggregation: 'Average'
                operator: 'GreaterThan'
                threshold: 80
                dimensions: []
                dividePerInstance: false
              }
              scaleAction: {
                direction: 'Increase'
                type: 'ChangeCount'
                value: '1'
                cooldown: 'PT5M'
              }
            }
            {
              metricTrigger: {
                metricName: 'CpuPercentage'
                metricNamespace: 'Microsoft.Web/serverfarms'
                metricResourceUri: appServicePlan[i].outputs.resourceId
                timeGrain: 'PT1M'
                statistic: 'Average'
                timeWindow: 'PT10M'
                timeAggregation: 'Average'
                operator: 'LessThan'
                threshold: 30
                dimensions: []
                dividePerInstance: false
              }
              scaleAction: {
                direction: 'Decrease'
                type: 'ChangeCount'
                value: '1'
                cooldown: 'PT5M'
              }
            }
            {
              metricTrigger: {
                metricName: 'MemoryPercentage'
                metricNamespace: 'Microsoft.Web/serverfarms'
                metricResourceUri: appServicePlan[i].outputs.resourceId
                timeGrain: 'PT1M'
                statistic: 'Average'
                timeWindow: 'PT10M'
                timeAggregation: 'Average'
                operator: 'GreaterThan'
                threshold: 80
                dimensions: []
                dividePerInstance: false
              }
              scaleAction: {
                direction: 'Increase'
                type: 'ChangeCount'
                value: '1'
                cooldown: 'PT5M'
              }
            }
            {
              metricTrigger: {
                metricName: 'MemoryPercentage'
                metricNamespace: 'Microsoft.Web/serverfarms'
                metricResourceUri: appServicePlan[i].outputs.resourceId
                timeGrain: 'PT1M'
                statistic: 'Average'
                timeWindow: 'PT10M'
                timeAggregation: 'Average'
                operator: 'LessThan'
                threshold: 30
                dimensions: []
                dividePerInstance: false
              }
              scaleAction: {
                direction: 'Decrease'
                type: 'ChangeCount'
                value: '1'
                cooldown: 'PT5M'
              }
            }
          ]
        }
      ]
      enabled: true
      targetResourceUri: appServicePlan[i].outputs.resourceId
    })
  }
]

output appServicePlan array = [
  for (aspName, i) in aspNamesArray: { ids: appServicePlan[i].outputs.resourceId }
]

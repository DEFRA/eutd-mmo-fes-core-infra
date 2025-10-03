param logAnalyticsWorkspace string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param environment string
param location string = resourceGroup().location

// logAnalytic parameters
var logAnalyticdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'LOG'
  Location: location
  name: logAnalyticsWorkspace
  Purpose: 'FESMMO-LOG'
  type: 'LOG'
}

module law 'br/avm:operational-insights/workspace:0.7.0' = {
  name: '${logAnalyticsWorkspace}-${deploymentDate}'
  params: {
    name: toUpper(logAnalyticsWorkspace)
    location: location
    dataRetention: 30
    skuName: 'PerGB2018'
    tags: logAnalyticdefaultTags
  }
}

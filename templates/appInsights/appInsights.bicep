param environment string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param logAnalyticsName string
param testsEndpoints object
// appInsights parameters
param appInsightsName string
var appInsightsTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'APPINSIGHTS'
  Location: location
}
var customTagsForappInsights = {
  name: appInsightsName
  Purpose: 'FESMMO-APPINSIGHTS'
  type: 'APPINSIGHTS'
}

var appInsightsId = resourceId('microsoft.insights/components', appInsightsName)

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

// Create Application Insights 
module appInsights 'br/avm:insights/component:0.4.1' = {
  name: '${appInsightsName}-${deploymentDate}'
  params: {
    name: toUpper(appInsightsName)
    location: location
    workspaceResourceId: logAnalyticsWorkspace.id
    tags: union(appInsightsTags, customTagsForappInsights)
  }
}

resource webtests 'Microsoft.Insights/webtests@2018-05-01-preview' = [
  for i in range(0, length(testsEndpoints.endpoints)): {
    name: testsEndpoints.endpoints[i].name
    location: resourceGroup().location
    kind: 'ping'
    tags: {
      'hidden-link:${appInsightsId}': 'Resource'
    }
    properties: {
      Description: testsEndpoints.endpoints[i].description
      Enabled: testsEndpoints.endpoints[i].Enabled
      Frequency: 300
      Kind: 'standard'
      RetryEnabled: true
      SyntheticMonitorId: testsEndpoints.endpoints[i].id
      Timeout: 30
      Locations: [
        {
          Id: 'emea-se-sto-edge'
        }
        {
          Id: 'emea-gb-db3-azr'
        }
        {
          Id: 'emea-nl-ams-azr'
        }
        {
          Id: 'emea-fr-pra-edge'
        }
        {
          Id: 'emea-ru-msa-edge'
        }
        {
          Id: 'us-ca-sjc-azr'
        }
        {
          Id: 'us-va-ash-azr'
        }
        {
          Id: 'us-il-ch1-azr'
        }
        {
          Id: 'us-fl-mia-edge'
        }
        {
          Id: 'us-tx-sn1-azr'
        }
        {
          Id: 'emea-ch-zrh-edge'
        }
      ]
      Name: testsEndpoints.endpoints[i].displayName
      Request: {
        FollowRedirects: null
        HttpVerb: 'GET'
        ParseDependentRequests: false
        RequestUrl: testsEndpoints.endpoints[i].url
      }
      ValidationRules: {
        ExpectedHttpStatusCode: 200
        IgnoreHttpStatusCode: false
        ContentValidation: null
        SSLCheck: testsEndpoints.endpoints[i].ssl
        SSLCertRemainingLifetimeCheck: testsEndpoints.endpoints[i].sslLife
      }
    }
  }
]

// Output the necessary IDs
output appInsightsId string = appInsights.outputs.resourceId
output instrumentationKey string = appInsights.outputs.instrumentationKey

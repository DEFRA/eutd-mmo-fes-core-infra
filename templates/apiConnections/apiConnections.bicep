param CommonApiContName string
param environment string
param location string = resourceGroup().location
param storagerefdataName string
param createdDate string = utcNow('yyyy-MM-dd')
param serviceBusConnection string
param azureMgmtUri string
param resourceGroupName string
param primaryRegionResourceGroupName string
param storageConnection string
param serviceBusName string

param resourceUri string
param common object

@secure()
param servicePrincipalSecret string
param servicePrincipalTenant string
var storageResourceId = resourceId(
  primaryRegionResourceGroupName,
  'Microsoft.Storage/storageAccounts',
  toLower(storagerefdataName)
)

var defaulttags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreationDate: createdDate
  Environment: environment
  Tier: 'API'
  Region: resourceGroup().name
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: toLower(serviceBusName)
}
var authRuleResourceId = '${serviceBusNamespace.id}/authorizationRules/RootManageSharedAccessKey'

resource storageConnection_name 'Microsoft.Web/connections@2016-06-01' = {
  name: toUpper(storageConnection)
  location: location
  kind: 'V2'
  tags: defaulttags
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuretables')
    }
    parameterValues: {
      storageaccount: toLower(storagerefdataName)
      sharedkey: listKeys(storageResourceId, '2019-04-01').keys[0].value
    }
    testLinks: [
      {
        requestUri: uri(
          azureMgmtUri,
          '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/connections/${storagerefdataName}/extensions/proxy/testconnection?api-version=2018-07-01-preview'
        )
        method: 'get'
      }
    ]
  }
}

resource serviceBusconnections 'Microsoft.Web/connections@2016-06-01' = {
  name: toUpper(serviceBusConnection)
  location: location
  tags: defaulttags
  kind: 'V2'
  properties: {
    displayName: 'servicebus-connect-resource'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'servicebus')
    }
    parameterValues: {
      connectionString: listKeys(authRuleResourceId, '2024-01-01').primaryConnectionString
    }
  }
}

resource CommonApiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: toUpper(CommonApiContName)
  location: location
  tags: defaulttags
  kind: 'V2'
  properties: {
    displayName: 'commondataservice'
    customParameterValues: {}
    api: {
      id: subscriptionResourceId(
        'Microsoft.Web/locations/managedApis',
        location,
        'commondataservice'
      )
    }
    parameterValues: {
      'token:clientId': common.servicePrincipalAppId
      'token:clientSecret': servicePrincipalSecret
      'token:TenantId': servicePrincipalTenant
      'token:resourceUri': resourceUri
      'token:grantType': 'client_credentials'
    }
  }
}

output commonApiConnectionId string = CommonApiConnection.id
output connectionRuntimeUrl string = CommonApiConnection.properties.connectionRuntimeUrl

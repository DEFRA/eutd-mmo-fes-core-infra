param CommonApiContName string
param environment string
param location string = resourceGroup().location
param storagerefdataName string
param createdDate string = utcNow('yyyy-MM-dd')
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
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
resource storageRefData 'Microsoft.Storage/storageAccounts@2025-06-01' existing = {
  name: toLower(storagerefdataName)
  scope: resourceGroup(primaryRegionResourceGroupName)
}

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

module storageConnection_name 'br/avm:web/connection:0.4.4' = {
  name: '${toUpper(storageConnection)}-${deploymentDate}'
  params: {
    name: toUpper(storageConnection)
    location: location
    kind: 'V2'
    tags: defaulttags
    displayName: 'Azure Table Storage'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuretables')
    }
    parameterValues: {
      storageaccount: toLower(storagerefdataName)
      sharedkey: storageRefData.listKeys().keys[0].value
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

module serviceBusconnections 'br/avm:web/connection:0.4.4' = {
  name: '${toUpper(serviceBusConnection)}-${deploymentDate}'
  params: {
    name: toUpper(serviceBusConnection)
    location: location
    tags: defaulttags
    kind: 'V2'
    displayName: 'servicebus-connect-resource'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'servicebus')
    }
    parameterValues: {
      connectionString: listKeys(authRuleResourceId, '2024-01-01').primaryConnectionString
    }
  }
}

module CommonApiConnection 'br/avm:web/connection:0.4.4' = {
  name: '${toUpper(CommonApiContName)}-${deploymentDate}'
  params: {
    name: toUpper(CommonApiContName)
    location: location
    tags: defaulttags
    kind: 'V2'
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

// Module outputs omit connectionRuntimeUrl, so read it from the deployed connection.
resource commonApiConnectionRuntime 'Microsoft.Web/connections@2016-06-01' existing = {
  name: toUpper(CommonApiContName)
  dependsOn: [
    CommonApiConnection
  ]
}

output commonApiConnectionId string = CommonApiConnection.outputs.resourceId
// connectionRuntimeUrl is returned by ARM but missing from the type definition.
#disable-next-line BCP053
output connectionRuntimeUrl string = commonApiConnectionRuntime.properties.connectionRuntimeUrl

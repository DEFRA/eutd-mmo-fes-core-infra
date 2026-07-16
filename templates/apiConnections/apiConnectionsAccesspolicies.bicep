param CommonApiContName string
param storageConnection string
param serviceBusConnection string
param location string = resourceGroup().location

param tenantId string
param logicApps string

var CommonApiPoliciesName = toUpper(CommonApiContName)
var storageConnectionName = toUpper(storageConnection)
var serviceBusConnectionName = toUpper(serviceBusConnection)
var scopeGroup = resourceGroup().name
var logicAppsArray = json(logicApps)

resource logicAppResources 'Microsoft.Web/sites@2024-04-01' existing = [for logicApp in logicAppsArray: {
  name: logicApp.Name
  scope: resourceGroup(scopeGroup)
}]

resource storageAccessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = [for (logicApp, i) in logicAppsArray: {
  name: '${storageConnectionName}/${logicApp.Name}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: items(logicAppResources[i].identity.userAssignedIdentities)[0].value.principalId
        tenantId: tenantId
      }
    }
  }
}]

resource serviceBusAccessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = [for (logicApp, i) in logicAppsArray: {
  name: '${serviceBusConnectionName}/${logicApp.Name}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: items(logicAppResources[i].identity.userAssignedIdentities)[0].value.principalId
        tenantId: tenantId
      }
    }
  }
}]

resource commonApiAccessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = [for (logicApp, i) in logicAppsArray: {
  name: '${CommonApiPoliciesName}/${logicApp.Name}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: items(logicAppResources[i].identity.userAssignedIdentities)[0].value.principalId
        tenantId: tenantId
      }
    }
  }
}]

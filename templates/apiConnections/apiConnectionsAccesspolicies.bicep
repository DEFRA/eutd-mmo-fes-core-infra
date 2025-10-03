param CommonApiContName string
param storageConnection string
param serviceBusConnection string
param location string = resourceGroup().location

param tenantId string
param refdatalogicAppName string
param processorlogicAppName string

var CommonApiPoliciesName = toUpper(CommonApiContName)
var storageConnectionName = toUpper(storageConnection)
var serviceBusConnectionName = toUpper(serviceBusConnection)
var scopeGroup = resourceGroup().name

resource refdataLogicApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: refdatalogicAppName
  scope: resourceGroup(scopeGroup)
}

resource processorLogicApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: processorlogicAppName
  scope: resourceGroup(scopeGroup)
}

resource refdataAccessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${storageConnectionName}/${refdatalogicAppName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: refdataLogicApp.identity.principalId
        tenantId: tenantId
      }
    }
  }
}

resource processAccessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${storageConnectionName}/${processorlogicAppName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: processorLogicApp.identity.principalId
        tenantId: tenantId
      }
    }
  }
}

resource refdataAccessPolicies02 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${serviceBusConnectionName}/${refdatalogicAppName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: refdataLogicApp.identity.principalId
        tenantId: tenantId
      }
    }
  }
}

resource processorAccessPolicies02 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${serviceBusConnectionName}/${processorlogicAppName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: processorLogicApp.identity.principalId
        tenantId: tenantId
      }
    }
  }
}

resource refdataAccessPolicies03 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${CommonApiPoliciesName}/${refdatalogicAppName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: refdataLogicApp.identity.principalId
        tenantId: tenantId
      }
    }
  }
}

resource processorAccessPolicies03 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${CommonApiPoliciesName}/${processorlogicAppName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        objectId: processorLogicApp.identity.principalId
        tenantId: tenantId
      }
    }
  }
}

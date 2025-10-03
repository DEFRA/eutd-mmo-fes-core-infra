param webAppNames string
param webAppResourceGroupName string
param keyVaultName string
param functionAppName string
param slotsEnabled string

var webAppsObjectsArray = json(webAppNames)
var webAppNamesArray = [for webApp in webAppsObjectsArray: webApp.Name]
var allAppNames = union(webAppNamesArray, [functionAppName])

resource webApps 'Microsoft.Web/sites@2024-04-01' existing = [
  for appName in allAppNames: {
    name: toUpper(appName)
    scope: resourceGroup(webAppResourceGroupName)
  }
]

resource webAppSlots 'Microsoft.Web/sites/slots@2024-04-01' existing = [
  for appName in allAppNames: if (bool(slotsEnabled)) {
    name: '${toUpper(appName)}/staging'
    scope: resourceGroup(webAppResourceGroupName)
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource keyVaultRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (app, i) in allAppNames: {
    name: guid(subscription().subscriptionId, 'KeyVaultRoleAssignment', webApps[i].name)
    scope: keyVault
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        '4633458b-17de-408a-b874-0445c86b69e6'
      )
      principalId: webApps[i].identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

resource keyVaultRoleAssignmentSlots 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (app, i) in allAppNames: if (bool(slotsEnabled)) {
    name: guid(subscription().subscriptionId, 'KeyVaultRoleAssignment', webAppSlots[i].name)
    scope: keyVault
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        '4633458b-17de-408a-b874-0445c86b69e6'
      )
      principalId: webAppSlots[i].identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

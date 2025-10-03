param webAppNames array
param webAppResourceGroupName string
param acrName string
param slotsEnabled string
param appEnvSubscriptionId string

resource webApps 'Microsoft.Web/sites@2024-04-01' existing = [
  for app in webAppNames: {
    name: toUpper(app)
    scope: resourceGroup(appEnvSubscriptionId, webAppResourceGroupName)
  }
]

resource webAppSlots 'Microsoft.Web/sites/slots@2024-04-01' existing = [
  for app in webAppNames: if (bool(slotsEnabled)) {
    name: '${toUpper(app)}/staging'
    scope: resourceGroup(appEnvSubscriptionId, webAppResourceGroupName)
  }
]

resource acr 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' existing = {
  name: acrName
}

resource acrRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (app, i) in webAppNames: {
    name: guid(subscription().subscriptionId, 'AcrRoleAssignment', webApps[i].name)
    scope: acr
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
      )
      principalId: webApps[i].identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

resource acrRoleAssignmentsSlots 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (app, i) in webAppNames: if (bool(slotsEnabled)) {
    name: guid(subscription().subscriptionId, 'AcrRoleAssignment', webAppSlots[i].name)
    scope: acr
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        '7f951dda-4ed3-4680-a7ca-43fe172d538d' //AcrPull
      )
      principalId: webAppSlots[i].identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

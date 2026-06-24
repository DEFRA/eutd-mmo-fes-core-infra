param logicApps string
param logicAppResourceGroupName string
param storageAccountName string

param subscriptionId string = subscription().subscriptionId

var logicAppsArray = json(logicApps)

resource logicAppResources 'Microsoft.Web/sites@2024-04-01' existing = [for logicApp in logicAppsArray: {
  name: logicApp.Name
  scope: resourceGroup(logicAppResourceGroupName)
}]

var strAccRoleAssignments = [
  {
    description: 'Storage blob contributor'
    roleDefinitionIdOrName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  }
  {
    description: 'Storage Table contributor'
    roleDefinitionIdOrName: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  }
  {
    description: 'Storage Account Contributor'
    roleDefinitionIdOrName: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  }
]

module strAccRoleAssignmentsModule '.bicep/storageAccRoleAssignment.bicep' = [for (logicApp, i) in logicAppsArray: {
  name: guid(subscriptionId, 'strAccRoleAssignments-${logicApp.Name}')
  params: {
    roleAssignments: strAccRoleAssignments
    principalId: logicAppResources[i].identity.principalId
    storageAccountName: storageAccountName
  }
}]

param roleAssignments array
param principalId string
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: toLower(storageAccountName)
}

resource roleAssignmentResources 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, i) in roleAssignments: {
    name: guid(subscription().subscriptionId, roleAssignment.description, principalId)
    scope: storageAccount
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        roleAssignment.roleDefinitionIdOrName
      )
      principalId: principalId
      principalType: 'ServicePrincipal'
    }
  }
]

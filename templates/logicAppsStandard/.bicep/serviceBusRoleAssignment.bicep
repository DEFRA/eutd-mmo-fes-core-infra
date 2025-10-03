param roleAssignments array
param principalId string
param serviceBusName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: toLower(serviceBusName)
}

resource roleAssignmentResources 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, i) in roleAssignments: {
    name: guid(subscription().subscriptionId, roleAssignment.description, principalId)
    scope: serviceBus
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

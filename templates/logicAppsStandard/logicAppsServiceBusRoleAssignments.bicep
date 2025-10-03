param refdatalogicAppName string
param processorlogicAppName string
param logicAppResourceGroupName string
param serviceBusName string

param subscriptionId string = subscription().subscriptionId

resource refDataLogicApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: refdatalogicAppName
  scope: resourceGroup(logicAppResourceGroupName)
}
resource processorLogicApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: processorlogicAppName
  scope: resourceGroup(logicAppResourceGroupName)
}

var serviceBusRoleAssignments = [
  {
    description: 'Azure Service Bus Data Receiver'
    roleDefinitionIdOrName: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
  }
  {
    description: 'Azure Service Bus Data Sender'
    roleDefinitionIdOrName: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
  }
]

module refDataServiceBusRoleAssignments '.bicep/serviceBusRoleAssignment.bicep' = {
  name: guid(subscriptionId, 'refDataServiceBusRoleAssignments')
  params: {
    roleAssignments: serviceBusRoleAssignments
    principalId: refDataLogicApp.identity.principalId
    serviceBusName: serviceBusName
  }
}

module processorServiceBusRoleAssignments '.bicep/serviceBusRoleAssignment.bicep' = {
  name: guid(subscriptionId, 'processorServiceBusRoleAssignments')
  params: {
    roleAssignments: serviceBusRoleAssignments
    principalId: processorLogicApp.identity.principalId
    serviceBusName: serviceBusName
  }
}

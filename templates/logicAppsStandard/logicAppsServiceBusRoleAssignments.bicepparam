using 'logicAppsServiceBusRoleAssignments.bicep'

param refdatalogicAppName = '#{{ environment }}#{{ nc-deptService }}REFDATA#{{ nc-resource-logicapps }}#{{ nc-region-id }}01'
param processorlogicAppName = '#{{ environment }}#{{ nc-deptService }}PROCESSOR#{{ nc-resource-logicapps }}#{{ nc-region-id }}01'
param logicAppResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'
param serviceBusName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-servicebus }}#{{ nc-region-id }}01'

using 'logicAppsServiceBusRoleAssignments.bicep'

param logicApps = '''#{{ logicApps }}'''
param logicAppResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'
param serviceBusName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-servicebus }}#{{ nc-region-id }}01'

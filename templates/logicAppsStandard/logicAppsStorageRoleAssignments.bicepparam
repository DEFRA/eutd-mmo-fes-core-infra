using 'logicAppsStorageRoleAssignments.bicep'

param storageAccountName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}03'
param logicApps = '''#{{ logicApps }}'''
param logicAppResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'

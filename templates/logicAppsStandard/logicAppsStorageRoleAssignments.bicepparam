using 'logicAppsStorageRoleAssignments.bicep'

param storageAccountName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}03' //referencedata
param refdatalogicAppName = '#{{ environment }}#{{ nc-deptService }}REFDATA#{{ nc-resource-logicapps }}#{{ nc-region-id }}01'
param processorlogicAppName = '#{{ environment }}#{{ nc-deptService }}PROCESSOR#{{ nc-resource-logicapps }}#{{ nc-region-id }}01'
param logicAppResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'

using './keyVaultRoleAssignments.bicep'

param webAppNames = '#{{ webAppNames }}'
param webAppResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'
param keyVaultName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-static-res-region-id }}01'
param functionAppName = '#{{ functionAppName }}'
param slotsEnabled = '#{{ slotsEnabled }}'

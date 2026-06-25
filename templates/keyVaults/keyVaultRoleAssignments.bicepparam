using 'keyVaultRoleAssignments.bicep'

param webAppNames = '''#{{ webAppNames }}'''
param webAppResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'
param keyVaultName = '#{{ keyVaultName }}'
param functionAppName = '#{{ functionAppName }}'
param slotsEnabled = '#{{ slotsEnabled }}'

using 'apiConnections.bicep'

param environment = '#{{ environment }}'
param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param primaryRegionResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-static-res-region-id }}02'

param storagerefdataName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}03'

param storageConnection = '#{{ environment }}#{{ nc-deptService }}referencedata-api-connection-01'
param serviceBusConnection = '#{{ environment }}mmoservicebus-api-connection-01'
param CommonApiContName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02-api-connection-01'

param serviceBusName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-servicebus }}#{{ nc-region-id }}01'

param resourceUri = 'https://management.core.windows.net/'
param azureMgmtUri = 'https://management.azure.com:443/'
param common = {
  servicePrincipalAppId: '#{{ ServicePrincipalAppId }}'
  keyVaultName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-static-res-region-id }}01'
}

param servicePrincipalSecret = az.getSecret(
  '#{{ subscriptionId }}',
  '${primaryRegionResourceGroupName}',
  '${common.keyVaultName}',
  'SERVICE-PRINCIPAL-SECRET'
)
param servicePrincipalTenant = '#{{ apiConnectionTenantId }}'

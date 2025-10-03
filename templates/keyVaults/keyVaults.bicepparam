using 'keyVaults.bicep'

param keyVaultName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-region-id }}01'
param environment = '#{{ environment }}'
param sku = 'standard'

param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'
param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkVault }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkVault }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkVault }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkVault }}'

param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

using 'keyVaults.bicep'

param keyVaultName = '#{{ keyVaultName }}'
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

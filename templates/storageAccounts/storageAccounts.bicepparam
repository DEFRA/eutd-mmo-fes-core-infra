using 'storageAccounts.bicep'

param storageAccounts = '#{{ storageAccounts }}'

param environment = '#{{ environment }}'
param skuName = '#{{ storageAccountSkuName }}'
param kind = 'StorageV2'
param accessTier = 'Hot'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkBlob }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkBlob }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkBlob }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkBlob }}'

param ukSouthDnsTableZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkTable }}'
param northEuDnsTableZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkTable }}'
param westEuDnsTableZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkTable }}'
param ukWestDnsTableZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkTable }}'

param ukSouthDnsStorageQueueZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkStorageQueue }}'
param northEuDnsStorageQueueZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkStorageQueue }}'
param westEuDnsStorageQueueZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkStorageQueue }}'
param ukWestDnsStorageQueueZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkStorageQueue }}'

param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'
param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'
param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

param subnets = [
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}01'
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}02'
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}03'
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}04'
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}05'
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}06'
  '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}07'
]

param cefasSubnets = '#{{ cefasSubnets }}'
param firewallIps = '#{{ firewallIps }}'

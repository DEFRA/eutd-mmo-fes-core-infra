using 'redisCache.bicep'

param environment = '#{{ environment }}'
param redisCacheName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-rediscachename }}#{{ nc-region-id }}01'
param redisCacheSkuName = '#{{ cacheSkuName }}'
param redisCacheCapacity = '#{{ cacheCapacity }}'

param comparams = {
  logAnalyticsName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-analytics }}#{{ nc-region-id }}01'
  secondaryRegionLogAnalyticsName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-analytics }}1601'
}
param sharedResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'
param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkRedis }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkRedis }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkRedis }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkRedis }}'

param secondaryRegion = '#{{ secondaryRegion }}'
param secondaryRegionCacheName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-rediscachename }}1601'
param secondaryRegionSharedResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}1602'
param secondaryRegionResourceGroup = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}1601'
param secondaryRegionVnetName = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}1601'
param secondaryRegionVnetResourceGroupName = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}1601'
param secondaryRegionPrivateEndpointSubnet = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}1606'
param disasterRecoverySupported = '#{{ disasterRecoverySupported }}'

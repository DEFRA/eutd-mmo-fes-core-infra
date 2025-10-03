param environment string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param comparams object
param redisCacheName string
param redisCacheSkuName string
param redisCacheCapacity string
param vnetResourceGroupName string
param vnetName string
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param privateEndpointSubnet string
param sharedResourceGroupName string
param secondaryRegion string
param secondaryRegionCacheName string
param secondaryRegionSharedResourceGroupName string
param secondaryRegionVnetName string
param secondaryRegionVnetResourceGroupName string
param secondaryRegionResourceGroup string
param secondaryRegionPrivateEndpointSubnet string
param disasterRecoverySupported string

var defaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'Cache'
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: privateEndpointSubnet
  }
}
resource secondaryVnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (bool(disasterRecoverySupported)) {
  name: secondaryRegionVnetName
  scope: resourceGroup(secondaryRegionVnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: secondaryRegionPrivateEndpointSubnet
  }
}
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: comparams.logAnalyticsName
  scope: resourceGroup(sharedResourceGroupName)
}
resource secondaryRegionLaw 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (bool(disasterRecoverySupported)) {
  name: comparams.secondaryRegionLogAnalyticsName
  scope: resourceGroup(secondaryRegionSharedResourceGroupName)
}

module secondaryRegionRG 'br/avm:resources/resource-group:0.4.1' = if (bool(disasterRecoverySupported)) {
  name: '${secondaryRegionResourceGroup}-${deploymentDate}'
  scope: subscription()
  params: {
    name: secondaryRegionResourceGroup
    location: secondaryRegion
  }
}

// Primary Redis Cache
module primaryRedisCache 'br/avm:cache/redis:0.14.0' = {
  name: '${redisCacheName}-${deploymentDate}'
  params: {
    name: redisCacheName
    location: location
    redisConfiguration: {}
    minimumTlsVersion: '1.2'
    enableNonSslPort: false
    tags: union(defaultTags, {
      Location: location
    })
    zoneRedundant: true
    skuName: redisCacheSkuName
    capacity: int(redisCacheCapacity)
    replicasPerPrimary: 1
    replicasPerMaster: 1
    shardCount: 1
    publicNetworkAccess: 'Disabled'
    managedIdentities: {
      systemAssigned: true
    }
    privateEndpoints: [
      {
        name: toUpper('${redisCacheName}-PE')
        service: 'redisCache'
        subnetResourceId: vnet::subnet.id
        tags: {
          name: toUpper('${redisCacheName}-PE')
          Environment: environment
        }
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: ukSouthDnsZoneId
              name: 'uks-privatelink-redis-cache'
            }
            {
              privateDnsZoneResourceId: northEuDnsZoneId
              name: 'neu-privatelink-redis-cache'
            }
            {
              privateDnsZoneResourceId: westEuDnsZoneId
              name: 'weu-privatelink-redis-cache'
            }
            {
              privateDnsZoneResourceId: ukWestDnsZoneId
              name: 'ukw-privatelink-redis-cache'
            }
          ]
        }
      }
    ]
    diagnosticSettings: [
      {
        name: '${redisCacheName}-diagnosticSettings'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        workspaceResourceId: law.id
      }
    ]
  }
}

// Secondary Redis Cache (for geo-replication)
module secondaryRedisCache 'br/avm:cache/redis:0.14.0' = if (bool(disasterRecoverySupported)) {
  name: '${secondaryRegionCacheName}-${deploymentDate}'
  scope: resourceGroup(secondaryRegionResourceGroup)
  dependsOn: [secondaryRegionRG]
  params: {
    name: secondaryRegionCacheName
    location: secondaryRegion
    redisConfiguration: {}
    minimumTlsVersion: '1.2'
    enableNonSslPort: false
    tags: union(defaultTags, {
      Location: secondaryRegion
    })
    zoneRedundant: false
    skuName: redisCacheSkuName
    capacity: int(redisCacheCapacity)
    replicasPerPrimary: 1
    replicasPerMaster: 1
    publicNetworkAccess: 'Disabled'
    shardCount: 1
    managedIdentities: {
      systemAssigned: true
    }
    privateEndpoints: [
      {
        name: toUpper('${secondaryRegionCacheName}-PE')
        service: 'redisCache'
        subnetResourceId: secondaryVnet::subnet.id
        tags: {
          name: toUpper('${secondaryRegionCacheName}-PE')
          Environment: environment
        }
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: ukSouthDnsZoneId
              name: 'uks-privatelink-redis-cache'
            }
            {
              privateDnsZoneResourceId: northEuDnsZoneId
              name: 'neu-privatelink-redis-cache'
            }
            {
              privateDnsZoneResourceId: westEuDnsZoneId
              name: 'weu-privatelink-redis-cache'
            }
            {
              privateDnsZoneResourceId: ukWestDnsZoneId
              name: 'ukw-privatelink-redis-cache'
            }
          ]
        }
      }
    ]
    diagnosticSettings: [
      {
        name: '${secondaryRegionCacheName}-diagnosticSettings'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        workspaceResourceId: secondaryRegionLaw.id
      }
    ]
  }
}

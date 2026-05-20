param environment string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param comparams object
param redisCacheName string
param redisCacheSkuName string
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

var disasterRecoveryEnabled = bool(disasterRecoverySupported)
var redisGeoReplicationGroupName = redisCacheName
var primaryRedisDatabaseResourceId = resourceId('Microsoft.Cache/redisEnterprise/databases', redisCacheName, 'default')
var secondaryRedisDatabaseResourceId = resourceId(secondaryRegionResourceGroup, 'Microsoft.Cache/redisEnterprise/databases', secondaryRegionCacheName, 'default')

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
resource secondaryVnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (disasterRecoveryEnabled) {
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
resource secondaryRegionLaw 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (disasterRecoveryEnabled) {
  name: comparams.secondaryRegionLogAnalyticsName
  scope: resourceGroup(secondaryRegionSharedResourceGroupName)
}

var baseRedisDatabaseConfig = {
  accessKeysAuthentication: 'Enabled'
  clientProtocol: 'Encrypted'
  clusteringPolicy: 'EnterpriseCluster'
  port: 10000
}

var primaryRedisDatabaseConfig = union(baseRedisDatabaseConfig, disasterRecoveryEnabled ? {
  geoReplication: {
    groupNickname: redisGeoReplicationGroupName
    linkedDatabases: [
      {
        id: primaryRedisDatabaseResourceId
      }
    ]
  }
} : {})

var secondaryRedisDatabaseConfig = union(baseRedisDatabaseConfig, {
  geoReplication: {
    groupNickname: redisGeoReplicationGroupName
    linkedDatabases: [
      {
        id: primaryRedisDatabaseResourceId
      }
      {
        id: secondaryRedisDatabaseResourceId
      }
    ]
  }
})

module secondaryRegionRG 'br/avm:resources/resource-group:0.4.1' = if (disasterRecoveryEnabled) {
  name: '${secondaryRegionResourceGroup}-${deploymentDate}'
  scope: subscription()
  params: {
    name: secondaryRegionResourceGroup
    location: secondaryRegion
  }
}

// Primary Azure Managed Redis instance
module primaryRedisCache 'br/avm:cache/redis-enterprise:0.5.1' = {
  name: '${redisCacheName}-${deploymentDate}'
  params: {
    name: redisCacheName
    location: location
    database: primaryRedisDatabaseConfig
    highAvailability: disasterRecoveryEnabled ? 'Enabled' : 'Disabled'
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    tags: union(defaultTags, {
      Location: location
    })
    skuName: redisCacheSkuName
    privateEndpoints: [
      {
        name: toUpper('${redisCacheName}-PE')
        service: 'redisEnterprise'
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

// Secondary Azure Managed Redis instance for active geo-replication
module secondaryRedisCache 'br/avm:cache/redis-enterprise:0.5.1' = if (disasterRecoveryEnabled) {
  name: '${secondaryRegionCacheName}-${deploymentDate}'
  scope: resourceGroup(secondaryRegionResourceGroup)
  dependsOn: [
    primaryRedisCache
    secondaryRegionRG
  ]
  params: {
    name: secondaryRegionCacheName
    location: secondaryRegion
    database: secondaryRedisDatabaseConfig
    highAvailability: 'Enabled'
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    tags: union(defaultTags, {
      Location: secondaryRegion
    })
    skuName: redisCacheSkuName
    privateEndpoints: [
      {
        name: toUpper('${secondaryRegionCacheName}-PE')
        service: 'redisEnterprise'
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

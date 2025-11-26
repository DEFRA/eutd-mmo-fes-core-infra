param cosmosDBName string
param location string = resourceGroup().location
param environment string
param createdDate string = utcNow('yyyy-MM-dd')
param logAnalyticsWorkspace string
param vnetName string
param vnetResourceGroupName string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param ukSouthDnsZoneIdMongoCluster string
param northEuDnsZoneIdMongoCluster string
param westEuDnsZoneIdMongoCluster string
param ukWestDnsZoneIdMongoCluster string
param privateEndpointSubnet string
param serverVersion string
param cosmosMultiRegionWrite bool
param databaseAccountOfferType string
param defaultConsistencyLevel string
param cosmosReadOnlyLocation string
param cosmosMongoDbCollections object
param isServerless string
param isPrimaryZoneRedundant string
param isSecondaryZoneRedundant string
param isGeoRedundant bool
param isVcore string
@secure()
param cosmosAdminPassword string
param secondaryCosmosDBName string
param secondaryRegionResourceGroup string
param secondaryRegionVnetName string
param secondaryRegionVnetResourceGroupName string
param secondaryRegionPrivateEndpointSubnet string
param secondaryRegionLogAnalyticsName string
param geoReplicaExists bool = false
param vCoreTier string
param vCoreZoneRedundancy string
param vCoreStorageSizeInGB int

var primaryLocation = [
  {
    failoverPriority: 0
    locationName: location
    isZoneRedundant: bool(isPrimaryZoneRedundant)
  }
]
var secondaryLocation = [
  {
    failoverPriority: 1
    locationName: cosmosReadOnlyLocation
    isZoneRedundant: bool(isSecondaryZoneRedundant)
  }
]

var capabilites = [
  'EnableMongo'
  'DisableRateLimitingResponses'
  'EnableUniqueCompoundNestedDocs'
]

var defaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'DBS'
  Location: location
}
var customTags = {
  name: cosmosDBName
  Purpose: 'FESMMO-DBS'
  type: 'DBS'
}
var privateEndpointTags = {
  name: '${toLower(cosmosDBName)}-PE'
  Environment: environment
}
var isCosmosServerless = bool(isServerless)
var isCosmosVcore = bool(isVcore)

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspace
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: privateEndpointSubnet
  }
}

resource secondaryVnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (isGeoRedundant) {
  name: secondaryRegionVnetName
  scope: resourceGroup(secondaryRegionVnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: secondaryRegionPrivateEndpointSubnet
  }
}

resource secondaryRegionLaw 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (isGeoRedundant) {
  name: secondaryRegionLogAnalyticsName
  scope: resourceGroup(secondaryRegionResourceGroup)
}

module secondaryRegionRG 'br/avm:resources/resource-group:0.4.1' = if (isGeoRedundant) {
  name: '${secondaryRegionResourceGroup}-${deploymentDate}'
  scope: subscription()
  params: {
    name: secondaryRegionResourceGroup
    location: cosmosReadOnlyLocation
  }
}

// UNABLE TO ADD CERTAIN CAPABILITIES VIA AVM. SO USING BICEP
resource cosmosDbThroughputAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = if (!isCosmosVcore) {
  name: toLower(cosmosDBName)
  location: location
  tags: union(defaultTags, customTags)
  kind: 'MongoDB'
  properties: {
    databaseAccountOfferType: databaseAccountOfferType
    enableAutomaticFailover: true
    enableMultipleWriteLocations: cosmosMultiRegionWrite
    publicNetworkAccess: 'Disabled'
    consistencyPolicy: {
      defaultConsistencyLevel: defaultConsistencyLevel
    }
    apiProperties: {
      serverVersion: serverVersion
    }
    capabilities: [
      for c in (bool(isCosmosServerless) ? union(capabilites, ['EnableServerless']) : capabilites): {
        name: c
      }
    ]
    locations: [
      for loc in (isGeoRedundant ? union(primaryLocation, secondaryLocation) : primaryLocation): {
        locationName: loc.locationName
        failoverPriority: loc.failoverPriority
        isZoneRedundant: loc.isZoneRedundant
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: isGeoRedundant == 'true'
          ? 'Geo'
          : (isPrimaryZoneRedundant == 'true' ? 'Zone' : 'Local')
      }
    }
  }
}

resource exportCertMongoDbDatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2024-11-15' = if (!isCosmosVcore) {
  name: cosmosMongoDbCollections.name
  parent: cosmosDbThroughputAccount
  properties: {
    resource: {
      id: cosmosMongoDbCollections.name
    }
    options: {}
  }
}

resource privateEndpointCosmosThroughput 'Microsoft.Network/privateEndpoints@2024-03-01' = if (!isCosmosVcore) {
  name: '${toUpper(cosmosDBName)}-PE'
  location: location
  tags: privateEndpointTags
  properties: {
    subnet: {
      id: vnet::subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${toUpper(cosmosDBName)}-MongoDB-0'
        properties: {
          privateLinkServiceId: cosmosDbThroughputAccount.id
          groupIds: [ 'MongoDB' ]
        }
      }
    ]
  }
  resource privateDnsZoneGroupsCosmosThroughput 'privateDnsZoneGroups@2024-03-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'uks-privatelink-mongodb'
          properties: { privateDnsZoneId: ukSouthDnsZoneId }
        }
        {
          name: 'neu-privatelink-mongodb'
          properties: { privateDnsZoneId: northEuDnsZoneId }
        }
        {
          name: 'weu-privatelink-mongodb'
          properties: { privateDnsZoneId: westEuDnsZoneId }
        }
        {
          name: 'ukw-privatelink-mongodb'
          properties: { privateDnsZoneId: ukWestDnsZoneId }
        }
      ]
    }
  }
}

// Diagnostic settings for throughput account
resource cosmosThroughputDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!isCosmosVcore) {
  name: '${toLower(cosmosDBName)}-diagnosticSettings'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
  scope: cosmosDbThroughputAccount
}

@batchSize(4)
resource exportCertMongoDbCollections 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2024-11-15' = [
  for item in cosmosMongoDbCollections.collections: if (!isCosmosVcore) {
    name: item.name
    parent: exportCertMongoDbDatabase
    properties: {
      resource: {
        id: item.name
        shardKey: {
          _id: 'Hash'
        }
      }
      options: isCosmosServerless
        ? {}
        : {
            autoscaleSettings: {
              maxThroughput: item.throughput
            }
          }
    }
  }
]

// UNABLE TO DISABLE PUBLIC ACCESS VIA AVM. SO USING BICEP
resource cosmosDb 'Microsoft.DocumentDB/mongoClusters@2025-07-01-preview' = if (isCosmosVcore) {
  location: location
  name: toLower(cosmosDBName)
  properties: {
    administrator: {
      password: cosmosAdminPassword
      userName: toLower(cosmosDBName)
    }
    authConfig: {
      allowedModes: [
        'NativeAuth'
      ]
    }
    backup: {}
    compute: {
      tier: vCoreTier
    }
    highAvailability: {
      targetMode: vCoreZoneRedundancy
    }
    publicNetworkAccess: 'Disabled'
    serverVersion: serverVersion
    sharding: {
      shardCount: 1
    }
    storage: {
      sizeGb: vCoreStorageSizeInGB
    }
  }
  tags: union(defaultTags, customTags)
}

resource cosmosDbGeoReplica 'Microsoft.DocumentDB/mongoClusters@2025-07-01-preview' = if (isCosmosVcore && isGeoRedundant) {
  location: cosmosReadOnlyLocation
  name: toLower(secondaryCosmosDBName)
  properties: {
    publicNetworkAccess: 'Disabled'
    compute: { tier: vCoreTier }
    ...(geoReplicaExists
      ? {
          serverVersion: serverVersion
        }
      : {
          createMode: 'GeoReplica'
          replicaParameters: {
            sourceResourceId: cosmosDb.id
            sourceLocation: location
          }
        })
  }
  tags: union(defaultTags, customTags, {
    name: toLower(secondaryCosmosDBName)
    Purpose: 'FESMMO-DBS-GeoReplica'
  })
}

resource cosmosDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (isCosmosVcore) {
  name: '${toLower(cosmosDBName)}-diagnosticSettings'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
  scope: cosmosDb
}

resource cosmosGeoReplicaDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (isCosmosVcore && isGeoRedundant) {
  name: '${toLower(secondaryCosmosDBName)}-diagnosticSettings'
  properties: {
    workspaceId: secondaryRegionLaw.id
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
  scope: cosmosDbGeoReplica
}

resource privateEndpointCosmos 'Microsoft.Network/privateEndpoints@2024-03-01' = if (isCosmosVcore) {
  name: '${toUpper(cosmosDBName)}-PE'
  location: location
  tags: privateEndpointTags
  properties: {
    subnet: {
      id: vnet::subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${toUpper(cosmosDBName)}-MongoDB-0'
        properties: {
          privateLinkServiceId: cosmosDb.id
          groupIds: [
            'MongoCluster'
          ]
        }
      }
    ]
  }
  resource privateDnsZoneGroupsCosmos 'privateDnsZoneGroups@2024-03-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'uks-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: ukSouthDnsZoneIdMongoCluster
          }
        }
        {
          name: 'ukw-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: ukWestDnsZoneIdMongoCluster
          }
        }
        {
          name: 'neu-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: northEuDnsZoneIdMongoCluster
          }
        }
        {
          name: 'weu-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: westEuDnsZoneIdMongoCluster
          }
        }
      ]
    }
  }
}

resource privateEndpointCosmosGeoReplica 'Microsoft.Network/privateEndpoints@2024-03-01' = if (isCosmosVcore && isGeoRedundant) {
  name: '${toUpper(secondaryCosmosDBName)}-PE'
  location: cosmosReadOnlyLocation
  tags: union(privateEndpointTags, {
    name: '${toLower(secondaryCosmosDBName)}-PE'
  })
  properties: {
    subnet: {
      id: secondaryVnet::subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${toUpper(secondaryCosmosDBName)}-MongoDB-0'
        properties: {
          privateLinkServiceId: cosmosDbGeoReplica.id
          groupIds: [
            'MongoCluster'
          ]
        }
      }
    ]
  }
  resource privateDnsZoneGroupsCosmosGeo 'privateDnsZoneGroups@2024-03-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'uks-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: ukSouthDnsZoneIdMongoCluster
          }
        }
        {
          name: 'ukw-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: ukWestDnsZoneIdMongoCluster
          }
        }
        {
          name: 'neu-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: northEuDnsZoneIdMongoCluster
          }
        }
        {
          name: 'weu-privatelink-mongodb-cluster'
          properties: {
            privateDnsZoneId: westEuDnsZoneIdMongoCluster
          }
        }
      ]
    }
  }
}

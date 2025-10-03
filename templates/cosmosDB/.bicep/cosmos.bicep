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
param exportCertMongoDbCollection object
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

module cosmosDbThroughput 'br/avm:document-db/database-account:0.15.0' = if (!isCosmosVcore) {
  name: '${toLower(cosmosDBName)}-${deploymentDate}'
  params: {
    name: toLower(cosmosDBName)
    location: location
    tags: union(defaultTags, customTags)
    automaticFailover: true
    databaseAccountOfferType: databaseAccountOfferType
    capabilitiesToAdd: bool(isCosmosServerless)
      ? union(capabilites, ['EnableServerless'])
      : capabilites
    defaultConsistencyLevel: defaultConsistencyLevel
    serverVersion: serverVersion
    enableMultipleWriteLocations: cosmosMultiRegionWrite
    failoverLocations: isGeoRedundant ? union(primaryLocation, secondaryLocation) : primaryLocation
    mongodbDatabases: [
      {
        name: exportCertMongoDbCollection.name
        collections: []
      }
    ]
    zoneRedundant: bool(isPrimaryZoneRedundant)
    backupPolicyType: 'Periodic'
    backupRetentionIntervalInHours: 8
    backupIntervalInMinutes: 240
    backupStorageRedundancy: isGeoRedundant == 'true'
      ? 'Geo'
      : (isPrimaryZoneRedundant == 'true' ? 'Zone' : 'Local')
    networkRestrictions: {
      publicNetworkAccess: 'Disabled'
    }
    privateEndpoints: [
      {
        name: toUpper('${cosmosDBName}-PE')
        service: 'MongoDB'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: ukSouthDnsZoneId
              name: 'uks-privatelink-mongodb'
            }
            {
              privateDnsZoneResourceId: northEuDnsZoneId
              name: 'neu-privatelink-mongodb'
            }
            {
              privateDnsZoneResourceId: westEuDnsZoneId
              name: 'weu-privatelink-mongodb'
            }
            {
              privateDnsZoneResourceId: ukWestDnsZoneId
              name: 'ukw-privatelink-mongodb'
            }
          ]
        }
        subnetResourceId: vnet::subnet.id
        tags: privateEndpointTags
      }
    ]
    diagnosticSettings: [
      {
        name: '${toLower(cosmosDBName)}-diagnosticSettings'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        workspaceResourceId: logAnalytics.id
      }
    ]
  }
}

@batchSize(4)
resource exportCertMongoDbCollections 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2024-11-15' = [
  for item in exportCertMongoDbCollection.collections: if (!isCosmosVcore) {
    name: '${toLower(cosmosDBName)}/mmo_exportcert/${item.name}'
    properties: {
      resource: {
        id: item.name
        indexes: item.indexes
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
    dependsOn: [cosmosDbThroughput]
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

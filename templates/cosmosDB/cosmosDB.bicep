param cosmosDBName string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param environment string
param logAnalyticsWorkspace string
param vnetName string
param vnetResourceGroupName string
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
param cosmosMongoDbCollections string
param isServerless string
param keyVaultName string
param cosmosDbWriteConnStringSecretName string
param cosmosDbReadOnlyConnStringSecretName string
param isPrimaryZoneRedundant string
param isSecondaryZoneRedundant string
param isGeoRedundant string
param isVcore string
@secure()
param cosmosAdminPassword string
param secondaryCosmosDBName string
param secondaryRegionResourceGroup string
param secondaryRegionVnetName string
param secondaryRegionVnetResourceGroupName string
param secondaryRegionPrivateEndpointSubnet string
param secondaryRegionLogAnalyticsName string
param geoReplicaExists string = 'false'
param vCoreTier string
param vCoreZoneRedundancy string
param vCoreStorageSizeInGB string

var cosmosMongoDbCollectionsObj = json(cosmosMongoDbCollections)
var geoReplicaExistsBool = empty(geoReplicaExists) ? false : bool(geoReplicaExists)
var validatedvCoreStorageSizeInGB = empty(vCoreStorageSizeInGB) ? 0 : int(vCoreStorageSizeInGB)
var geoRedundantBool = empty(isGeoRedundant) ? false : bool(isGeoRedundant)

module cosmosDb '.bicep/cosmos.bicep' = {
  name: '${toLower(cosmosDBName)}-deployment-${deploymentDate}'
  params: {
    cosmosDBName: cosmosDBName
    location: location
    environment: environment
    logAnalyticsWorkspace: logAnalyticsWorkspace
    vnetName: vnetName
    vnetResourceGroupName: vnetResourceGroupName
    ukSouthDnsZoneId: ukSouthDnsZoneId
    northEuDnsZoneId: northEuDnsZoneId
    westEuDnsZoneId: westEuDnsZoneId
    ukWestDnsZoneId: ukWestDnsZoneId
    ukSouthDnsZoneIdMongoCluster: ukSouthDnsZoneIdMongoCluster
    northEuDnsZoneIdMongoCluster: northEuDnsZoneIdMongoCluster
    westEuDnsZoneIdMongoCluster: westEuDnsZoneIdMongoCluster
    ukWestDnsZoneIdMongoCluster: ukWestDnsZoneIdMongoCluster
    privateEndpointSubnet: privateEndpointSubnet
    serverVersion: serverVersion
    cosmosMultiRegionWrite: cosmosMultiRegionWrite
    databaseAccountOfferType: databaseAccountOfferType
    defaultConsistencyLevel: defaultConsistencyLevel
    cosmosReadOnlyLocation: cosmosReadOnlyLocation
    cosmosMongoDbCollections: cosmosMongoDbCollectionsObj
    isServerless: isServerless
    isPrimaryZoneRedundant: isPrimaryZoneRedundant
    isSecondaryZoneRedundant: isSecondaryZoneRedundant
    isGeoRedundant: geoRedundantBool
    isVcore: isVcore
    cosmosAdminPassword: cosmosAdminPassword
    secondaryCosmosDBName: secondaryCosmosDBName
    secondaryRegionResourceGroup: secondaryRegionResourceGroup
    secondaryRegionVnetName: secondaryRegionVnetName
    secondaryRegionVnetResourceGroupName: secondaryRegionVnetResourceGroupName
    secondaryRegionPrivateEndpointSubnet: secondaryRegionPrivateEndpointSubnet
    secondaryRegionLogAnalyticsName: secondaryRegionLogAnalyticsName
    geoReplicaExists: geoReplicaExistsBool
    vCoreTier: vCoreTier
    vCoreZoneRedundancy: vCoreZoneRedundancy
    vCoreStorageSizeInGB: validatedvCoreStorageSizeInGB
  }
}

module cosmosDbSecrets '.bicep/cosmosDbSecrets.bicep' = {
  name: 'cosmosDb-secrets-deployment'
  params: {
    keyVaultName: keyVaultName
    cosmosDbName: toLower(cosmosDBName)
    cosmosDbWriteConnStringSecretName: cosmosDbWriteConnStringSecretName
    cosmosDbReadOnlyConnStringSecretName: cosmosDbReadOnlyConnStringSecretName
    isVcore: bool(isVcore)
    cosmosAdminPassword: cosmosAdminPassword
  }
  dependsOn: [
    cosmosDb
  ]
}

using 'cosmosDB.bicep'

param cosmosDBName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-database }}#{{ nc-resource-cosmosdb }}#{{ nc-region-id }}01'
param environment = '#{{ environment }}'

param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'
param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongo }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongo }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongo }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongo }}'

param ukSouthDnsZoneIdMongoCluster = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongoCluster }}'
param northEuDnsZoneIdMongoCluster = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongoCluster }}'
param westEuDnsZoneIdMongoCluster = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongoCluster }}'
param ukWestDnsZoneIdMongoCluster = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkCosmosMongoCluster }}'

param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

param serverVersion = '#{{ cosmosMongoServerversion }}'
param cosmosMultiRegionWrite = false
param databaseAccountOfferType = 'Standard'
param defaultConsistencyLevel = 'Session'
param cosmosReadOnlyLocation = '#{{ secondaryRegion }}'

param keyVaultName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-region-id }}01'
param cosmosDbWriteConnStringSecretName = 'COSMOS-DB-RW-CONNECTION-URI'
param cosmosDbReadOnlyConnStringSecretName = 'COSMOS-DB-RO-CONNECTION-URI'

param isPrimaryZoneRedundant = '#{{ cosmosPrimaryZoneRedundant }}'
param isSecondaryZoneRedundant = '#{{ cosmosSecondaryZoneRedundant }}'
param isServerless = '#{{ cosmosServerless }}'
param isGeoRedundant = '#{{ cosmosGeoRedundant }}'
param isVcore = '#{{ cosmosVcore }}'
param vCoreTier = '#{{ cosmosVcoreTier }}'
param vCoreZoneRedundancy = '#{{ cosmosVcoreZoneRedundancy }}'
param vCoreStorageSizeInGB = '#{{ cosmosVcoreStorageSizeInGB}}'

param exportCertMongoDbCollection = '#{{ cosmosDbCollections }}'
param cosmosAdminPassword = az.getSecret(
  '#{{ subscriptionId }}',
  '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-static-res-region-id }}02',
  '${keyVaultName}',
  'COSMOS-VCORE-ADMIN-PASSWORD'
)

param secondaryCosmosDBName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-database }}#{{ nc-resource-cosmosdb }}1601'
param secondaryRegionResourceGroup = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}1602'
param secondaryRegionVnetName = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}1601'
param secondaryRegionVnetResourceGroupName = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-resourcegroup }}1601'
param secondaryRegionPrivateEndpointSubnet = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}1606'
param secondaryRegionLogAnalyticsName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-analytics }}1601'
param geoReplicaExists = '#{{ geoReplicaExists }}'

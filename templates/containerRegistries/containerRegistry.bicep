@description('The name of the Azure Container Registry')
param registry object
param location string = resourceGroup().location
param createdDate string = utcNow('yyyy-MM-dd')
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param environment string
param vnetName string
param vnetResourceGroupName string
param ukWestDnsZoneId string
param ukSouthDnsZoneId string
param westEuDnsZoneId string
param northEuDnsZoneId string
param acrZoneRedundancy string
param acrSoftDeletePolicyDays string
param acrSoftDeletePolicyStatus string
param acrGeoReplicationEnabled string
param acrServiceConnectionAppRegObjectId string

var defaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'ACR'
  Location: location
}

var customTags = {
  name: registry.name
  Purpose: 'FESMMO-ContainerRegistry'
  type: 'ACR'
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: registry.subnet
  }
}

module containerRegistry 'br/avm:container-registry/registry:0.6.0' = {
  name: '${registry.name}-${deploymentDate}'
  scope: resourceGroup(registry.resourceGroup)
  params: {
    name: toUpper(registry.name)
    location: location
    acrSku: 'Premium'
    tags: union(defaultTags, customTags)
    zoneRedundancy: acrZoneRedundancy
    exportPolicyStatus: 'enabled'
    softDeletePolicyDays: int(acrSoftDeletePolicyDays)
    softDeletePolicyStatus: acrSoftDeletePolicyStatus
    managedIdentities: {
      systemAssigned: true
    }
    networkRuleBypassOptions: 'AzureServices'
    dataEndpointEnabled: true
    networkRuleSetDefaultAction: 'Deny'
    networkRuleSetIpRules: []
    replications: bool(acrGeoReplicationEnabled)
      ? [
          {
            location: 'ukwest'
            name: 'ukwest'
          }
        ]
      : null
    privateEndpoints: [
      {
        name: '${registry.name}-PE'
        service: 'registry'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: ukSouthDnsZoneId
              name: 'uks-privatelink-acr'
            }
            {
              privateDnsZoneResourceId: northEuDnsZoneId
              name: 'neu-privatelink-acr'
            }
            {
              privateDnsZoneResourceId: westEuDnsZoneId
              name: 'weu-privatelink-acr'
            }
            {
              privateDnsZoneResourceId: ukWestDnsZoneId
              name: 'ukw-privatelink-acr'
            }
          ]
        }
        subnetResourceId: vnet::subnet.id
        tags: {
          name: '${registry.name}-PE'
          Environment: environment
        }
      }
    ]
    roleAssignments: [
      {
        principalId: acrServiceConnectionAppRegObjectId
        roleDefinitionIdOrName: 'AcrPull'
      }
      {
        principalId: acrServiceConnectionAppRegObjectId
        roleDefinitionIdOrName: 'AcrPush'
      }
      {
        principalId: acrServiceConnectionAppRegObjectId
        roleDefinitionIdOrName: 'Contributor'
      }
    ]
    publicNetworkAccess: 'Disabled'
  }
}

output registryLoginServer string = containerRegistry.outputs.loginServer
output registryId string = containerRegistry.outputs.resourceId

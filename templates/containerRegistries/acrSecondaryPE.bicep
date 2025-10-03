param location string
param environment string
param acrName string
param acrResourceGroupName string
param vnetName string
param vnetResourceGroupName string
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param privateEndpointSubnet string

var privateEndpointTags = {
  name: '${toLower(acrName)}-PE-SEC'
  Environment: environment
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: privateEndpointSubnet
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
  name: acrName
  scope: resourceGroup(acrResourceGroupName)
}

module privateEndpointCosmos 'br/avm:network/private-endpoint:0.11.0' = {
  name: toUpper('${acrName}-PE-SEC')
  params: {
    name: toUpper('${acrName}-PE-SEC')
    location: location
    tags: privateEndpointTags
    subnetResourceId: vnet::subnet.id
    privateLinkServiceConnections: [
      {
        name: '${toUpper(acrName)}-registry-0'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
    privateDnsZoneGroup: {
      privateDnsZoneGroupConfigs: [
        {
          privateDnsZoneResourceId: ukSouthDnsZoneId
          name: 'uks-privatelink-registry'
        }
        {
          privateDnsZoneResourceId: northEuDnsZoneId
          name: 'neu-privatelink-registry'
        }
        {
          privateDnsZoneResourceId: westEuDnsZoneId
          name: 'weu-privatelink-registry'
        }
        {
          privateDnsZoneResourceId: ukWestDnsZoneId
          name: 'ukw-privatelink-registry'
        }
      ]
    }
  }
}

param location string = resourceGroup().location
param environment string
param keyVaultName string
param keyVaultResourceGroupName string
param vnetName string
param vnetResourceGroupName string
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param privateEndpointSubnet string

var privateEndpointTags = {
  name: '${toLower(keyVaultName)}-PE-SEC'
  Environment: environment
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: privateEndpointSubnet
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}

module keyVaultPE 'br/avm:network/private-endpoint:0.11.0' = {
  name: toUpper('${keyVaultName}-PE-SEC')
  params: {
    name: toUpper('${keyVaultName}-PE-SEC')
    location: location
    tags: privateEndpointTags
    subnetResourceId: vnet::subnet.id
    privateLinkServiceConnections: [
      {
        name: '${toUpper(keyVaultName)}-vault-0'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    privateDnsZoneGroup: {
      privateDnsZoneGroupConfigs: [
        {
          privateDnsZoneResourceId: ukSouthDnsZoneId
          name: 'uks-privatelink-vault'
        }
        {
          privateDnsZoneResourceId: northEuDnsZoneId
          name: 'neu-privatelink-vault'
        }
        {
          privateDnsZoneResourceId: westEuDnsZoneId
          name: 'weu-privatelink-vault'
        }
        {
          privateDnsZoneResourceId: ukWestDnsZoneId
          name: 'ukw-privatelink-vault'
        }
      ]
    }
  }
}

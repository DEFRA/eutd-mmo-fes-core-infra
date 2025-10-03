param location string = resourceGroup().location
param environment string
param storageAccounts string
param skuName string
param accessTier string
param kind string
param vnetName string
param vnetResourceGroupName string
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param ukSouthDnsTableZoneId string
param northEuDnsTableZoneId string
param westEuDnsTableZoneId string
param ukWestDnsTableZoneId string
param ukSouthDnsStorageQueueZoneId string
param northEuDnsStorageQueueZoneId string
param westEuDnsStorageQueueZoneId string
param ukWestDnsStorageQueueZoneId string
param privateEndpointSubnet string
param strAccResourceGroupName string
param subscriptionId string
param subnets array
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')

var storageSuffix = az.environment().suffixes.storage
var strAccArray = json(storageAccounts)

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2024-05-01' existing = {
    name: privateEndpointSubnet
  }
  resource internalSubnets 'subnets' existing = [
    for subnetName in subnets: {
      name: subnetName
    }
  ]
}

var internalSubnetRules = [
  for (subnetName, i) in subnets: {
    action: 'Allow'
    id: vnet::internalSubnets[i].id
  }
]

resource strAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = [
  for (strAcc, i) in strAccArray: if (strAcc.Access == 'public') {
    name: toLower(strAcc.Name)
    scope: resourceGroup(strAccResourceGroupName)
  }
]

module storageAccount 'br/avm:storage/storage-account:0.11.1' = [
  for (strAcc, i) in strAccArray: if (strAcc.Access == 'public') {
    params: {
      name: toLower(strAcc.Name)
      skuName: skuName
      kind: kind
      accessTier: accessTier
      supportsHttpsTrafficOnly: true
      allowBlobPublicAccess: false
      publicNetworkAccess: strAcc.Access == 'public' ? 'Enabled' : 'Disabled'
      networkAcls: {
        virtualNetworkRules: concat(
          strAccount[i].properties.networkAcls.virtualNetworkRules,
          filter(
            internalSubnetRules,
            rule =>
              !(contains(
                map(
                  strAccount[i].properties.networkAcls.virtualNetworkRules,
                  existingRule => existingRule.id
                ),
                rule.id
              ))
          )
        )
      }
    }
    name: '${strAcc.Name}-${deploymentDate}'
    scope: resourceGroup(strAccResourceGroupName)
  }
]

module strAccBlobPE 'br/avm:network/private-endpoint:0.11.0' = [
  for (strAcc, i) in strAccArray: if (strAcc.Access == 'private' && contains(
    strAcc.PrivateEndpoints,
    'blob'
  )) {
    name: toUpper('${strAcc.Name}-blob-PE-SEC')
    params: {
      name: toUpper('${strAcc.Name}-blob-PE-SEC')
      location: location
      tags: {
        name: '${toLower(strAcc.Name)}-blob-PE-SEC'
        Environment: environment
      }
      subnetResourceId: vnet::subnet.id
      privateLinkServiceConnections: [
        {
          name: '${toUpper(strAcc.Name)}-blob-0'
          properties: {
            privateLinkServiceId: resourceId(
              subscriptionId,
              strAccResourceGroupName,
              'Microsoft.Storage/storageAccounts',
              strAcc.Name
            )
            groupIds: [
              'blob'
            ]
          }
        }
      ]
      privateDnsZoneGroup: {
        privateDnsZoneGroupConfigs: [
          {
            privateDnsZoneResourceId: '${ukSouthDnsZoneId}${storageSuffix}'
            name: 'uks-privatelink-blob'
          }
          {
            privateDnsZoneResourceId: '${northEuDnsZoneId}${storageSuffix}'
            name: 'neu-privatelink-blob'
          }
          {
            privateDnsZoneResourceId: '${westEuDnsZoneId}${storageSuffix}'
            name: 'weu-privatelink-blob'
          }
          {
            privateDnsZoneResourceId: '${ukWestDnsZoneId}${storageSuffix}'
            name: 'ukw-privatelink-blob'
          }
        ]
      }
    }
  }
]

module strAccTablePE 'br/avm:network/private-endpoint:0.11.0' = [
  for (strAcc, i) in strAccArray: if (strAcc.Access == 'private' && contains(
    strAcc.PrivateEndpoints,
    'table'
  )) {
    name: toUpper('${strAcc.Name}-table-PE-SEC')
    params: {
      name: toUpper('${strAcc.Name}-table-PE-SEC')
      location: location
      tags: {
        name: '${toLower(strAcc.Name)}-table-PE-SEC'
        Environment: environment
      }
      subnetResourceId: vnet::subnet.id
      privateLinkServiceConnections: [
        {
          name: '${toUpper(strAcc.Name)}-table-0'
          properties: {
            privateLinkServiceId: resourceId(
              subscriptionId,
              strAccResourceGroupName,
              'Microsoft.Storage/storageAccounts',
              strAcc.Name
            )
            groupIds: [
              'table'
            ]
          }
        }
      ]
      privateDnsZoneGroup: {
        privateDnsZoneGroupConfigs: [
          {
            privateDnsZoneResourceId: ukSouthDnsTableZoneId
            name: 'uks-privatelink-table'
          }
          {
            privateDnsZoneResourceId: northEuDnsTableZoneId
            name: 'neu-privatelink-table'
          }
          {
            privateDnsZoneResourceId: westEuDnsTableZoneId
            name: 'weu-privatelink-table'
          }
          {
            privateDnsZoneResourceId: ukWestDnsTableZoneId
            name: 'ukw-privatelink-table'
          }
        ]
      }
    }
  }
]

module strAccQueuePE 'br/avm:network/private-endpoint:0.11.0' = [
  for (strAcc, i) in strAccArray: if (strAcc.Access == 'private' && contains(
    strAcc.PrivateEndpoints,
    'queue'
  )) {
    name: toUpper('${strAcc.Name}-queue-PE-SEC')
    params: {
      name: toUpper('${strAcc.Name}-queue-PE-SEC')
      location: location
      tags: {
        name: '${toLower(strAcc.Name)}-queue-PE-SEC'
        Environment: environment
      }
      subnetResourceId: vnet::subnet.id
      privateLinkServiceConnections: [
        {
          name: '${toUpper(strAcc.Name)}-queue-0'
          properties: {
            privateLinkServiceId: resourceId(
              subscriptionId,
              strAccResourceGroupName,
              'Microsoft.Storage/storageAccounts',
              strAcc.Name
            )
            groupIds: [
              'queue'
            ]
          }
        }
      ]
      privateDnsZoneGroup: {
        privateDnsZoneGroupConfigs: [
          {
            privateDnsZoneResourceId: ukSouthDnsStorageQueueZoneId
            name: 'uks-privatelink-storage-queue'
          }
          {
            privateDnsZoneResourceId: northEuDnsStorageQueueZoneId
            name: 'neu-privatelink-storage-queue'
          }
          {
            privateDnsZoneResourceId: westEuDnsStorageQueueZoneId
            name: 'weu-privatelink-storage-queue'
          }
          {
            privateDnsZoneResourceId: ukWestDnsStorageQueueZoneId
            name: 'ukw-privatelink-storage-queue'
          }
        ]
      }
    }
  }
]

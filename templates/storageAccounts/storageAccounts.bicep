param storageAccounts string
param location string = resourceGroup().location
param skuName string
param accessTier string
param kind string
param environment string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param logAnalyticsWorkspace string
param vnetName string
param vnetResourceGroupName string
param privateEndpointSubnet string
param ukWestDnsZoneId string
param ukSouthDnsZoneId string
param westEuDnsZoneId string
param northEuDnsZoneId string
param ukSouthDnsTableZoneId string
param northEuDnsTableZoneId string
param westEuDnsTableZoneId string
param ukWestDnsTableZoneId string
param ukSouthDnsStorageQueueZoneId string
param northEuDnsStorageQueueZoneId string
param westEuDnsStorageQueueZoneId string
param ukWestDnsStorageQueueZoneId string
param subnets array
param cefasSubnets string
param firewallIps string

var storageSuffix = az.environment().suffixes.storage
var strAccArray = json(storageAccounts)
var cefasSubnetsArray = json(cefasSubnets)
var firewallIpsArray = json(firewallIps)

var defaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'STORAGE'
  Location: location
}

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspace
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource peSubnet 'subnets' existing = {
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
var cefasSubnetRules = [
  for cefasSubnet in cefasSubnetsArray: {
    action: 'Allow'
    id: cefasSubnet
  }
]
var ipRules = [
  for ip in firewallIpsArray: {
    action: 'Allow'
    value: ip
  }
]

module storageAccount 'br/avm:storage/storage-account:0.27.1' = [
  for (strAcc, i) in strAccArray: {
    name: '${strAcc.Name}-${deploymentDate}'
    params: {
      name: toLower(strAcc.Name)
      location: location
      skuName: skuName
      kind: kind
      tags: defaultTags
      accessTier: accessTier
      supportsHttpsTrafficOnly: true
      allowBlobPublicAccess: false
      publicNetworkAccess: strAcc.Access == 'public' ? 'Enabled' : 'Disabled'
      blobServices: {
        containers: map(strAcc.Containers, container => {
          name: container.name
          publicAccess: container.publicAccess
        })
        deleteRetentionPolicyDays: 30
        deleteRetentionPolicyEnabled: true
        lastAccessTimeTrackingPolicyEnabled: true
      }
      tableServices: {
        tables: map(strAcc.Tables, table => {
          name: table.name
        })
      }
      networkAcls: {
        bypass: 'AzureServices'
        defaultAction: 'Deny'
        virtualNetworkRules: strAcc.Access == 'public'
          ? concat(internalSubnetRules, cefasSubnetRules)
          : null
        ipRules: strAcc.Access == 'public' ? ipRules : null
      }
      privateEndpoints: concat(
        (strAcc.Access == 'private' && contains(strAcc.PrivateEndpoints, 'blob'))
          ? [
              {
                name: toUpper('${strAcc.Name}-blob-PE')
                service: 'blob'
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
                subnetResourceId: vnet::peSubnet.id
                tags: {
                  name: toUpper('${strAcc.Name}-blob-PE')
                  Environment: environment
                }
              }
            ]
          : [],
        (strAcc.Access == 'private' && contains(strAcc.PrivateEndpoints, 'table'))
          ? [
              {
                name: toUpper('${strAcc.Name}-table-PE')
                service: 'table'
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
                subnetResourceId: vnet::peSubnet.id
                tags: {
                  name: toUpper('${strAcc.Name}-table-PE')
                  Environment: environment
                }
              }
            ]
          : [],
        (strAcc.Access == 'private' && contains(strAcc.PrivateEndpoints, 'queue'))
          ? [
              {
                name: toUpper('${strAcc.Name}-queue-PE')
                service: 'queue'
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
                subnetResourceId: vnet::peSubnet.id
                tags: {
                  name: toUpper('${strAcc.Name}-queue-PE')
                  Environment: environment
                }
              }
            ]
          : []
      )

      diagnosticSettings: [
        {
          name: '${strAcc.Name}-diagnosticSettings'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          workspaceResourceId: law.id
        }
      ]
    }
  }
]

// Output the storage account name and resource IDs for use in other modules
output storageAccounts array = [
  for (strAcc, i) in strAccArray: {
    name: strAcc.Name
    resourceId: storageAccount[i].outputs.resourceId
  }
]

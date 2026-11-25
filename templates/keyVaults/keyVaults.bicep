param keyVaultName string
param location string = resourceGroup().location
param sku string = 'standard'
param softDeleteRetentionDays int = 90
param purgeProtectionEnabled bool = true
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param environment string
param logAnalyticsWorkspace string
param vnetName string
param vnetResourceGroupName string
param ukSouthDnsZoneId string
param northEuDnsZoneId string
param westEuDnsZoneId string
param ukWestDnsZoneId string
param privateEndpointSubnet string

var defaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'KEYVAULT'
  Location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2025-05-01' existing = {
    name: privateEndpointSubnet
  }
}

resource law 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
  name: logAnalyticsWorkspace
}

module keyVault 'br/avm:key-vault/vault:0.14.0' = {
  name: '${keyVaultName}-${deploymentDate}'
  params: {
    name: toUpper(keyVaultName)
    location: location
    sku: sku
    tags: defaultTags
    publicNetworkAccess: 'Disabled'
    enablePurgeProtection: purgeProtectionEnabled
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionDays
    privateEndpoints: [
      {
        name: toUpper('${keyVaultName}-PE')
        service: 'vault'
        subnetResourceId: vnet::subnet.id
        tags: {
          name: toUpper('${keyVaultName}-PE')
          Environment: environment
        }
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
    ]
    diagnosticSettings: [
      {
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: '${keyVaultName}-diagnosticSettings'
        workspaceResourceId: law.id
      }
    ]
  }
}

output keyVaultId string = keyVault.outputs.resourceId

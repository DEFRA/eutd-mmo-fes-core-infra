param funcAppName string
param environment string
param ephemeral string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param aspName string
param comparams object
param subnetName string
param resourceGroupName string
param primaryRegionResourceGroupName string
param privateEndpointSubnet string
param ukWestDnsZoneId string
param ukSouthDnsZoneId string
param westEuDnsZoneId string
param northEuDnsZoneId string
param logAnalyticsWorkspace string
param webjobsStorageAccount string
param vnetName string
param vnetResourceGroupName string
param slotsEnabled string
param appSettingsSlotKeyValuePairs object
param appSettingsKeyValuePairs object
param appVersions string
param aadclientId string
param aadTenantId string
@secure()
param aadClientSecret string
param aadAppIdUri string

var aadIssuerUrl = 'https://sts.windows.net/${aadTenantId}/v2.0'

var funcAppdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'functionApp'
  Location: location
  Ephemeral: ephemeral
}

var customTags = {
  name: funcAppName
  Purpose: 'FESMMO-ASP'
  type: 'functionApp'
}
var validatedAppVersions = empty(appVersions) ? '[]' : appVersions
var appVersionsArray = json(validatedAppVersions)

var siteConfig = {
  vnetRouteAllEnabled: true
  numberOfWorkers: 2
  httpLoggingEnabled: true
  logsDirectorySizeLimit: 35
  alwaysOn: true
  reserved: true
  acrUseManagedIdentityCreds: true
  http20Enabled: true
  ftpsState: 'Disabled'
  minTlsVersion: '1.3'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets' existing = {
    name: subnetName
  }
  resource peSubnet 'subnets' existing = {
    name: privateEndpointSubnet
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  name: toUpper(aspName)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: toUpper(comparams.appInsightsName)
  scope: resourceGroup(resourceGroupName)
}

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspace
  scope: resourceGroup(resourceGroupName)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: toLower(webjobsStorageAccount)
  scope: resourceGroup(primaryRegionResourceGroupName)
}
module functionapp 'br/avm:web/site:0.9.0' = {
  name: '${funcAppName}-${deploymentDate}'
  params: {
    name: toUpper(funcAppName)
    kind: 'functionapp'
    location: location
    tags: union(funcAppdefaultTags, customTags)
    serverFarmResourceId: appServicePlan.id
    appInsightResourceId: appInsights.id
    appSettingsKeyValuePairs: union(appSettingsKeyValuePairs, {
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${toLower(webjobsStorageAccount)};AccountKey=${storageAccount.listKeys().keys[0].value}'
      APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
      AAD_CLIENTSECRET: aadClientSecret
    })
    authSettingV2Configuration: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'Return401'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            clientId: aadclientId
            clientSecretSettingName: 'AAD_CLIENTSECRET'
            openIdIssuer: aadIssuerUrl
          }
          validation: {
            allowedAudiences: [
              aadAppIdUri
            ]
          }
        }
      }
      platform: {
        enabled: true
      }
    }
    slots: bool(slotsEnabled)
      ? [
          {
            name: 'staging'
            appSettingsKeyValuePairs: union(
              appSettingsKeyValuePairs,
              appSettingsSlotKeyValuePairs,
              {
                AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${toLower(webjobsStorageAccount)};AccountKey=${storageAccount.listKeys().keys[0].value}'
                APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
                AAD_CLIENTSECRET: aadClientSecret
              }
            )
            authSettingV2Configuration: {
              globalValidation: {
                requireAuthentication: true
                unauthenticatedClientAction: 'Return401'
              }
              identityProviders: {
                azureActiveDirectory: {
                  enabled: true
                  registration: {
                    clientId: aadclientId
                    clientSecretSettingName: 'AAD_CLIENTSECRET'
                    openIdIssuer: aadIssuerUrl
                  }
                  validation: {
                    allowedAudiences: [
                      aadAppIdUri
                    ]
                  }
                }
              }
              platform: {
                enabled: true
              }
            }
            siteConfig: union(siteConfig, {
              linuxFxVersion: filter(
                appVersionsArray,
                a => (toUpper(a.Name) == toUpper(funcAppName)) && (a.Slot == true)
              )[0].LinuxFxVersion
            })
            vnetImagePullEnabled: true
            vnetRouteAllEnabled: true
            privateEndpoints: [
              {
                name: toUpper('${funcAppName}-STAGING-PE')
                service: 'sites-staging'
                privateDnsZoneGroup: {
                  privateDnsZoneGroupConfigs: [
                    {
                      privateDnsZoneResourceId: ukSouthDnsZoneId
                      name: 'uks-privatelink-sites'
                    }
                    {
                      privateDnsZoneResourceId: northEuDnsZoneId
                      name: 'neu-privatelink-sites'
                    }
                    {
                      privateDnsZoneResourceId: westEuDnsZoneId
                      name: 'weu-privatelink-sites'
                    }
                    {
                      privateDnsZoneResourceId: ukWestDnsZoneId
                      name: 'ukw-privatelink-sites'
                    }
                  ]
                }
                subnetResourceId: vnet::peSubnet.id
                tags: {
                  name: toUpper('${funcAppName}-STAGING-PE')
                  Environment: environment
                }
              }
            ]
            diagnosticSettings: [
              {
                name: '${funcAppName}-staging-diagnosticSettings'
                metricCategories: [
                  {
                    category: 'AllMetrics'
                    enabled: true
                  }
                ]
                workspaceResourceId: law.id
              }
            ]
          }
        ]
      : []
    publicNetworkAccess: 'Disabled'
    managedIdentities: {
      systemAssigned: true
    }
    httpsOnly: true
    siteConfig: union(siteConfig, {
      linuxFxVersion: filter(
        appVersionsArray,
        a => (toUpper(a.Name) == toUpper(funcAppName)) && (a.Slot != true)
      )[0].LinuxFxVersion
    })
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
    virtualNetworkSubnetId: vnet::subnet.id
    privateEndpoints: [
      {
        name: toUpper('${funcAppName}-PE')
        service: 'sites'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: ukSouthDnsZoneId
              name: 'uks-privatelink-sites'
            }
            {
              privateDnsZoneResourceId: northEuDnsZoneId
              name: 'neu-privatelink-sites'
            }
            {
              privateDnsZoneResourceId: westEuDnsZoneId
              name: 'weu-privatelink-sites'
            }
            {
              privateDnsZoneResourceId: ukWestDnsZoneId
              name: 'ukw-privatelink-sites'
            }
          ]
        }
        subnetResourceId: vnet::peSubnet.id
        tags: {
          name: toUpper('${funcAppName}-PE')
          Environment: environment
          Ephemeral: ephemeral
        }
      }
    ]
    diagnosticSettings: [
      {
        name: '${funcAppName}-diagnosticSettings'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        workspaceResourceId: law.id
      }
    ]
  }
}

resource createdFuncApp 'Microsoft.Web/sites@2024-04-01' existing = if (bool(slotsEnabled)) {
  name: toUpper(funcAppName)
  dependsOn: [
    functionapp
  ]
}

resource slotsStickyConfig 'Microsoft.Web/sites/config@2022-09-01' = if (bool(slotsEnabled)) {
  name: 'slotConfigNames'
  parent: createdFuncApp
  properties: {
    appSettingNames: objectKeys(appSettingsSlotKeyValuePairs)
  }
  dependsOn: [
    createdFuncApp
  ]
}

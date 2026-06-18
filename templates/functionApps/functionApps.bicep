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
param appVersions string
param aadclientId string
param aadTenantId string
@secure()
param aadAppIdUri string
param managedIdentityName string

var aadIssuerUrl = 'https://sts.windows.net/${aadTenantId}/v2.0'
var funcAppdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'functionApp'
  Location: location
}

var customTags = {
  name: funcAppName
  Purpose: 'FESMMO-ASP'
  type: 'functionApp'
  Ephemeral: ephemeral
}

var customTagsMI = {
  name: toUpper(managedIdentityName)
  Purpose: 'Identity'
  type: 'User Assigned Managed Identity'
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
  scmMinTlsVersion: '1.3'
  minTlsCipherSuite: 'TLS_AES_256_GCM_SHA384'
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
// Create the user-assigned managed identity for the function app
module userAssignedIdentity 'br/avm:managed-identity/user-assigned-identity:0.5.1' = {
  name: '${managedIdentityName}-${deploymentDate}'
  params: {
    name: toUpper(managedIdentityName)
    location: location
    tags: union(funcAppdefaultTags, customTagsMI)
  }
}

module functionapp 'br/avm:web/site:0.23.1' = {
  name: '${funcAppName}-${deploymentDate}'
  params: {
    name: toUpper(funcAppName)
    kind: 'functionapp,linux,container'
    location: location
    tags: union(funcAppdefaultTags, customTags)
    serverFarmResourceId: appServicePlan.id
    configs: [
      {
        name: 'appsettings'
        applicationInsightResourceId: appInsights.id
        properties: {
          AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${toLower(webjobsStorageAccount)};AccountKey=${storageAccount.listKeys().keys[0].value}'
          APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
        }
      }
      {
        name: 'authsettingsV2'
        properties: {
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
      }
    ]
    slots: bool(slotsEnabled)
      ? [
          {
            name: 'staging'
            configs: [
              {
                name: 'appsettings'
                applicationInsightResourceId: appInsights.id
                properties: {
                  AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${toLower(webjobsStorageAccount)};AccountKey=${storageAccount.listKeys().keys[0].value}'
                  APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
                }
              }
              {
                name: 'authsettingsV2'
                properties: {
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
              }
            ]
            siteConfig: union(siteConfig, {
              linuxFxVersion: reduce(
                appVersionsArray,
                'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest',
                (cur, next) =>
                  (toUpper(next.Name) == toUpper(funcAppName) && next.Slot == true)
                    ? next.LinuxFxVersion
                    : cur
              )
              acrUserManagedIdentityID: userAssignedIdentity.outputs.clientId
            })
            managedIdentities: {
              systemAssigned: false
              userAssignedResourceIds: [
                userAssignedIdentity.outputs.resourceId
              ]
            }
            keyVaultAccessIdentityResourceId: userAssignedIdentity.outputs.resourceId
            outboundVnetRouting: {
              allTraffic: true
              imagePullTraffic: true
            }
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
      systemAssigned: false
      userAssignedResourceIds: [
        userAssignedIdentity.outputs.resourceId
      ]
    }
    basicPublishingCredentialsPolicies: [
      { name: 'scm', allow: true }
    ]
    keyVaultAccessIdentityResourceId: userAssignedIdentity.outputs.resourceId
    httpsOnly: true
    siteConfig: union(siteConfig, {
      linuxFxVersion: reduce(
        appVersionsArray,
        'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest',
        (cur, next) =>
          (toUpper(next.Name) == toUpper(funcAppName) && next.Slot != true)
            ? next.LinuxFxVersion
            : cur
      )
      acrUserManagedIdentityID: userAssignedIdentity.outputs.clientId
    })
    outboundVnetRouting: {
      allTraffic: true
      imagePullTraffic: true
    }
    virtualNetworkSubnetResourceId: vnet::subnet.id
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

param environment string
param ephemeral string
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param webAppNames string
param appSettingsKeyValuePairs array
param appSettingsSlotKeyValuePairs array
param comparams object
param resourceGroupName string
param logAnalyticsWorkspace string
param vnetName string
param vnetResourceGroupName string
param privateEndpointSubnet string
param ukWestDnsZoneId string
param ukSouthDnsZoneId string
param westEuDnsZoneId string
param northEuDnsZoneId string
param slotsEnabled string
param frontDoorId string
param appVersions string

var webAppNamesArray = json(webAppNames)
var validatedAppVersions = empty(appVersions) ? '[]' : appVersions
var appVersionsArray = json(validatedAppVersions)
var ephemeralFlag = bool(ephemeral)

var WebAppdefaultTags = {
  ServiceCode: 'FES'
  ServiceName: 'MMO'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'Web'
  Location: location
  Ephemeral: ephemeral
}

var customTagsForWebApp = [
  for (webAppName, i) in webAppNamesArray: {
    name: toUpper(webAppName.Name)
    Purpose: 'FESMMO-ASP'
    type: 'WebApp'
  }
]

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
    name: privateEndpointSubnet
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: toUpper(comparams.appInsightsName)
  scope: resourceGroup(resourceGroupName)
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspace
  scope: resourceGroup(resourceGroupName)
}

// Create Web Apps in batches
@batchSize(2)
module webApp 'br/avm:web/site:0.19.3' = [
  for (app, i) in webAppNamesArray: {
    name: '${app.Name}-${deploymentDate}'
    params: {
      name: toUpper(app.Name)
      location: location
      kind: 'app,linux,container'
      serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', app.ASP)
      siteConfig: union(siteConfig, {
        linuxFxVersion: filter(
          appVersionsArray,
          a => (toUpper(a.Name) == toUpper(app.Name)) && (a.Slot != true)
        )[0].LinuxFxVersion
      })
      configs: [
        {
          name: 'appsettings'
          properties: union(appSettingsKeyValuePairs[i], {
            INSTRUMENTATION_KEY: appInsights.properties.InstrumentationKey
            APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
          })
        }
      ]
      slots: bool(slotsEnabled)
        ? [
            {
              name: 'staging'
              configs: [
                {
                  name: 'appsettings'
                  properties: union(
                    appSettingsKeyValuePairs[i],
                    appSettingsSlotKeyValuePairs[i],
                    {
                      INSTRUMENTATION_KEY: appInsights.properties.InstrumentationKey
                      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
                    }
                  )
                }
              ]
              outboundVnetRouting: {
                allTraffic: true
                imagePullTraffic: true
              }
              siteConfig: union(siteConfig, {
                linuxFxVersion: filter(
                  appVersionsArray,
                  a => (toUpper(a.Name) == toUpper(app.Name)) && (a.Slot == true)
                )[0].LinuxFxVersion
              })
              publicNetworkAccess: bool(app.IsFrontEnd) ? 'Enabled' : 'Disabled'
              privateEndpoints: bool(app.IsFrontEnd)
                ? []
                : [
                    {
                      name: toUpper('${app.Name}-STAGING-PE')
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
                      subnetResourceId: vnet::subnet.id
                      tags: {
                        name: toUpper('${app.Name}-PE')
                        Environment: environment
                      }
                    }
                  ]
              diagnosticSettings: [
                {
                  name: '${app.Name}-staging-diagnosticSettings'
                  metricCategories: [
                    {
                      category: 'AllMetrics'
                      enabled: true
                    }
                  ]
                  workspaceResourceId: logAnalytics.id
                }
              ]
            }
          ]
        : []
      publicNetworkAccess: (ephemeralFlag && bool(app.IsFrontEnd)) ? 'Enabled' : 'Disabled'
      httpsOnly: true
      outboundVnetRouting: {
        imagePullTraffic: true
        allTraffic: true
        contentShareTraffic: false
      }
      clientAffinityEnabled: false
      tags: union(WebAppdefaultTags, customTagsForWebApp[i])
      managedIdentities: {
        systemAssigned: true
      }
      virtualNetworkSubnetResourceId: resourceId(
        vnetResourceGroupName,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetName,
        app.Subnet
      )
      privateEndpoints: [
        {
          name: toUpper('${app.Name}-PE')
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
          subnetResourceId: vnet::subnet.id
          tags: {
            name: toUpper('${app.Name}-PE')
            Environment: environment
            Ephemeral: ephemeral
          }
        }
      ]
      diagnosticSettings: [
        {
          name: '${app.Name}-diagnosticSettings'
          metricCategories: [
            {
              category: 'AllMetrics'
              enabled: true
            }
          ]
          workspaceResourceId: logAnalytics.id
        }
      ]
    }
  }
]

resource createdWebApps 'Microsoft.Web/sites@2024-04-01' existing = [
  for (app, i) in webAppNamesArray: if (bool(slotsEnabled)) {
    name: toUpper(app.Name)
    dependsOn: [
      webApp[i]
    ]
  }
]

resource slotsStickyConfig 'Microsoft.Web/sites/config@2022-09-01' = [
  for (app, i) in webAppNamesArray: if (bool(slotsEnabled)) {
    name: 'slotConfigNames'
    parent: createdWebApps[i]
    properties: {
      appSettingNames: objectKeys(appSettingsSlotKeyValuePairs[i])
    }
    dependsOn: [
      createdWebApps[i]
    ]
  }
]

resource createdStagingSlots 'Microsoft.Web/sites/slots@2024-04-01' existing = [
  for (app, i) in webAppNamesArray: if (bool(slotsEnabled)) {
    name: 'staging'
    parent: createdWebApps[i]
    dependsOn: [
      webApp[i]
    ]
  }
]

resource stagingSlotConfig 'Microsoft.Web/sites/slots/config@2024-04-01' = [
  for (app, i) in webAppNamesArray: if (bool(slotsEnabled)) {
    name: 'web'
    parent: createdStagingSlots[i]
    properties: {
      ipSecurityRestrictions: bool(app.IsFrontEnd)
        ? [
            {
              ipAddress: 'AzureFrontDoor.Backend'
              action: 'Allow'
              tag: 'ServiceTag'
              priority: 101
              name: 'FrontDoor'
              description: 'Allow FrontDoor Backend connection'
              headers: {
                'x-azure-fdid': [
                  frontDoorId
                ]
              }
            }
          ]
        : []
      ipSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsUseMain: true
    }
    dependsOn: [
      createdStagingSlots[i]
    ]
  }
]

resource webAppsConfig 'Microsoft.Web/sites/config@2024-04-01' = [
  for (app, i) in webAppNamesArray: if (ephemeralFlag) {
    name: 'web'
    parent: createdWebApps[i]
    properties: {
      ipSecurityRestrictions: bool(app.IsFrontEnd)
        ? [
            {
              ipAddress: 'AzureFrontDoor.Backend'
              action: 'Allow'
              tag: 'ServiceTag'
              priority: 101
              name: 'FrontDoor'
              description: 'Allow FrontDoor Backend connection'
              headers: {
                'x-azure-fdid': [
                  frontDoorId
                ]
              }
            }
          ]
        : []
      ipSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsUseMain: true
    }
    dependsOn: [
      createdWebApps[i]
    ]
  }
]

output webAppIds array = [
  for (appName, i) in webAppNamesArray: {
    name: appName.Name
    resourceId: webApp[i].outputs.resourceId
  }
]

using 'functionApps.bicep'

param aspName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appserviceplan }}#{{ nc-region-id }}05'
param environment = '#{{ environment }}'
param ephemeral = '#{{ ephemeral }}'
param funcAppName = '#{{ functionAppName }}'
param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param primaryRegionResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-static-res-region-id }}02'
param subnetName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}05'
param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'

param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkSites }}'

param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'
param webjobsStorageAccount = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}03'

param comparams = {
  keyVaultName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-static-res-region-id }}01'
  appInsightsName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appinsights }}#{{ nc-region-id }}01'
}
param aadTenantId = '#{{ aadTenantId }}'
param aadclientId = az.getSecret(
  '#{{ subscriptionId }}',
  '${primaryRegionResourceGroupName}',
  '${comparams.keyVaultName}',
  'AAD-CLIENTID'
)
param aadAppIdUri = '#{{ aadAppIdUri }}'
param slotsEnabled = '#{{ slotsEnabled }}'
param appVersions = '#{{ appVersions }}'

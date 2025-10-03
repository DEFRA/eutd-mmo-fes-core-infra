using 'logicApps.bicep'

param environment = '#{{ environment }}'
param ephemeral = '#{{ ephemeral }}'
param comparams = {
  appInsightsName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appinsights }}#{{ nc-region-id }}01'
  serviceBusName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-servicebus }}#{{ nc-region-id }}01'
}

param commonApiContName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02-api-connection-01'
param storageApiContName = '#{{ environment }}#{{ nc-deptService }}referencedata-api-connection-01'
param serviceBusApiContName = '#{{ environment }}mmoservicebus-api-connection-01'
param refedataStorageAccountName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}03'

param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param primaryRegionResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-static-res-region-id }}02'
param subnetName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}07'
param dynamicsOrgName = '#{{ dynamicsOrgName }}'

param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'

param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

param logicApps = '#{{ logicApps }}'

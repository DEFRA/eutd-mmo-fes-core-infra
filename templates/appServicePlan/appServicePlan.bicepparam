using 'appServicePlan.bicep'

param environment = '#{{ environment }}'
param aspNames = '#{{ aspNames }}'
param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'
param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param skuCapacity = '#{{ aspSkuCapacity }}'
param zoneRedundant = '#{{ aspZoneRedundant }}'
param ephemeral = '#{{ ephemeral }}'

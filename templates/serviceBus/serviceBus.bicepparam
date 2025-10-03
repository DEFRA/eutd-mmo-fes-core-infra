using 'serviceBus.bicep'

param serviceBusName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-servicebus }}#{{ nc-region-id }}01'
param environment = '#{{ environment }}'
param logAnalyticsName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-analytics }}#{{ nc-region-id }}01'
param resourceGroupName = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param messageLockDuration = 'PT4M'
param serviceBusZoneRedundant = '#{{ serviceBusZoneRedundant }}'

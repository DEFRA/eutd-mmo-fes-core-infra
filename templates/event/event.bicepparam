using 'event.bicep'

param eventHubNamespaceName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-resource-eventhub }}#{{ nc-region-id }}03'
param eventHubName = 'insights-application-logs'
param logAnalyticsName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-analytics }}#{{ nc-region-id }}01'
param environment = '#{{ environment }}'
param ehbZoneRedundant = '#{{ ehbZoneRedundant }}'

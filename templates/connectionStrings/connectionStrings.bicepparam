using 'connectionStrings.bicep'

param keyVaultName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-static-res-region-id }}01'

param redisCacheName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-rediscachename }}#{{ nc-region-id }}01'
param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'
param serviceBusName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-servicebus }}#{{ nc-region-id }}01'
param exportCertStorageName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}01'
param refDataStorageName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}02'
param eventHubNamespaceName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-resource-eventhub }}#{{ nc-region-id }}03'
param eventHubResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param eventHubName = 'insights-application-logs'
param eventHubPolicyName = 'QRADAR_APP'

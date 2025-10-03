param keyVaultName string
param redisCacheName string
param resourceGroupName string
param serviceBusName string
param exportCertStorageName string
param refDataStorageName string
param eventHubName string
param eventHubNamespaceName string
param eventHubResourceGroupName string
param eventHubPolicyName string

var authRuleResourceId = '${serviceBus.id}/authorizationRules/RootManageSharedAccessKey'
var redisPrimaryKey = redisCache.listKeys().primaryKey
var redisHostName = redisCache.properties.hostName

resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusName
  scope: resourceGroup(resourceGroupName)
}

resource redisCache 'Microsoft.Cache/redis@2024-03-01' existing = {
  name: redisCacheName
  scope: resourceGroup(resourceGroupName)
}

resource exportCertStorageAcc 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: exportCertStorageName
}

resource refDataStorageAcc 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: refDataStorageName
}

resource eventhubRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2024-01-01' existing = {
  name: '${eventHubNamespaceName}/${eventHubName}/${eventHubPolicyName}'
  scope: resourceGroup(eventHubResourceGroupName)
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource servicebusSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'SERVICEBUS-CONNECTION-STRING'
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: listKeys(authRuleResourceId, '2024-01-01').primaryConnectionString
  }
}

resource redisSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'REDIS-PASSWORD'
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: redisPrimaryKey
  }
}

resource redisSecret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'REDIS-CONNECTION-STRING'
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: 'redis://:${redisPrimaryKey}@${redisHostName}:6380'
  }
}

resource exportCertStorageSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'EXPORTCERT-STORAGE-CONNECTION-STRING'
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: 'DefaultEndpointsProtocol=https;AccountName=${toLower(exportCertStorageAcc.name)};AccountKey=${exportCertStorageAcc.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
  }
}

resource refDataStorageSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'REFDATA-STORAGE-CONNECTION-STRING'
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: 'DefaultEndpointsProtocol=https;AccountName=${toLower(refDataStorageAcc.name)};AccountKey=${refDataStorageAcc.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
  }
}

resource eventHubConnectionSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'EVENTHUB-CONNECTION-STRING'
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: eventhubRule.listkeys().primaryConnectionString
  }
}

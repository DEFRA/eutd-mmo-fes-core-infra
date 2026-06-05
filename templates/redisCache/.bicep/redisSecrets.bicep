param keyVaultName string
param redisPasswordSecretName string
param redisConnectionStringSecretName string
param redisHostNameSecretName string

@secure()
param redisPassword string

@secure()
param redisConnectionString string

param redisHostName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource redisPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: redisPasswordSecretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: redisPassword
  }
}

resource redisConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: redisConnectionStringSecretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: redisConnectionString
  }
}

resource redisHostNameSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: redisHostNameSecretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: redisHostName
  }
}

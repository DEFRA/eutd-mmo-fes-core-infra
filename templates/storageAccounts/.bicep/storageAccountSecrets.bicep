param keyVaultName string
param exportCertSecretName string
param refDataSecretName string

@secure()
param exportCertConnectionString string

@secure()
param refDataConnectionString string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource exportCertStorageSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: exportCertSecretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: exportCertConnectionString
  }
}

resource refDataStorageSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: refDataSecretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: refDataConnectionString
  }
}

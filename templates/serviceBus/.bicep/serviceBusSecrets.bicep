param keyVaultName string
param secretName string

@secure()
param serviceBusConnectionString string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource serviceBusSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: serviceBusConnectionString
  }
}

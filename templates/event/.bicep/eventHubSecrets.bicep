param keyVaultName string
param secretName string
param authorizationRuleResourceId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource eventHubSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: listKeys(authorizationRuleResourceId, '2024-01-01').primaryConnectionString
  }
}

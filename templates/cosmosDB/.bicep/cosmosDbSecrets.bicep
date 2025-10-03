param keyVaultName string
param cosmosDbName string
param cosmosDbWriteConnStringSecretName string
param cosmosDbReadOnlyConnStringSecretName string
param isVcore bool
@secure()
param cosmosAdminPassword string

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = if (!isVcore) {
  name: cosmosDbName
}

resource cosmosDbVcore 'Microsoft.DocumentDB/mongoClusters@2025-04-01-preview' existing = if (isVcore) {
  name: toLower(cosmosDbName)
}

resource keyvault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

var cosmosRWConnString = !isVcore
  ? cosmosDb.listConnectionStrings().connectionStrings[0].connectionString
  : replace(
      replace(
        cosmosDbVcore.listConnectionStrings().connectionStrings[0].connectionString,
        '<user>',
        cosmosDbName
      ),
      '<password>',
      uriComponent(cosmosAdminPassword)
    )

resource addCosmosWriteConnStringToKeyVault 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyvault
  name: cosmosDbWriteConnStringSecretName
  properties: {
    value: cosmosRWConnString
    contentType: 'text/plain'
  }
}

resource addCosmosReadOnlyConnStringToKeyVault 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (!isVcore) {
  parent: keyvault
  name: cosmosDbReadOnlyConnStringSecretName
  properties: {
    value: cosmosDb.listConnectionStrings().connectionStrings[2].connectionString
    contentType: 'text/plain'
  }
}

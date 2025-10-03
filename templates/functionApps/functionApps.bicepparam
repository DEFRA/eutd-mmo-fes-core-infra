using 'functionApps.bicep'

param aspName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appserviceplan }}#{{ nc-region-id }}05'
param environment = '#{{ environment }}'
param ephemeral = '#{{ ephemeral }}'
param funcAppName = '#{{ functionAppName }}'
param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02'
param primaryRegionResourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-static-res-region-id }}02'
param subnetName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}05'
param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'

param privateEndpointSubnet = '#{{ privateEndpointSubnet }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkSites }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkSites }}'

param logAnalyticsWorkspace = '#{{ logAnalyticsWorkspace }}'
param webjobsStorageAccount = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-storageaccount }}#{{ nc-static-res-region-id }}03'

param comparams = {
  keyVaultName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-keyvault }}#{{ nc-static-res-region-id }}01'
  appInsightsName: '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appinsights }}#{{ nc-region-id }}01'
}
param aadTenantId = '#{{ aadTenantId }}'
param aadclientId = az.getSecret(
  '#{{ subscriptionId }}',
  '${primaryRegionResourceGroupName}',
  '${comparams.keyVaultName}',
  'AAD-CLIENTID'
)
param aadClientSecret = az.getSecret(
  '#{{ subscriptionId }}',
  '${primaryRegionResourceGroupName}',
  '${comparams.keyVaultName}',
  'AAD-CLIENTSECRET'
)
param aadAppIdUri = '#{{ aadAppIdUri }}'

param slotsEnabled = '#{{ slotsEnabled }}'
param appVersions = '#{{ appVersions }}'
param appSettingsSlotKeyValuePairs = {
  DATA_READER_URL: toLower('https://#{{ environment }}-#{{ repoName1 }}-#{{ nc-resource-webapp }}-staging.azurewebsites.net/v1/jobs/landings')
}

param appSettingsKeyValuePairs = {
  CRONTIME: '#{{ REF_DATA_READER_REFRESH_REPORT_JOB }}'
  DATA_READER_URL: toLower('https://#{{ environment }}-#{{ repoName1 }}-#{{ nc-resource-webapp }}.azurewebsites.net/v1/jobs/landings')
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'node'
  NUMBER_OF_RETRIES: '4'
  RETRY_DELAY_IN_MS: '300000'
  TIMEOUT_IN_MS: '600000'
  WEBSITE_HTTPLOGGING_RETENTION_DAYS: '5'
  WEBSITE_NODE_DEFAULT_VERSION: '~18'
  WEBSITE_RUN_FROM_PACKAGE: '1'
  WEBSITE_TIME_ZONE: 'UTC'
  BATCH_CERTIFICATES_NUMBER: '#{{ batchCertificatesNumber }}'
  DB_NAME: 'mmo_exportcert'
  DB_CONNECTION_URI: '@Microsoft.KeyVault(VaultName=${comparams.keyVaultName};SecretName=COSMOS-DB-RW-CONNECTION-URI)'
  QUERY_START_DATE: '#{{ queryStartDate }}'
  QUERY_END_DATE: '#{{ queryEndDate }}'
  BUSINESS_CONTINUITY_URL: '#{{ businessContinuityUrl }}'
  BUSINESS_CONTINUITY_KEY: '#{{ businessContinuityKey }}'
  API_NAME: '/api/certificates'
  WEBSITE_AUTH_AAD_ALLOWED_TENANTS: '#{{ aadAllowedTenants }}'
}

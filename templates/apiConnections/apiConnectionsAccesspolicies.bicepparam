using 'apiConnectionsAccesspolicies.bicep'

param logicApps = '#{{ logicApps }}'
param tenantId = '#{{ defraTenantId }}'

param storageConnection = '#{{ environment }}#{{ nc-deptService }}referencedata-api-connection-01'
param serviceBusConnection = '#{{ environment }}mmoservicebus-api-connection-01'
param CommonApiContName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}02-api-connection-01'

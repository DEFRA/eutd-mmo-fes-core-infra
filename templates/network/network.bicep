param vnetName string
param addressPrefixes array
param location string = resourceGroup().location
param environment string
param subnets array
param dnsServers string

param routeTableObject object
param nsgObject object
param routeTableRoutes string
param nsgRules string

param customTags object

var defaultTags = {
  ServiceCode: 'MMO'
  ServiceName: 'FES'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'NETWORK'
  Location: location
}

param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')

var virtualNetworkDeployment = '${vnetName}-${deploymentDate}'
var serviceEndpoints = [
  'Microsoft.ContainerRegistry'
  'Microsoft.AzureActiveDirectory'
  'Microsoft.KeyVault'
  'Microsoft.ServiceBus'
  'Microsoft.Sql'
  'Microsoft.AzureCosmosDB'
  'Microsoft.Storage'
  'Microsoft.Web'
  'Microsoft.EventHub'
]

var routeTable = union(routeTableObject, {
  routes: json(routeTableRoutes)
})
var nsg = union(nsgObject, {
  rules: json(nsgRules)
})

module routeTableInstance 'br/avm:network/route-table:0.4.0' = {
  name: 'routeTableDeployment'
  params: {
    name: routeTable.name
    location: location
    tags: union(defaultTags, routeTable.customTags)
    routes: routeTable.routes
    disableBgpRoutePropagation: true
  }
}

module networkSecurityGroup 'br/avm:network/network-security-group:0.5.0' = {
  name: 'nsgDeployment'
  params: {
    name: nsg.name
    location: location
    tags: union(defaultTags, nsg.customTags)
    securityRules: nsg.rules
  }
}

module virtualNetwork 'br/avm:network/virtual-network:0.4.0' = {
  name: virtualNetworkDeployment
  params: {
    name: vnetName
    addressPrefixes: addressPrefixes
    location: location
    tags: union(defaultTags, customTags)
    subnets: [
      for item in subnets: {
        name: item.name
        addressPrefix: item.addressPrefix
        serviceEndpoints: serviceEndpoints
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegation: item.delegation
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
        routeTableResourceId: routeTableInstance.outputs.resourceId
      }
    ]
    dnsServers: json(dnsServers)
  }
}

output vnetId string = virtualNetwork.outputs.resourceId

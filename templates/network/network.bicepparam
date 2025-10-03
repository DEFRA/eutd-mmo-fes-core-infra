using 'network.bicep'

param vnetName = '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ nc-region-id }}01'
param addressPrefixes = [
  '#{{ vnetRange }}'
]
param environment = '#{{ environmentName }}'
param subnets = [
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}01'
    addressPrefix: '#{{ subnet01Range }}'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}02'
    addressPrefix: '#{{ subnet02Range }}'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}03'
    addressPrefix: '#{{ subnet03Range }}'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}04'
    addressPrefix: '#{{ subnet04Range }}'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}05'
    addressPrefix: '#{{ subnet05Range }}'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}06'
    addressPrefix: '#{{ subnet06Range }}'
    delegation: ''
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}07'
    addressPrefix: '#{{ subnet07Range }}'
    delegation: 'Microsoft.Web/serverFarms'
  }
]
param dnsServers = '#{{ dnsServers }}'
param customTags = {
  Name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ nc-region-id }}01'
  Purpose: '#{{ #{{ nc-deptService }} }}-VNet'
}

param routeTableObject = {
  name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-routetable }}#{{ nc-region-id }}01'
  routes: []
  customTags: {
    Name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-routetable }}#{{ nc-region-id }}01'
    Purpose: '#{{ #{{ nc-deptService }} }}-RouteTable'
  }
}
param routeTableRoutes = '#{{ networkRouteTableRoutes }}'

param nsgObject = {
  name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-nsg }}#{{ nc-region-id }}01'
  rules: []
  customTags: {
    Name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-nsg }}#{{ nc-region-id }}01'
    Purpose: '#{{ #{{ nc-deptService }} }}-Networksecurity'
  }
}
param nsgRules = '#{{ networkNsgRules }}'

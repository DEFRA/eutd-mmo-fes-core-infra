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
  }
  {
    name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-subnet }}#{{ nc-region-id }}02'
    addressPrefix: '#{{ subnet02Range }}'
  }
]

param dnsServers = '#{{ dnsServers }}'
param customTags = {
  Name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-virtualnetwork }}#{{ nc-region-id }}01'
  Purpose: '#{{ #{{ nc-deptService }} }}-VNet'
}

param routeTable = {
  name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-routetable }}#{{ nc-region-id }}01'
  routes: [
    {
      name: 'defaultRoute'
      properties: {
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: '#{{ virtualApplianceIp }}'
      }
    }
    {
      name: 'AzureKMS'
      properties: {
        addressPrefix: '23.102.135.246/32'
        nextHopType: 'Internet'
        hasBgpOverride: false
      }
    }
    {
      name: 'AzureKMS1'
      properties: {
        addressPrefix: '20.118.99.224/32'
        nextHopType: 'Internet'
        hasBgpOverride: false
      }
    }
    {
      name: 'AzureKMS2'
      properties: {
        addressPrefix: '40.83.235.53/32'
        nextHopType: 'Internet'
        hasBgpOverride: false
      }
    }
  ]
  customTags: {
    Name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-routetable }}#{{ nc-region-id }}01'
    Purpose: '#{{ #{{ nc-deptService }} }}-RouteTable'
  }
}

param nsg = {
  name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-nsg }}#{{ nc-region-id }}01'
  rules: [
    {
      name: 'allow-active-directory-inbound-neu'
      properties: {
        access: 'Allow'
        description: 'Default CSC Ruleset'
        destinationAddressPrefix: '*'
        destinationPortRange: '*'
        direction: 'Inbound'
        priority: 103
        protocol: '*'
        sourceAddressPrefixes: [
          '10.205.0.4'
          '10.205.0.5'
          '10.205.0.20'
          '10.206.64.116'
          '10.206.64.117'
          '10.206.66.116'
          '10.206.66.117'
          '10.176.0.4'
          '10.176.0.5'
          '10.184.0.4'
          '10.184.0.5'
        ]
        sourcePortRange: '*'
      }
    }
    {
      name: 'allow-all-LogicMonitor-inbound'
      properties: {
        access: 'Allow'
        description: 'Default CSC Ruleset'
        destinationAddressPrefix: '*'
        destinationPortRange: '*'
        direction: 'Inbound'
        priority: 305
        protocol: '*'
        sourceAddressPrefixes: [
          '10.204.0.136'
          '10.204.0.137'
          '10.204.2.136'
          '10.204.2.137'
          '10.176.14.136'
          '10.176.14.137'
          '10.184.14.136'
          '10.184.14.137'
        ]
        sourcePortRange: '*'
      }
    }
    {
      name: 'CSC-Allow_LogicMonitor_Public_Check-inbound'
      properties: {
        access: 'Allow'
        description: 'Default CSC Ruleset'
        destinationAddressPrefix: '*'
        destinationPortRange: '*'
        direction: 'Inbound'
        priority: 316
        protocol: 'Tcp'
        sourceAddressPrefixes: [
          '52.169.155.125'
          '52.164.227.127'
          '13.95.143.135'
          '52.233.139.63'
          '51.132.12.126'
          '51.132.12.247'
          '51.141.50.174'
          '51.141.51.22'
        ]
        sourcePortRange: '443'
      }
    }
    {
      name: 'AllowDevopsAgent443Inbound'
      properties: {
        access: 'Allow'
        description: 'Allow devops agents access to deploy to function app'
        destinationAddressPrefix: '*'
        destinationPortRange: '*'
        direction: 'Inbound'
        priority: 317
        protocol: 'Tcp'
        sourceAddressPrefixes: [
          '10.178.146.32/27'
          '10.205.185.0/24'
        ]
        sourcePortRange: '443'
      }
    }
  ]
  customTags: {
    Name: '#{{ environmentName }}#{{ nc-deptService }}#{{ nc-function-network }}#{{ nc-resource-nsg }}#{{ nc-region-id }}01'
    Purpose: '#{{ #{{ nc-deptService }} }}-Networksecurity'
  }
}

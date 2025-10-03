using 'containerRegistry.bicep'

param registry = {
  name: '#{{ acrName }}'
  resourceGroup: '#{{ acrResourceGroup }}'
  subnet: '#{{ acrSubnet }}'
}

param environment = '#{{ environment }}'

param vnetName = '#{{ vnetName }}'
param vnetResourceGroupName = '#{{ vnetResourceGroupName }}'

param ukSouthDnsZoneId = '#{{ ukSouthDnsZoneIdPrefix }}/#{{ privateLinkAcr }}'
param northEuDnsZoneId = '#{{ northEuDnsZoneIdPrefix }}/#{{ privateLinkAcr }}'
param westEuDnsZoneId = '#{{ westEuDnsZoneIdPrefix }}/#{{ privateLinkAcr }}'
param ukWestDnsZoneId = '#{{ ukWestDnsZoneIdPrefix }}/#{{ privateLinkAcr }}'

param acrZoneRedundancy = '#{{ acrZoneRedundancy }}'
param acrSoftDeletePolicyDays = '#{{ acrSoftDeletePolicyDays }}'
param acrSoftDeletePolicyStatus = '#{{ acrSoftDeletePolicyStatus }}'
param acrGeoReplicationEnabled = '#{{ acrGeoReplicationEnabled }}'
param acrServiceConnectionAppRegObjectId = '#{{ acrServiceConnectionAppRegObjectId }}'

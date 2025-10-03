using 'appInsights.bicep'

param environment = '#{{ environment }}'
param appInsightsName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appinsights }}#{{ nc-region-id }}01'
param logAnalyticsName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-analytics }}#{{ nc-region-id }}01'
param testsEndpoints = {
  endpoints: [
    {
      name: 'AdminSiteAvailability'
      displayName: '#{{ environment }}-Fish-Exports-Admin-to-AAD-Login-Screen-Availability'
      description: 'Admin Site Availability Test'
      id: 'AdminTest'
      url: '#{{ internalAdminFrontendBaseUrl }}/'
      ssl: false
      sslLife: null
      severity: 1
      Enabled: true
    }
    {
      name: 'PublicSiteAvailability'
      displayName: '#{{ environment }}-Fish-Exports-to-GovGateway-Availability'
      description: 'Public Site Availability Test'
      id: 'PublicTest'
      url: '#{{ externalFrontendBaseUrl }}/'
      ssl: false
      sslLife: null
      severity: 1
      Enabled: false
    }
    {
      name: 'SSLExpiryWarning'
      displayName: '#{{ environment }}-Fish-Exports-SSL-Certificate-Expiry-Warning'
      description: 'SSL Expiry Warning Test'
      id: 'SSLExpiry'
      url: '#{{ externalFrontendBaseUrl }}/404'
      ssl: true
      sslLife: 30
      severity: 2
      Enabled: true
    }
    {
      name: 'SSLValidity'
      displayName: '#{{ environment }}-Fish-Exports-SSL-Certificate-Validity'
      description: 'SSL Validity Test'
      id: 'SSL Validity Test'
      url: '#{{ externalFrontendBaseUrl }}/404'
      ssl: true
      sslLife: 1
      severity: 1
      Enabled: true
    }
    {
      name: 'DynamicsAvailability'
      displayName: '#{{ environment }}-Fish-Exports-CaseManagement-Availability'
      description: 'Dynamics CM Availability Test'
      id: 'DynamicsTest'
      url: '#{{ dynamicsOrgName }}/_static/Tools/Diagnostics/random100x100.jpg'
      ssl: false
      sslLife: null
      severity: 1
      Enabled: true
    }
  ]
}

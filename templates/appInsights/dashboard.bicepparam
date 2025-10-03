using './dashboard.bicep'

param dashboardName = '#{{ environment }}-FES-APPS-DASHBOARD'
param resourceGroupName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-resourcegroup }}#{{ nc-region-id }}01'
param aspNames = '#{{ aspNames }}'
param logicAppAspName = '#{{ environment }}#{{ nc-deptService }}#{{ nc-function-infrastructure }}#{{ nc-resource-appserviceplan }}#{{ nc-resource-logicapps }}#{{ nc-region-id }}01'

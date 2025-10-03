using './acrRoleAssignments.bicep'

param webAppNames = [
  '#{{ appEnvironment }}-#{{ repoName1 }}-#{{ nc-resource-webapp }}'
  '#{{ appEnvironment }}-#{{ repoName2 }}-#{{ nc-resource-webapp }}'
  '#{{ appEnvironment }}-#{{ repoName3 }}-#{{ nc-resource-webapp }}'
  '#{{ appEnvironment }}-#{{ repoName4 }}-#{{ nc-resource-webapp }}'
  '#{{ appEnvironment }}-#{{ repoName5 }}-#{{ nc-resource-webapp }}'
  '#{{ appEnvironment }}-#{{ repoName6 }}-#{{ nc-resource-webapp }}'
  '#{{ appEnvironment }}-#{{ funcRepoName }}-#{{ nc-resource-functionapp }}'
]
param webAppResourceGroupName = '#{{ appEnvWebAppRgName }}'
param acrName = '#{{ acrName }}'
param slotsEnabled = '#{{ slotsEnabled }}'
param appEnvSubscriptionId = '#{{ appEnvSubscriptionId}}'

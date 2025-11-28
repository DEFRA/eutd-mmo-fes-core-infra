[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AppsRG,

    [Parameter(Mandatory = $true)]
    [string]$StorageRG,

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string] $WebAppNamesJson,

    [Parameter(Mandatory = $false)]
    [string]$ContainerName = 'apps'
)

Write-Host "Starting export for multiple Web Apps"

if ([string]::IsNullOrWhiteSpace($WebAppNamesJson)) {
  Write-Error 'WebAppNamesJson is empty or not set.'
  exit 1
}

try {
  $apps = $WebAppNamesJson | ConvertFrom-Json
} catch {
  Write-Error "Failed to parse WebAppNamesJson: $($_.Exception.Message)"
  exit 1
}

if (-not $apps) {
  Write-Error 'WebAppNames JSON did not deserialize to any items.'
  exit 1
}

$scriptRoot = "$(System.DefaultWorkingDirectory)/MMOPipelineCommon/scripts"
$exportWorkflowsScript = Join-Path $scriptRoot 'Export-Workflows.ps1'

Write-Host "Exporting environment variables for $($apps.Count) web apps..."
foreach ($app in $apps) {
  $appName = $app.Name
  if ([string]::IsNullOrWhiteSpace($appName)) {
    Write-Warning 'Encountered app entry without Name property. Skipping.'
    continue
  }
  Write-Host "Exporting variables for web app: $appName"
  & $exportWorkflowsScript -AppsRG $AppsRG -StorageRG $StorageRG -AppsName $appName -StorageAccountName $StorageAccountName -EnvironmentVariablesOnly -ContainerName $ContainerName
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Export script failed for $appName"
    exit $LASTEXITCODE
  }
}

Write-Host "Completed export for all web apps."

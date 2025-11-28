param(
  [Parameter(Mandatory=$true)]
  [string] $AppsRG,

  [Parameter(Mandatory=$true)]
  [string] $StorageRG,

  [Parameter(Mandatory=$true)]
  [string] $StorageAccountName,

  [Parameter(Mandatory=$true)]
  [string] $WebAppNamesJson,

  [string] $ContainerName = 'apps'
)

Write-Host "Starting import for multiple Web Apps"

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
$importWorkflowsScript = Join-Path $scriptRoot 'Import-Workflows.ps1'

Write-Host "Importing environment variables for $($apps.Count) web apps..."
foreach ($app in $apps) {
  $appName = $app.Name
  if ([string]::IsNullOrWhiteSpace($appName)) {
    Write-Warning 'Encountered app entry without Name property. Skipping.'
    continue
  }
  Write-Host "Importing variables for web app: $appName"
  & $importWorkflowsScript -AppsRG $AppsRG -StorageRG $StorageRG -AppsName $appName -StorageAccountName $StorageAccountName -EnvironmentVariablesOnly -ContainerName $ContainerName
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Import script failed for $appName"
    exit $LASTEXITCODE
  }
}

Write-Host "Completed import for all web apps."

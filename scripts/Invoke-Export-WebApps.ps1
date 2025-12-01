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

    [Parameter()]
    [string]$ContainerName = 'apps'
)

if ([string]::IsNullOrWhiteSpace($WebAppNamesJson)) { throw 'WebAppNamesJson is empty or not set.' }

try { $apps = $WebAppNamesJson | ConvertFrom-Json } catch { throw "Failed to parse WebAppNamesJson: $($_.Exception.Message)" }
if (-not $apps) { throw 'WebAppNames JSON did not deserialize to any items.' }

$scriptRoot = "$(System.DefaultWorkingDirectory)/MMOPipelineCommon/scripts"
$exportWorkflowsScript = Join-Path $scriptRoot 'Export-Workflows.ps1'

foreach ($app in $apps) {
  # Support array of objects with Name, or array of plain strings
  $appName = if ($app -is [string]) { $app } else { $app.Name }
  if ([string]::IsNullOrWhiteSpace($appName)) { continue }
  & $exportWorkflowsScript -AppsRG $AppsRG -StorageRG $StorageRG -AppsName $appName -StorageAccountName $StorageAccountName -EnvironmentVariablesOnly -ContainerName $ContainerName
}

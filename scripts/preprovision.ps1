## Executes pre-provision scripts

# App Service Environment
$ASE = Read-Host("App Service Environment? (Y/N): ")

# Check if input matches "y", "yes", or "true"
if ($ASE -match "^(y|yes|true)$") {
    $env:AZURE_APP_SERVICE_ENVIRONMENT = $true
}

# Zero trust
$zeroTrustScript = Join-Path -Path $PSScriptRoot -ChildPath 'zerotrust\zeroTrustHeadsUp.ps1'
& $zeroTrustScript

Write-Host "ASE: $env:AZURE_APP_SERVICE_ENVIRONMENT"

exit 0

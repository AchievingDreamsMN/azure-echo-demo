# Cleanup Script for Azure Echo Demo
# Destroys all demo resources created by Terraform and bootstrap

param(
    [switch]$Force,
    [switch]$SkipTerraform
)

$ErrorActionPreference = "Stop"

Write-Host "=== Azure Echo Demo Cleanup ===" -ForegroundColor Cyan
Write-Host "This will DELETE all demo resources!" -ForegroundColor Red

if (-not $Force) {
    $confirm = Read-Host "Are you sure? Type 'yes' to confirm"
    if ($confirm -ne "yes") {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit 0
    }
}

# Check if logged in to Azure
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Please log in to Azure..." -ForegroundColor Yellow
    az login
}

# Destroy Terraform resources
if (-not $SkipTerraform) {
    Write-Host "`nDestroying Terraform resources..." -ForegroundColor Cyan
    
    # Prod
    if (Test-Path "terraform/environments/prod/.terraform") {
        Write-Host "Destroying prod environment..." -ForegroundColor Yellow
        Push-Location terraform/environments/prod
        terraform destroy -auto-approve
        Pop-Location
    }
    
    # QA
    if (Test-Path "terraform/environments/qa/.terraform") {
        Write-Host "Destroying QA environment..." -ForegroundColor Yellow
        Push-Location terraform/environments/qa
        terraform destroy -auto-approve
        Pop-Location
    }
}

# Delete resource groups with 'demo-' prefix
Write-Host "`nDeleting demo resource groups..." -ForegroundColor Cyan
$rgs = az group list --query "[?starts_with(name, 'demo-')].name" -o tsv
foreach ($rg in $rgs) {
    Write-Host "Deleting: $rg" -ForegroundColor Yellow
    az group delete --name $rg --yes --no-wait
}

# Delete service principal
Write-Host "`nDeleting service principal..." -ForegroundColor Cyan
$sp = az ad sp list --display-name "demo-github-actions-sp" --query "[0].id" -o tsv
if ($sp) {
    az ad sp delete --id $sp
    Write-Host "Service principal deleted." -ForegroundColor Green
} else {
    Write-Host "Service principal not found (already deleted?)." -ForegroundColor Yellow
}

# Delete app registration
$app = az ad app list --display-name "demo-github-actions-sp" --query "[0].id" -o tsv
if ($app) {
    az ad app delete --id $app
    Write-Host "App registration deleted." -ForegroundColor Green
}

Write-Host "`n=== Cleanup Complete ===" -ForegroundColor Green
Write-Host "Note: Resource group deletions run in background. Check Azure portal to confirm." -ForegroundColor Yellow

# Bootstrap Script for Azure Echo Demo
# Run this ONCE to create prerequisites that Terraform needs
# After demo: delete the 'demo-bootstrap-rg' resource group and the App Registration

param(
    [string]$Prefix = "demo",
    [string]$Location = "eastus"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Azure Echo Demo Bootstrap ===" -ForegroundColor Cyan
Write-Host "This script creates:" -ForegroundColor Yellow
Write-Host "  1. Resource group for Terraform state" -ForegroundColor Yellow
Write-Host "  2. Storage account for Terraform state" -ForegroundColor Yellow
Write-Host "  3. Service Principal for GitHub Actions" -ForegroundColor Yellow
Write-Host ""

# Check if logged in to Azure
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Please log in to Azure..." -ForegroundColor Yellow
    az login
    $account = az account show | ConvertFrom-Json
}

Write-Host "Using subscription: $($account.name) ($($account.id))" -ForegroundColor Green
$subscriptionId = $account.id

# Variables
$rgName = "$Prefix-bootstrap-rg"
$storageAccountName = "${Prefix}tfstate$((Get-Random -Maximum 9999).ToString('D4'))"
$containerName = "tfstate"
$spName = "$Prefix-github-actions-sp"

# Create resource group
Write-Host "`nCreating resource group: $rgName..." -ForegroundColor Cyan
az group create --name $rgName --location $Location --output none

# Create storage account for Terraform state
Write-Host "Creating storage account: $storageAccountName..." -ForegroundColor Cyan
az storage account create `
    --name $storageAccountName `
    --resource-group $rgName `
    --location $Location `
    --sku Standard_LRS `
    --output none

# Create blob container
Write-Host "Creating blob container: $containerName..." -ForegroundColor Cyan
az storage container create `
    --name $containerName `
    --account-name $storageAccountName `
    --output none

# Create Service Principal for GitHub Actions
Write-Host "Creating service principal: $spName..." -ForegroundColor Cyan
$sp = az ad sp create-for-rbac `
    --name $spName `
    --role Contributor `
    --scopes "/subscriptions/$subscriptionId" `
    --sdk-auth | ConvertFrom-Json

# Get additional details
$spDetails = az ad sp list --display-name $spName | ConvertFrom-Json | Select-Object -First 1

# Output results
Write-Host "`n=== BOOTSTRAP COMPLETE ===" -ForegroundColor Green
Write-Host "`n--- Terraform Backend Configuration ---" -ForegroundColor Cyan
Write-Host "Update terraform/environments/*/main.tf with:" -ForegroundColor Yellow
Write-Host @"
  backend "azurerm" {
    resource_group_name  = "$rgName"
    storage_account_name = "$storageAccountName"
    container_name       = "$containerName"
    key                  = "echo-server-ENV.tfstate"  # qa or prod
  }
"@

Write-Host "`n--- GitHub Secrets ---" -ForegroundColor Cyan
Write-Host "Add these secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "(Settings -> Secrets and variables -> Actions -> New repository secret)`n"

Write-Host "AZURE_CREDENTIALS:" -ForegroundColor White
$sp | ConvertTo-Json | Write-Host

Write-Host "`nARM_CLIENT_ID: $($sp.clientId)" -ForegroundColor White
Write-Host "ARM_CLIENT_SECRET: $($sp.clientSecret)" -ForegroundColor White
Write-Host "ARM_SUBSCRIPTION_ID: $($sp.subscriptionId)" -ForegroundColor White
Write-Host "ARM_TENANT_ID: $($sp.tenantId)" -ForegroundColor White

Write-Host "`n--- Cleanup After Demo ---" -ForegroundColor Cyan
Write-Host "To delete EVERYTHING after the demo, run:" -ForegroundColor Yellow
Write-Host @"

# 1. Destroy Terraform resources first
cd terraform/environments/prod && terraform destroy -auto-approve
cd ../qa && terraform destroy -auto-approve

# 2. Delete bootstrap resources
az group delete --name $rgName --yes --no-wait
az group delete --name demo-echo-server-qa-rg --yes --no-wait
az group delete --name demo-echo-server-prod-rg --yes --no-wait
az group delete --name demo-echo-server-acr-rg --yes --no-wait

# 3. Delete service principal
az ad sp delete --id $($spDetails.appId)
"@

Write-Host "`n=== Save this output! ===" -ForegroundColor Red

# Save to file
$outputFile = "bootstrap-output.txt"
@"
=== Azure Echo Demo Bootstrap Output ===
Generated: $(Get-Date)

Subscription: $($account.name) ($subscriptionId)

--- Terraform Backend ---
resource_group_name  = "$rgName"
storage_account_name = "$storageAccountName"
container_name       = "$containerName"

--- Service Principal ---
ARM_CLIENT_ID=$($sp.clientId)
ARM_CLIENT_SECRET=$($sp.clientSecret)
ARM_SUBSCRIPTION_ID=$($sp.subscriptionId)
ARM_TENANT_ID=$($sp.tenantId)

--- AZURE_CREDENTIALS (JSON) ---
$($sp | ConvertTo-Json)

--- Cleanup Commands ---
az group delete --name $rgName --yes
az group delete --name demo-echo-server-qa-rg --yes
az group delete --name demo-echo-server-prod-rg --yes
az group delete --name demo-echo-server-acr-rg --yes
az ad sp delete --id $($spDetails.appId)
"@ | Out-File -FilePath $outputFile

Write-Host "`nCredentials saved to: $outputFile (gitignored)" -ForegroundColor Green

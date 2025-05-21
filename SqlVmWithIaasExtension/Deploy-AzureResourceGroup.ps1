param(
    [string]$StorageAccountName = '',
    [string]$ResourceGroupName,
    [string]$ResourceGroupLocation,
    [string]$TemplateFile,
    [string]$TemplateParametersFile,
    [string]$ArtifactStagingDirectory = '.',
    [string]$DSCSourceFolder = '.\DSC'
)

# Login if not already connected
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

# Confirm subscription context is set
$context = Get-AzContext
if (-not $context) {
    Write-Error "No Azure context found after login."
    exit 1
}

Write-Host "Account          : $($context.Account)"
Write-Host "SubscriptionName : $($context.Subscription.Name)"
Write-Host "SubscriptionId   : $($context.Subscription.Id)"
Write-Host "TenantId         : $($context.Tenant.Id)"
Write-Host "Environment      : $($context.Environment.Name)"
Write-Host ""

Write-Host "Checking if resource group '$ResourceGroupName' exists..."
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if (-not $rg) {
    Write-Host "Resource group '$ResourceGroupName' not found. Creating it..."
    New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation | Out-Null
} else {
    Write-Host "Resource group '$ResourceGroupName' exists."
}

Write-Host "Deploying ARM template..."
New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $TemplateParametersFile `
    -Mode Incremental `
    -Verbose

Write-Host "Deployment finished."

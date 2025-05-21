param(
    [Parameter(Mandatory = $true)][string]$ResourceGroupName,
    [Parameter(Mandatory = $true)][string]$ResourceGroupLocation,
    [Parameter(Mandatory = $true)][string]$TemplateFile,
    [Parameter(Mandatory = $true)][string]$TemplateParametersFile,
    [string]$StorageAccountName = "",
    [string]$ArtifactStagingDirectory = ".",
    [string]$DSCSourceFolder = ".\DSC"
)

# Ensure script runs in PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or later. Please run it in PowerShell 7."
    exit 1
}

# Only import Az modules if not already loaded (do NOT use -Force!)
if (-not (Get-Module -Name Az.Accounts)) {
    Import-Module Az.Accounts -ErrorAction Stop
}
if (-not (Get-Module -Name Az.Resources)) {
    Import-Module Az.Resources -ErrorAction Stop
}

# Show Azure context
Write-Output "`nAccount Context:"
Get-AzContext | Format-List

# Create Resource Group if needed
if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Output "Creating resource group '$ResourceGroupName' in location '$ResourceGroupLocation'..."
    New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
} else {
    Write-Output "Resource group '$ResourceGroupName' already exists."
}

# Deploy ARM template
Write-Output "Starting template deployment to resource group '$ResourceGroupName'..."
New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $TemplateParametersFile `
    -Verbose `
    -ErrorAction Stop

Write-Output "✅ Deployment completed successfully."

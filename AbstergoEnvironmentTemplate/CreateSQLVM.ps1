# Variables
$resourceGroupName = "FirstRG"
$location = "Central India"
$vmName = "MySQLServerVM"
$vmSize = "Standard_B1ms"
$publisherName = "MicrosoftSQLServer"
$offer = "sql2019-ws2019"
$sku = "basic"

# Login if needed
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

# Set subscription (if not already set)
Set-AzContext -SubscriptionId "badb6979-963f-445f-82d3-bf419401058c"

# Create resource group if it doesn't exist
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating resource group: $resourceGroupName"
    New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
    Write-Host "Resource group $resourceGroupName already exists."
}

# Prompt for VM credentials
$cred = Get-Credential -Message "Enter credentials for the VM (local admin)"

# Create virtual network
$vnet = New-AzVirtualNetwork -Name "$vmName-VNET" -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16"
Add-AzVirtualNetworkSubnetConfig -Name "default" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet | Set-AzVirtualNetwork

# Refresh VNet
$vnet = Get-AzVirtualNetwork -Name "$vmName-VNET" -ResourceGroupName $resourceGroupName
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq "default" }

# Create NIC
$nic = New-AzNetworkInterface -Name "$vmName-NIC" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id

# Configure VM
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate |
    Set-AzVMSourceImage -PublisherName $publisherName -Offer $offer -Skus $sku -Version "latest" |
    Add-AzVMNetworkInterface -Id $nic.Id

# Create VM
Write-Host "Creating VM $vmName..."
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "VM creation initiated. This may take several minutes..."

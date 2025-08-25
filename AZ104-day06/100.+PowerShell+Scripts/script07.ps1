$resourceGroupName="staging-grp"
$location="South East Asia"
$publicIPAddressName="app-ip"

New-AzPublicIpAddress -Name $publicIPAddressName -ResourceGroupName $resourceGroupName `
-Location $location -AllocationMethod Static
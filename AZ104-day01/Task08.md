# Azure Virtual Machine Scale Sets with Auto Scaling and Uniform Orchestration

This guide covers creating and managing Virtual Machine Scale Sets (VMSS) using uniform orchestration mode with auto scaling for both Linux and Windows VMs.

## Uniform vs Flexible Orchestration Mode

### Uniform Orchestration Mode
- **Identical VMs**: All instances use the same VM size and configuration
- **Availability Sets**: Uses traditional availability sets with fault/update domains
- **Scaling**: Optimized for large-scale identical workloads
- **Management**: Simplified management with uniform configuration
- **Use Cases**: Web servers, stateless applications, batch processing
- **SLA**: 99.95% with availability sets

### Flexible Orchestration Mode
- **Mixed VMs**: Different VM sizes and configurations in same scale set
- **Availability Zones**: Native support for availability zones
- **Scaling**: More granular control over individual instances
- **Management**: Complex management with varied configurations
- **Use Cases**: Microservices, mixed workloads, spot instances
- **SLA**: 99.99% with availability zones

### Comparison Table

| Feature | Uniform | Flexible |
|---------|---------|----------|
| VM Sizes | Single size | Multiple sizes |
| Availability | Availability Sets | Availability Zones |
| Scaling | Uniform scaling | Granular scaling |
| Management | Simplified | Complex |
| Cost | Lower management overhead | Higher flexibility |
| SLA | 99.95% | 99.99% |

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- SSH key pair for Linux VMs
- Understanding of scaling metrics

---
## Manual VMSS Creation with Uniform Orchestration

### Azure Portal Steps

#### 1. Create Uniform VMSS via Portal
1. Navigate to **Virtual machine scale sets** > **Create**
2. **Basics Tab:**
   - Resource group: `sa1_test_eic_SudarshanDarade`
   - Scale set name: `vmss-uniform-manual`
   - Region: `SouthEast Asia`
   - Orchestration mode: **Uniform**
   - Image: `Ubuntu 24.04 LTS`
   - Size: `Standard_B2s`
   - Authentication: SSH public key
   - Username: `azureuser`

3. **Disks Tab:**
   - OS disk type: `Premium SSD`
   - Use managed disks: `Yes`

4. **Networking Tab:**
   - Virtual network: Create new `vnet-vmss-uniform`
   - Subnet: Create new `subnet-vmss` (10.0.1.0/24)
   - Public IP: `Enabled`


5. **Scaling Tab:**
   - Initial instance count: `3`
   - Scaling policy: **Custom**
   - Enable autoscale: **Yes**
   - Minimum instances: `2`
   - Maximum instances: `15`
   - Scale out CPU threshold: `75%`
   - Scale in CPU threshold: `25%`

6. **Management Tab:**
   - Upgrade policy: `Rolling`
   - Max unhealthy instances: `20%`
   - Max batch size: `20%`
   - Pause time between batches: `0 seconds`

7. **Advanced Tab:**
   - Fault domain count: `3`
   - Update domain count: `5`
   - Custom data: Add stress tool installation
   ```bash
   #!/bin/bash
   apt-get update
   apt-get install -y nginx stress
   systemctl start nginx
   systemctl enable nginx
   echo "<h1>Uniform VMSS Instance: $(hostname)</h1>" > /var/www/html/index.html
   ```

8. Click **Review + Create** > **Create**

#### 2. Configure Advanced Auto Scale via Portal

**Multi-Metric Scaling:**
1. Navigate to VMSS > **Settings** > **Scaling**
2. Click **Custom autoscale**
3. Add multiple scale conditions:
   - **CPU-based**: Scale out when CPU > 75%, scale in when CPU < 25%
   - **Memory-based**: Scale out when Available Memory < 1GB
   - **Network-based**: Scale out when Network In > 10MB/s



#### 3. PowerShell Uniform VMSS Creation

```powershell
# Create resource group
New-AzResourceGroup -Name "sa1_test_eic_SudarshanDarade" -Location "SouthEast Asia"

# Create virtual network
$subnet = New-AzVirtualNetworkSubnetConfig -Name "subnet-vmss" -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "SouthEast Asia" -Name "vnet-vmss-uniform" -AddressPrefix "10.0.0.0/16" -Subnet $subnet

# Create load balancer
$publicIP = New-AzPublicIpAddress -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "SouthEast Asia" -AllocationMethod Static -Name "lb-vmss-ip"
$frontendIP = New-AzLoadBalancerFrontendIpConfig -Name "lb-frontend" -PublicIpAddress $publicIP
$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "lb-backend"
$probe = New-AzLoadBalancerProbeConfig -Name "http-probe" -Protocol Http -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath "/"
$lbrule = New-AzLoadBalancerRuleConfig -Name "http-rule" -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendPool -Probe $probe -Protocol Tcp -FrontendPort 80 -BackendPort 80
$lb = New-AzLoadBalancer -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "SouthEast Asia" -Name "lb-vmss" -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendPool -Probe $probe -LoadBalancingRule $lbrule

# Create VMSS configuration
$vmssConfig = New-AzVmssConfig -Location "SouthEast Asia" -SkuCapacity 3 -SkuName "Standard_B2s" -OrchestrationMode "Uniform" -PlatformFaultDomainCount 3 -UpgradePolicyMode "Rolling"

# Set OS profile
$vmssConfig = Set-AzVmssOsProfile -VirtualMachineScaleSet $vmssConfig -ComputerNamePrefix "vmss" -AdminUsername "azureuser" -LinuxConfigurationDisablePasswordAuthentication $true

# Set storage profile
$vmssConfig = Set-AzVmssStorageProfile -VirtualMachineScaleSet $vmssConfig -ImageReferencePublisher "Canonical" -ImageReferenceOffer "0001-com-ubuntu-server-jammy" -ImageReferenceSku "22_04-lts-gen2" -ImageReferenceVersion "latest" -OsDiskCreateOption "FromImage" -OsDiskCaching "ReadWrite"

# Set network profile
$ipConfig = New-AzVmssIpConfig -Name "vmss-ip-config" -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools[0].Id -SubnetId $vnet.Subnets[0].Id
$networkProfile = New-AzVmssNetworkInterfaceConfiguration -Name "vmss-nic" -Primary $true -IpConfiguration $ipConfig
$vmssConfig = Add-AzVmssNetworkInterfaceConfiguration -VirtualMachineScaleSet $vmssConfig -NetworkInterfaceConfiguration $networkProfile

# Create VMSS
New-AzVmss -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "vmss-uniform-manual" -VirtualMachineScaleSet $vmssConfig

# Create autoscale rules
$vmssId = "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-uniform-manual"
$rule1 = New-AzAutoscaleRule -MetricName "Percentage CPU" -MetricResourceId $vmssId -Operator GreaterThan -MetricStatistic Average -Threshold 75 -TimeGrain 00:01:00 -TimeWindow 00:05:00 -ScaleActionCooldown 00:05:00 -ScaleActionDirection Increase -ScaleActionValue 2

$rule2 = New-AzAutoscaleRule -MetricName "Percentage CPU" -MetricResourceId $vmssId -Operator LessThan -MetricStatistic Average -Threshold 25 -TimeGrain 00:01:00 -TimeWindow 00:10:00 -ScaleActionCooldown 00:10:00 -ScaleActionDirection Decrease -ScaleActionValue 1

# Create autoscale profile
$profile = New-AzAutoscaleProfile -DefaultCapacity 3 -MaximumCapacity 15 -MinimumCapacity 2 -Rule $rule1, $rule2 -Name "Default"

# Apply autoscale setting
Add-AzAutoscaleSetting -Location "SouthEast Asia" -Name "autoscale-uniform-manual" -ResourceGroupName "sa1_test_eic_SudarshanDarade" -TargetResourceId $vmssId -AutoscaleProfile $profile
```

---

## Linux VMSS with Uniform Orchestration

### 1. Create Resource Group and Prerequisites

```bash
# Create resource group
az group create \
  --name rg-vmss-uniform-linux \
  --location southeastasia

# Generate SSH key if not exists
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vmss-uniform-key -N ""
```

### 2. Create Virtual Network

```bash
# Create virtual network
az network vnet create \
  --resource-group rg-vmss-uniform-linux \
  --name vnet-vmss-uniform \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-vmss \
  --subnet-prefix 10.0.1.0/24
```

### 3. Create Linux VMSS with Uniform Orchestration

```bash
# Create Linux VMSS with uniform orchestration
az vmss create \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/vmss-uniform-key.pub \
  --instance-count 3 \
  --vm-sku Standard_B2s \
  --vnet-name vnet-vmss-uniform \
  --subnet subnet-vmss \
  --orchestration-mode Uniform \
  --upgrade-policy-mode Automatic \
  --platform-fault-domain-count 5 \
  --platform-update-domain-count 5
```

### 4. Configure Web Server on Linux Instances

```bash
# Create cloud-init script for web server setup
cat > cloud-init-linux.txt << 'EOF'
#cloud-config
package_update: true
packages:
  - nginx
  - stress
runcmd:
  - systemctl start nginx
  - systemctl enable nginx
  - echo "<h1>Linux VMSS Uniform Instance: $(hostname)</h1><p>Fault Domain: $(curl -s -H Metadata:true http://169.254.169.254/metadata/instance/compute/platformFaultDomain?api-version=2021-02-01)</p><p>Update Domain: $(curl -s -H Metadata:true http://169.254.169.254/metadata/instance/compute/platformUpdateDomain?api-version=2021-02-01)</p>" > /var/www/html/index.html
EOF

# Apply custom script extension
az vmss extension set \
  --resource-group rg-vmss-uniform-linux \
  --vmss-name vmss-linux-uniform \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --version 2.1 \
  --settings '{"commandToExecute":"apt-get update && apt-get install -y nginx stress && systemctl start nginx && systemctl enable nginx && echo \"<h1>Linux VMSS Uniform Instance: $(hostname)</h1><p>Load Test: <button onclick=\\\"fetch(\\\'/stress\\\')\\\" >Start CPU Load</button></p>\" > /var/www/html/index.html"}'
```

### 5. Create Auto Scale Settings for Linux VMSS

```bash
# Create auto scale profile
az monitor autoscale create \
  --resource-group rg-vmss-uniform-linux \
  --resource vmss-linux-uniform \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoscale-linux-uniform \
  --min-count 2 \
  --max-count 10 \
  --count 3

# Create scale-out rule (CPU > 70%)
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 2 \
  --cooldown 5

# Create scale-in rule (CPU < 30%)
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --condition "Percentage CPU < 30 avg 10m" \
  --scale in 1 \
  --cooldown 10
```

---

## Windows VMSS with Uniform Orchestration

### 1. Create Resource Group and Prerequisites

```bash
# Create resource group
az group create \
  --name rg-vmss-uniform-windows \
  --location southeastasia
```

### 2. Create Virtual Network

```bash
# Create virtual network
az network vnet create \
  --resource-group rg-vmss-uniform-windows \
  --name vnet-vmss-uniform-win \
  --address-prefix 10.1.0.0/16 \
  --subnet-name subnet-vmss-win \
  --subnet-prefix 10.1.1.0/24
```

### 3. Create Windows VMSS with Uniform Orchestration

```bash
# Create Windows VMSS with uniform orchestration
az vmss create \
  --resource-group rg-vmss-uniform-windows \
  --name vmss-windows-uniform \
  --image Win2022Datacenter \
  --admin-username azureuser \
  --admin-password 'P@ssw0rd123!' \
  --instance-count 3 \
  --vm-sku Standard_B2s \
  --vnet-name vnet-vmss-uniform-win \
  --subnet subnet-vmss-win \
  --orchestration-mode Uniform \
  --upgrade-policy-mode Automatic \
  --platform-fault-domain-count 5 \
  --platform-update-domain-count 5
```

### 4. Configure IIS on Windows Instances

```bash
# Apply custom script extension to install IIS
az vmss extension set \
  --resource-group rg-vmss-uniform-windows \
  --vmss-name vmss-windows-uniform \
  --name CustomScriptExtension \
  --publisher Microsoft.Compute \
  --version 1.10 \
  --settings '{"commandToExecute":"powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -name Web-Server -IncludeManagementTools; $hostname = $env:COMPUTERNAME; $faultDomain = (Invoke-RestMethod -Uri \"http://169.254.169.254/metadata/instance/compute/platformFaultDomain?api-version=2021-02-01\" -Headers @{\"Metadata\"=\"true\"}); $updateDomain = (Invoke-RestMethod -Uri \"http://169.254.169.254/metadata/instance/compute/platformUpdateDomain?api-version=2021-02-01\" -Headers @{\"Metadata\"=\"true\"}); $html = \"<html><body><h1>Windows VMSS Uniform Instance: $hostname</h1><p>Fault Domain: $faultDomain</p><p>Update Domain: $updateDomain</p><p><button onclick=\\\"startCpuLoad()\\\">Start CPU Load</button></p><script>function startCpuLoad(){fetch(\\\"/stress\\\");}</script></body></html>\"; $html | Out-File -FilePath \"C:\\inetpub\\wwwroot\\index.html\" -Encoding UTF8"}'
```

### 5. Create Auto Scale Settings for Windows VMSS

```bash
# Create auto scale profile
az monitor autoscale create \
  --resource-group rg-vmss-uniform-windows \
  --resource vmss-windows-uniform \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoscale-windows-uniform \
  --min-count 2 \
  --max-count 8 \
  --count 3

# Create scale-out rule (CPU > 75%)
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-windows \
  --autoscale-name autoscale-windows-uniform \
  --condition "Percentage CPU > 75 avg 5m" \
  --scale out 2 \
  --cooldown 5

# Create scale-in rule (CPU < 25%)
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-windows \
  --autoscale-name autoscale-windows-uniform \
  --condition "Percentage CPU < 25 avg 10m" \
  --scale in 1 \
  --cooldown 10
```

---

## Advanced Uniform Orchestration Features

### Availability Set Configuration

```bash
# Check availability set configuration
az vmss show \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --query "{FaultDomains:platformFaultDomainCount, UpdateDomains:platformUpdateDomainCount, OrchestrationMode:orchestrationMode}"

# List instances with domain information
az vmss list-instances \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --query "[].{Name:name, FaultDomain:platformFaultDomain, UpdateDomain:platformUpdateDomain}" \
  --output table
```

### Upgrade Policies

```bash
# Set rolling upgrade policy
az vmss update \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --set upgradePolicy.mode=Rolling \
  --set upgradePolicy.rollingUpgradePolicy.maxBatchInstancePercent=20 \
  --set upgradePolicy.rollingUpgradePolicy.maxUnhealthyInstancePercent=10 \
  --set upgradePolicy.rollingUpgradePolicy.pauseTimeBetweenBatches=PT30S

# Set automatic upgrade policy
az vmss update \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --set upgradePolicy.mode=Automatic
```

### Instance Protection

```bash
# Protect specific instances from scale-in
az vmss update \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --instance-id 0 \
  --protect-from-scale-in true

# Protect from scale-set actions
az vmss update \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --instance-id 0 \
  --protect-from-scale-set-actions true
```

---

## Multi-Metric Auto Scaling

### CPU and Memory Based Scaling

```bash
# Add memory-based scale-out rule
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --condition "Available Memory Bytes < 1073741824 avg 5m" \
  --scale out 1 \
  --cooldown 5

# Add memory-based scale-in rule
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --condition "Available Memory Bytes > 2147483648 avg 10m" \
  --scale in 1 \
  --cooldown 10
```

### Network and Disk Based Scaling

```bash
# Network-based scaling
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --condition "Network In Total > 10485760 avg 5m" \
  --scale out 1

# Disk-based scaling
az monitor autoscale rule create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --condition "Disk Read Bytes > 104857600 avg 5m" \
  --scale out 1
```

### Time-Based Scaling Profiles

```bash
# Create business hours profile
az monitor autoscale profile create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --name "business-hours" \
  --min-count 5 \
  --max-count 15 \
  --count 5 \
  --timezone "Eastern Standard Time" \
  --start "2024-01-01T09:00:00" \
  --end "2024-12-31T18:00:00" \
  --recurrence week mon tue wed thu fri

# Create night hours profile
az monitor autoscale profile create \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --name "night-hours" \
  --min-count 2 \
  --max-count 5 \
  --count 2 \
  --timezone "Eastern Standard Time" \
  --start "2024-01-01T18:01:00" \
  --end "2024-12-31T08:59:59" \
  --recurrence week mon tue wed thu fri
```

---

## Monitoring and Management

### Instance Health Monitoring

```bash
# Check instance health
az vmss get-instance-view \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --query "statuses[?code=='ProvisioningState/succeeded']"

# List unhealthy instances
az vmss list-instances \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --query "[?instanceView.vmHealth.status.displayStatus!='HealthState/healthy'].{Name:name, Health:instanceView.vmHealth.status.displayStatus}"
```



### Scaling Activity Monitoring

```bash
# View recent scaling activities
az monitor activity-log list \
  --resource-group rg-vmss-uniform-linux \
  --start-time 2024-01-01T00:00:00Z \
  --query "[?contains(operationName.value, 'Scale')]" \
  --output table

# Get current auto scale status
az monitor autoscale show \
  --resource-group rg-vmss-uniform-linux \
  --name autoscale-linux-uniform \
  --query "{Enabled:enabled, CurrentCapacity:profiles[0].capacity.default, MinCapacity:profiles[0].capacity.minimum, MaxCapacity:profiles[0].capacity.maximum}"
```

---

## Testing Auto Scaling

### CPU Load Testing Script for Linux

```bash
#!/bin/bash
# CPU load testing script for uniform VMSS

RESOURCE_GROUP="rg-vmss-uniform-linux"
VMSS_NAME="vmss-linux-uniform"

echo "Starting CPU load test on VMSS instances"

# Get instance IPs
INSTANCE_IPS=$(az vmss list-instance-public-ips \
  --resource-group $RESOURCE_GROUP \
  --name $VMSS_NAME \
  --query "[].ipAddress" -o tsv)

# Generate CPU load on all instances
for ip in $INSTANCE_IPS; do
  echo "Generating CPU load on instance: $ip"
  ssh -i ~/.ssh/vmss-uniform-key -o StrictHostKeyChecking=no azureuser@$ip \
    "nohup stress --cpu 2 --timeout 600s > /dev/null 2>&1 &" &
done

# Monitor scaling
echo "Monitoring scaling activity..."
for i in {1..20}; do
  CURRENT_COUNT=$(az vmss show --resource-group $RESOURCE_GROUP --name $VMSS_NAME --query "sku.capacity" -o tsv)
  echo "$(date): Current instance count: $CURRENT_COUNT"
  sleep 60
done
```

### PowerShell CPU Load Testing for Windows

```powershell
# PowerShell script for Windows VMSS CPU load testing
$ResourceGroup = "rg-vmss-uniform-windows"
$VmssName = "vmss-windows-uniform"

Write-Host "Starting CPU load test on VMSS instances"

# Get instance IPs
$instanceIps = az vmss list-instance-public-ips --resource-group $ResourceGroup --name $VmssName --query "[].ipAddress" -o tsv

# Generate CPU load on all instances via RDP/PowerShell remoting
foreach ($ip in $instanceIps) {
    Write-Host "Generating CPU load on instance: $ip"
    # Note: This requires PowerShell remoting to be enabled
    # Invoke-Command -ComputerName $ip -Credential $cred -ScriptBlock {
    #     $jobs = @()
    #     for ($i = 1; $i -le 4; $i++) {
    #         $jobs += Start-Job -ScriptBlock {
    #             $end = (Get-Date).AddMinutes(10)
    #             while ((Get-Date) -lt $end) {
    #                 $result = 1
    #                 for ($j = 1; $j -le 1000000; $j++) {
    #                     $result = $result * $j / $j
    #                 }
    #             }
    #         }
    #     }
    # }
}

# Monitor scaling
for ($i = 1; $i -le 20; $i++) {
    $currentCount = az vmss show --resource-group $ResourceGroup --name $VmssName --query "sku.capacity" -o tsv
    Write-Host "$(Get-Date): Current instance count: $currentCount"
    Start-Sleep -Seconds 60
}
```

---

## Best Practices for Uniform Orchestration

### Configuration Optimization

```bash
# Optimize for web workloads
az vmss update \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --set upgradePolicy.mode=Rolling \
  --set upgradePolicy.rollingUpgradePolicy.maxBatchInstancePercent=25 \
  --set upgradePolicy.rollingUpgradePolicy.maxUnhealthyInstancePercent=5

# Set optimal fault domain distribution
az vmss update \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --set platformFaultDomainCount=3
```

### Security Configuration

```bash
# Create NSG for VMSS
az network nsg create \
  --resource-group rg-vmss-uniform-linux \
  --name nsg-vmss-uniform

# Allow HTTP traffic
az network nsg rule create \
  --resource-group rg-vmss-uniform-linux \
  --nsg-name nsg-vmss-uniform \
  --name allow-http \
  --priority 1000 \
  --source-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

# Allow SSH from specific IP range
az network nsg rule create \
  --resource-group rg-vmss-uniform-linux \
  --nsg-name nsg-vmss-uniform \
  --name allow-ssh \
  --priority 1100 \
  --source-address-prefixes '10.0.0.0/8' \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp

# Associate NSG with subnet
az network vnet subnet update \
  --resource-group rg-vmss-uniform-linux \
  --vnet-name vnet-vmss-uniform \
  --name subnet-vmss \
  --network-security-group nsg-vmss-uniform
```

---

## Troubleshooting

### Common Issues

1. **Uneven Distribution**: Check fault domain configuration
2. **Slow Updates**: Verify rolling upgrade settings
3. **Scale Limits**: Check subscription quotas and limits
4. **Network Connectivity**: Verify NSG rules and subnet configuration

### Diagnostic Commands

```bash
# Check VMSS configuration
az vmss show \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --query "{OrchestrationMode:orchestrationMode, UpgradePolicy:upgradePolicy.mode, FaultDomains:platformFaultDomainCount}"

# Check instance distribution
az vmss list-instances \
  --resource-group rg-vmss-uniform-linux \
  --name vmss-linux-uniform \
  --query "[].{Name:name, FaultDomain:platformFaultDomain, UpdateDomain:platformUpdateDomain, ProvisioningState:provisioningState}" \
  --output table

# Check auto scale rules
az monitor autoscale rule list \
  --resource-group rg-vmss-uniform-linux \
  --autoscale-name autoscale-linux-uniform \
  --output table
```

---

## Cleanup

```bash
# Delete Linux uniform VMSS resources
az group delete --name rg-vmss-uniform-linux --yes --no-wait

# Delete Windows uniform VMSS resources
az group delete --name rg-vmss-uniform-windows --yes --no-wait
```

---

## Summary

This guide covered:
- Differences between uniform and flexible orchestration modes
- Creating VMSS with uniform orchestration for Linux and Windows
- Multi-metric auto scaling configuration
- Instance protection and upgrade policies
- CPU load testing and monitoring
- Troubleshooting uniform VMSS deployments

Uniform orchestration mode is ideal for homogeneous workloads requiring consistent configuration and simplified management with traditional availability set-based high availability.
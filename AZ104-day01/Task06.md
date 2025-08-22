# Azure Virtual Machine Scale Sets with Flexible Orchestration

This guide covers creating and managing Virtual Machine Scale Sets (VMSS) using flexible orchestration mode with manual scaling for both Linux and Windows VMs.

## Overview

Azure VMSS with flexible orchestration provides:
- **Manual Scaling**: Control over instance count
- **Mixed Instance Types**: Different VM sizes in same scale set
- **Availability Zone Distribution**: Automatic distribution across zones
- **Simplified Management**: Unified management interface

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- SSH key pair for Linux VMs
- Basic understanding of load balancing concepts

---

## Linux VMSS with Flexible Orchestration

### 1. Create Resource Group and Prerequisites

```bash
# Create resource group
az group create \
  --name rg-vmss-linux \
  --location eastus

# Generate SSH key if not exists
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vmss-key -N ""
```

### 2. Create Virtual Network

```bash
# Create virtual network
az network vnet create \
  --resource-group rg-vmss-linux \
  --name vnet-vmss \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-vmss \
  --subnet-prefix 10.0.1.0/24
```

### 3. Create Linux VMSS with Flexible Orchestration

```bash
# Create Linux VMSS
az vmss create \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/vmss-key.pub \
  --instance-count 2 \
  --vm-sku Standard_B2s \
  --vnet-name vnet-vmss \
  --subnet subnet-vmss \
  --orchestration-mode Flexible \
  --platform-fault-domain-count 1 \
  --zones 1 2 3 \
  --upgrade-policy-mode Manual
```

### 4. Configure Web Server on Linux Instances

```bash
# Create custom script for web server installation
cat > install-nginx.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Linux VMSS Instance: $(hostname)</h1>" > /var/www/html/index.html
echo "<p>Zone: $(curl -s -H Metadata:true http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01)</p>" >> /var/www/html/index.html
EOF

# Apply custom script extension to VMSS
az vmss extension set \
  --resource-group rg-vmss-linux \
  --vmss-name vmss-linux-flex \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --version 2.1 \
  --settings '{"fileUris":[],"commandToExecute":"apt-get update && apt-get install -y nginx && systemctl start nginx && systemctl enable nginx && echo \"<h1>Linux VMSS Instance: $(hostname)</h1><p>Zone: $(curl -s -H Metadata:true http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01)</p>\" > /var/www/html/index.html"}'
```

---

## Windows VMSS with Flexible Orchestration

### 1. Create Resource Group and Prerequisites

```bash
# Create resource group
az group create \
  --name rg-vmss-windows \
  --location eastus
```

### 2. Create Virtual Network

```bash
# Create virtual network
az network vnet create \
  --resource-group rg-vmss-windows \
  --name vnet-vmss-win \
  --address-prefix 10.1.0.0/16 \
  --subnet-name subnet-vmss-win \
  --subnet-prefix 10.1.1.0/24
```

### 3. Create Windows VMSS with Flexible Orchestration

```bash
# Create Windows VMSS
az vmss create \
  --resource-group rg-vmss-windows \
  --name vmss-windows-flex \
  --image Win2022Datacenter \
  --admin-username azureuser \
  --admin-password 'P@ssw0rd123!' \
  --instance-count 2 \
  --vm-sku Standard_B2s \
  --vnet-name vnet-vmss-win \
  --subnet subnet-vmss-win \
  --orchestration-mode Flexible \
  --platform-fault-domain-count 1 \
  --zones 1 2 3 \
  --upgrade-policy-mode Manual
```

### 4. Configure IIS on Windows Instances

```bash
# Create PowerShell script for IIS installation
cat > install-iis.ps1 << 'EOF'
Install-WindowsFeature -name Web-Server -IncludeManagementTools
$hostname = $env:COMPUTERNAME
$zone = (Invoke-RestMethod -Uri "http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01" -Headers @{"Metadata"="true"})
$html = @"
<!DOCTYPE html>
<html>
<head><title>Windows VMSS Instance</title></head>
<body>
<h1>Windows VMSS Instance: $hostname</h1>
<p>Zone: $zone</p>
<p>Time: $(Get-Date)</p>
</body>
</html>
"@
$html | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding UTF8
EOF

# Apply custom script extension to Windows VMSS
az vmss extension set \
  --resource-group rg-vmss-windows \
  --vmss-name vmss-windows-flex \
  --name CustomScriptExtension \
  --publisher Microsoft.Compute \
  --version 1.10 \
  --settings '{"commandToExecute":"powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -name Web-Server -IncludeManagementTools; $hostname = $env:COMPUTERNAME; $zone = (Invoke-RestMethod -Uri \"http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01\" -Headers @{\"Metadata\"=\"true\"}); $html = \"<html><body><h1>Windows VMSS Instance: $hostname</h1><p>Zone: $zone</p></body></html>\"; $html | Out-File -FilePath \"C:\\inetpub\\wwwroot\\index.html\" -Encoding UTF8"}'
```

---

## Manual Scaling Operations

### Scale Out (Increase Instances)

```bash
# Scale Linux VMSS to 4 instances
az vmss scale \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --new-capacity 4

# Scale Windows VMSS to 4 instances
az vmss scale \
  --resource-group rg-vmss-windows \
  --name vmss-windows-flex \
  --new-capacity 4
```

### Scale In (Decrease Instances)

```bash
# Scale Linux VMSS to 2 instances
az vmss scale \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --new-capacity 2

# Scale Windows VMSS to 2 instances
az vmss scale \
  --resource-group rg-vmss-windows \
  --name vmss-windows-flex \
  --new-capacity 2
```

### Manual Instance Management

```bash
# List VMSS instances
az vmss list-instances \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --output table

# Stop specific instance
az vmss stop \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --instance-ids 0

# Start specific instance
az vmss start \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --instance-ids 0

# Delete specific instance
az vmss delete-instances \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --instance-ids 0
```

---

## Monitoring and Management

### Check VMSS Status

```bash
# Get VMSS details
az vmss show \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --query "{Name:name, Capacity:sku.capacity, OrchestrationMode:orchestrationMode, UpgradePolicy:upgradePolicy.mode}"

# Check instance health
az vmss get-instance-view \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --query "statuses[?code=='ProvisioningState/succeeded']"
```



### Instance Details

```bash
# Get detailed instance information
az vmss list-instance-connection-info \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex

# Check instance zones distribution
az vmss list-instances \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --query "[].{Name:name, Zone:zones[0], ProvisioningState:provisioningState}" \
  --output table
```

---

## Update and Maintenance

### Update VMSS Configuration

```bash
# Update VM SKU (requires manual upgrade)
az vmss update \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --set sku.name=Standard_B4ms

# Apply updates to instances manually
az vmss update-instances \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --instance-ids "*"
```

### Rolling Updates

```bash
# Update VMSS image
az vmss update \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --set virtualMachineProfile.storageProfile.imageReference.version=latest

# Manually upgrade instances one by one
for instance in $(az vmss list-instances --resource-group rg-vmss-linux --name vmss-linux-flex --query "[].instanceId" -o tsv); do
  echo "Upgrading instance $instance"
  az vmss update-instances \
    --resource-group rg-vmss-linux \
    --name vmss-linux-flex \
    --instance-ids $instance
  sleep 30
done
```

---

## Testing and Verification

### Test Instance Connectivity

```bash
# Get instance public IPs
az vmss list-instance-public-ips \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --output table

# Test connectivity to individual instances
for ip in $(az vmss list-instance-public-ips --resource-group rg-vmss-linux --name vmss-linux-flex --query "[].ipAddress" -o tsv); do
  echo "Testing instance at $ip"
  curl -s http://$ip | grep "Instance:"
done
```

### Health Check

```bash
# Check instance health status
az vmss list-instances \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --query "[].{Name:name, HealthState:instanceView.vmHealth.status.displayStatus, PowerState:instanceView.statuses[1].displayStatus}" \
  --output table
```

---

## Best Practices

### Design Considerations

1. **Zone Distribution**: Spread instances across availability zones
2. **Update Strategy**: Use manual updates for critical applications
3. **Instance Types**: Mix different VM sizes as needed
4. **Monitoring**: Implement comprehensive monitoring
5. **Public IP**: Assign public IPs to instances if external access needed

### Security Configuration

```bash
# Create NSG for VMSS
az network nsg create \
  --resource-group rg-vmss-linux \
  --name nsg-vmss

# Allow HTTP traffic
az network nsg rule create \
  --resource-group rg-vmss-linux \
  --nsg-name nsg-vmss \
  --name allow-http \
  --priority 1000 \
  --source-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

# Associate NSG with subnet
az network vnet subnet update \
  --resource-group rg-vmss-linux \
  --vnet-name vnet-vmss \
  --name subnet-vmss \
  --network-security-group nsg-vmss
```

---

## Troubleshooting

### Common Issues

1. **Scaling Failures**: Check quotas and resource limits
2. **Zone Allocation**: Ensure VM SKU supports availability zones
3. **Network Connectivity**: Verify NSG rules and subnet configuration

### Diagnostic Commands

```bash
# Check VMSS events
az vmss get-instance-view \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex

# Check individual instance status
az vmss get-instance-view \
  --resource-group rg-vmss-linux \
  --name vmss-linux-flex \
  --instance-id 0

# Check network configuration
az network vnet subnet show \
  --resource-group rg-vmss-linux \
  --vnet-name vnet-vmss \
  --name subnet-vmss
```

---

## Cleanup

```bash
# Delete Linux VMSS resources
az group delete --name rg-vmss-linux --yes --no-wait

# Delete Windows VMSS resources
az group delete --name rg-vmss-windows --yes --no-wait
```

---

## Summary

This guide covered:
- Creating VMSS with flexible orchestration for Linux and Windows
- Manual scaling operations and instance management
- Web server configuration on VMSS instances
- Best practices for production deployments
- Troubleshooting common issues

Flexible orchestration mode provides greater control over instance management while maintaining the benefits of scale sets for high availability and scalability.
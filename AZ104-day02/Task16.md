# Azure VNet Peering: 3-Tier Networks with Cross-Environment Connectivity

This guide covers creating two 3-tier virtual networks (dev and staging) with VNet peering for secure cross-environment connectivity.

## Architecture Overview

### Network Design
- **Dev Environment**: 3-tier VNet with public, private, and database subnets
- **Staging Environment**: 3-tier VNet with public, private, and database subnets
- **VNet Peering**: Bidirectional connectivity between dev and staging environments
- **VM Placement**: Linux VMs in private subnets for secure communication

### IP Address Planning

| Environment | VNet CIDR | Public Subnets | Private Subnets | Database Subnets |
|-------------|-----------|----------------|-----------------|------------------|
| Dev | 10.10.0.0/16 | 10.10.1.0/24, 10.10.2.0/24 | 10.10.10.0/24, 10.10.11.0/24 | 10.10.20.0/24, 10.10.21.0/24 |
| Staging | 10.20.0.0/16 | 10.20.1.0/24, 10.20.2.0/24 | 10.20.10.0/24, 10.20.11.0/24 | 10.20.20.0/24, 10.20.21.0/24 |

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- SSH key pair for Linux VMs
- Basic understanding of networking concepts

---

## Creating Development Environment

### 1. Create Resource Group and Dev VNet

```bash
# Create resource group
az group create \
  --name rg-3tier-environments \
  --location eastus

# Create development VNet
az network vnet create \
  --resource-group rg-3tier-environments \
  --name vnet-dev \
  --address-prefix 10.10.0.0/16 \
  --location eastus
```

### 2. Create Dev Subnets

```bash
# Create public subnets for dev
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-public-1 \
  --address-prefix 10.10.1.0/24

az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-public-2 \
  --address-prefix 10.10.2.0/24

# Create private subnets for dev
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-private-1 \
  --address-prefix 10.10.10.0/24

az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-private-2 \
  --address-prefix 10.10.11.0/24

# Create database subnets for dev
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-db-1 \
  --address-prefix 10.10.20.0/24

az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-db-2 \
  --address-prefix 10.10.21.0/24
```

---

## Creating Staging Environment

### 1. Create Staging VNet

```bash
# Create staging VNet
az network vnet create \
  --resource-group rg-3tier-environments \
  --name vnet-staging \
  --address-prefix 10.20.0.0/16 \
  --location eastus
```

### 2. Create Staging Subnets

```bash
# Create public subnets for staging
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-public-1 \
  --address-prefix 10.20.1.0/24

az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-public-2 \
  --address-prefix 10.20.2.0/24

# Create private subnets for staging
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-private-1 \
  --address-prefix 10.20.10.0/24

az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-private-2 \
  --address-prefix 10.20.11.0/24

# Create database subnets for staging
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-db-1 \
  --address-prefix 10.20.20.0/24

az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-db-2 \
  --address-prefix 10.20.21.0/24
```

---

## Creating Linux VMs in Private Subnets

### 1. Generate SSH Key

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-3tier-key -N ""
```

### 2. Create VM in Dev Environment

```bash
# Create Linux VM in dev private subnet
az vm create \
  --resource-group rg-3tier-environments \
  --name vm-dev-private \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-3tier-key.pub \
  --vnet-name vnet-dev \
  --subnet subnet-dev-private-1 \
  --private-ip-address 10.10.10.10 \
  --public-ip "" \
  --size Standard_B1s \
  --storage-sku Standard_LRS
```

### 3. Create VM in Staging Environment

```bash
# Create Linux VM in staging private subnet
az vm create \
  --resource-group rg-3tier-environments \
  --name vm-staging-private \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-3tier-key.pub \
  --vnet-name vnet-staging \
  --subnet subnet-staging-private-1 \
  --private-ip-address 10.20.10.10 \
  --public-ip "" \
  --size Standard_B1s \
  --storage-sku Standard_LRS
```

---

## Setting Up VNet Peering

### 1. Create Peering from Dev to Staging

```bash
# Create peering from dev to staging
az network vnet peering create \
  --resource-group rg-3tier-environments \
  --name dev-to-staging \
  --vnet-name vnet-dev \
  --remote-vnet vnet-staging \
  --allow-vnet-access \
  --allow-forwarded-traffic
```

### 2. Create Peering from Staging to Dev

```bash
# Create peering from staging to dev
az network vnet peering create \
  --resource-group rg-3tier-environments \
  --name staging-to-dev \
  --vnet-name vnet-staging \
  --remote-vnet vnet-dev \
  --allow-vnet-access \
  --allow-forwarded-traffic
```

### 3. Verify Peering Status

```bash
# Check dev to staging peering
az network vnet peering show \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name dev-to-staging \
  --query "{Name:name, PeeringState:peeringState, ProvisioningState:provisioningState}"

# Check staging to dev peering
az network vnet peering show \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name staging-to-dev \
  --query "{Name:name, PeeringState:peeringState, ProvisioningState:provisioningState}"
```

---

## Network Security Groups Configuration

### 1. Create NSGs for Dev Environment

```bash
# Create NSG for dev private subnet
az network nsg create \
  --resource-group rg-3tier-environments \
  --name nsg-dev-private \
  --location eastus

# Allow SSH from staging environment
az network nsg rule create \
  --resource-group rg-3tier-environments \
  --nsg-name nsg-dev-private \
  --name allow-ssh-from-staging \
  --priority 100 \
  --source-address-prefixes 10.20.0.0/16 \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow internal dev communication
az network nsg rule create \
  --resource-group rg-3tier-environments \
  --nsg-name nsg-dev-private \
  --name allow-internal-dev \
  --priority 110 \
  --source-address-prefixes 10.10.0.0/16 \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --direction Inbound \
  --access Allow \
  --protocol '*'

# Associate NSG with dev private subnet
az network vnet subnet update \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name subnet-dev-private-1 \
  --network-security-group nsg-dev-private
```

### 2. Create NSGs for Staging Environment

```bash
# Create NSG for staging private subnet
az network nsg create \
  --resource-group rg-3tier-environments \
  --name nsg-staging-private \
  --location eastus

# Allow SSH from dev environment
az network nsg rule create \
  --resource-group rg-3tier-environments \
  --nsg-name nsg-staging-private \
  --name allow-ssh-from-dev \
  --priority 100 \
  --source-address-prefixes 10.10.0.0/16 \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow internal staging communication
az network nsg rule create \
  --resource-group rg-3tier-environments \
  --nsg-name nsg-staging-private \
  --name allow-internal-staging \
  --priority 110 \
  --source-address-prefixes 10.20.0.0/16 \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --direction Inbound \
  --access Allow \
  --protocol '*'

# Associate NSG with staging private subnet
az network vnet subnet update \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name subnet-staging-private-1 \
  --network-security-group nsg-staging-private
```

---

## Creating Bastion for Management Access

### 1. Create Bastion Subnet in Dev

```bash
# Create AzureBastionSubnet in dev VNet
az network vnet subnet create \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name AzureBastionSubnet \
  --address-prefix 10.10.100.0/26

# Create public IP for Bastion
az network public-ip create \
  --resource-group rg-3tier-environments \
  --name pip-bastion-dev \
  --sku Standard \
  --allocation-method Static \
  --location eastus

# Create Azure Bastion
az network bastion create \
  --resource-group rg-3tier-environments \
  --name bastion-dev \
  --public-ip-address pip-bastion-dev \
  --vnet-name vnet-dev \
  --location eastus \
  --sku Basic
```

---

## Testing Connectivity

### 1. Connect to Dev VM via Bastion

```bash
# Connect to dev VM using Bastion
az network bastion ssh \
  --name bastion-dev \
  --resource-group rg-3tier-environments \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-3tier-environments/providers/Microsoft.Compute/virtualMachines/vm-dev-private \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-3tier-key
```

### 2. Test Cross-Environment Connectivity

```bash
# From dev VM, test connectivity to staging VM
# (Run these commands after connecting to dev VM via Bastion)

# Test ping to staging VM
ping 10.20.10.10

# Test SSH connectivity to staging VM
ssh -i ~/.ssh/azure-3tier-key azureuser@10.20.10.10

# Test network connectivity
nc -zv 10.20.10.10 22
```

### 3. Verify Network Routes

```bash
# Check effective routes on dev VM NIC
az network nic show-effective-route-table \
  --resource-group rg-3tier-environments \
  --name vm-dev-privateVMNic \
  --output table

# Check effective routes on staging VM NIC
az network nic show-effective-route-table \
  --resource-group rg-3tier-environments \
  --name vm-staging-privateVMNic \
  --output table
```

---

## Application Deployment Simulation

### 1. Install Web Server on Dev VM

```bash
# Connect to dev VM and install nginx
az vm run-command invoke \
  --resource-group rg-3tier-environments \
  --name vm-dev-private \
  --command-id RunShellScript \
  --scripts "
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo '<h1>Development Environment</h1><p>Server: $(hostname)</p><p>IP: $(hostname -I)</p>' | sudo tee /var/www/html/index.html
  "
```

### 2. Install Web Server on Staging VM

```bash
# Connect to staging VM and install nginx
az vm run-command invoke \
  --resource-group rg-3tier-environments \
  --name vm-staging-private \
  --command-id RunShellScript \
  --scripts "
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo '<h1>Staging Environment</h1><p>Server: $(hostname)</p><p>IP: $(hostname -I)</p>' | sudo tee /var/www/html/index.html
  "
```

### 3. Test Web Connectivity

```bash
# Test HTTP connectivity between environments
# From dev VM to staging VM
curl http://10.20.10.10

# From staging VM to dev VM (via Bastion connection)
curl http://10.10.10.10
```

---

## Advanced Networking Configuration

### 1. Configure Route Tables

```bash
# Create route table for custom routing
az network route-table create \
  --resource-group rg-3tier-environments \
  --name rt-cross-environment \
  --location eastus

# Add route for dev to staging communication
az network route-table route create \
  --resource-group rg-3tier-environments \
  --route-table-name rt-cross-environment \
  --name route-dev-to-staging \
  --address-prefix 10.20.0.0/16 \
  --next-hop-type VnetPeering

# Add route for staging to dev communication
az network route-table route create \
  --resource-group rg-3tier-environments \
  --route-table-name rt-cross-environment \
  --name route-staging-to-dev \
  --address-prefix 10.10.0.0/16 \
  --next-hop-type VnetPeering
```

---

## Monitoring and Diagnostics

### 1. Enable Network Watcher

```bash
# Enable Network Watcher
az network watcher configure \
  --resource-group rg-3tier-environments \
  --locations eastus \
  --enabled true

# Test connectivity between VMs
az network watcher test-connectivity \
  --resource-group rg-3tier-environments \
  --source-resource vm-dev-private \
  --dest-resource vm-staging-private \
  --dest-port 22
```

### 2. Create Connection Monitor

```bash
# Create connection monitor
az network watcher connection-monitor create \
  --resource-group rg-3tier-environments \
  --name connection-monitor-cross-env \
  --source-resource vm-dev-private \
  --dest-resource vm-staging-private \
  --dest-port 80 \
  --monitoring-interval 30
```

### 3. Enable Flow Logs

```bash
# Create storage account for flow logs
az storage account create \
  --resource-group rg-3tier-environments \
  --name stflowlogs$(date +%s) \
  --sku Standard_LRS \
  --location eastus

# Enable NSG flow logs for dev environment
az network watcher flow-log create \
  --resource-group rg-3tier-environments \
  --name flowlog-dev-private \
  --nsg nsg-dev-private \
  --storage-account stflowlogs* \
  --enabled true \
  --retention 7 \
  --format JSON \
  --log-version 2
```

---

## Security Enhancements

### 1. Create Application Security Groups

```bash
# Create ASGs for better security management
az network asg create \
  --resource-group rg-3tier-environments \
  --name asg-dev-app-servers \
  --location eastus

az network asg create \
  --resource-group rg-3tier-environments \
  --name asg-staging-app-servers \
  --location eastus

# Associate VMs with ASGs
az network nic ip-config update \
  --resource-group rg-3tier-environments \
  --nic-name vm-dev-privateVMNic \
  --name ipconfigvm-dev-private \
  --application-security-groups asg-dev-app-servers

az network nic ip-config update \
  --resource-group rg-3tier-environments \
  --nic-name vm-staging-privateVMNic \
  --name ipconfigvm-staging-private \
  --application-security-groups asg-staging-app-servers
```

### 2. Enhanced NSG Rules with ASGs

```bash
# Create rule allowing dev ASG to staging ASG
az network nsg rule create \
  --resource-group rg-3tier-environments \
  --nsg-name nsg-staging-private \
  --name allow-dev-asg-to-staging \
  --priority 90 \
  --source-asgs asg-dev-app-servers \
  --destination-asgs asg-staging-app-servers \
  --destination-port-ranges 80 443 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

---

## Backup and Disaster Recovery

### 1. Create VM Snapshots

```bash
# Create snapshot of dev VM OS disk
DEV_DISK_ID=$(az vm show --resource-group rg-3tier-environments --name vm-dev-private --query "storageProfile.osDisk.managedDisk.id" -o tsv)

az snapshot create \
  --resource-group rg-3tier-environments \
  --name snapshot-dev-vm-$(date +%Y%m%d) \
  --source $DEV_DISK_ID

# Create snapshot of staging VM OS disk
STAGING_DISK_ID=$(az vm show --resource-group rg-3tier-environments --name vm-staging-private --query "storageProfile.osDisk.managedDisk.id" -o tsv)

az snapshot create \
  --resource-group rg-3tier-environments \
  --name snapshot-staging-vm-$(date +%Y%m%d) \
  --source $STAGING_DISK_ID
```

---

## Performance Optimization

### 1. Enable Accelerated Networking

```bash
# Update dev VM NIC for accelerated networking
az network nic update \
  --resource-group rg-3tier-environments \
  --name vm-dev-privateVMNic \
  --accelerated-networking true

# Update staging VM NIC for accelerated networking
az network nic update \
  --resource-group rg-3tier-environments \
  --name vm-staging-privateVMNic \
  --accelerated-networking true
```

### 2. Optimize VM Sizes

```bash
# Resize VMs for better performance if needed
az vm resize \
  --resource-group rg-3tier-environments \
  --name vm-dev-private \
  --size Standard_B2s

az vm resize \
  --resource-group rg-3tier-environments \
  --name vm-staging-private \
  --size Standard_B2s
```

---

## Troubleshooting

### 1. Common Connectivity Issues

```bash
# Check peering status
az network vnet peering list \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --output table

# Verify NSG effective rules
az network nic list-effective-nsg \
  --resource-group rg-3tier-environments \
  --name vm-dev-privateVMNic

# Test IP flow
az network watcher test-ip-flow \
  --resource-group rg-3tier-environments \
  --vm vm-dev-private \
  --direction Outbound \
  --protocol TCP \
  --local 10.10.10.10:22 \
  --remote 10.20.10.10:22
```

### 2. Performance Diagnostics

```bash
# Check VM performance metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-3tier-environments/providers/Microsoft.Compute/virtualMachines/vm-dev-private \
  --metric "Percentage CPU" \
  --interval PT1M

# Monitor network performance
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-3tier-environments/providers/Microsoft.Network/networkInterfaces/vm-dev-privateVMNic \
  --metric "BytesReceivedRate" \
  --interval PT1M
```

---

## Cleanup

```bash
# Delete Bastion (takes time)
az network bastion delete \
  --name bastion-dev \
  --resource-group rg-3tier-environments

# Delete VNet peerings
az network vnet peering delete \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-dev \
  --name dev-to-staging

az network vnet peering delete \
  --resource-group rg-3tier-environments \
  --vnet-name vnet-staging \
  --name staging-to-dev

# Delete entire resource group
az group delete \
  --name rg-3tier-environments \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Creating two 3-tier virtual networks (dev and staging environments)
- Implementing proper subnet segmentation for each tier
- Deploying Linux VMs in private subnets for security
- Establishing VNet peering for cross-environment connectivity
- Configuring Network Security Groups for controlled access
- Setting up Azure Bastion for secure management access
- Testing connectivity and deploying sample applications
- Advanced networking features and security enhancements
- Monitoring, diagnostics, and troubleshooting procedures

The architecture provides a secure, scalable foundation for multi-environment deployments with proper network isolation and controlled connectivity between development and staging environments.
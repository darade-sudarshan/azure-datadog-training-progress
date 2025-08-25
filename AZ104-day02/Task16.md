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

## Manual VNet Peering Creation via Azure Portal

### 1. Create Resource Group and Dev VNet via Portal

#### Create Resource Group
1. Navigate to **Resource groups** in Azure Portal
2. Click **Create**
3. **Basics tab**:
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Region**: `Southeast Asia`
4. Click **Review + create** > **Create**

#### Create Development VNet
1. Navigate to **Virtual networks**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `vnet-dev`
   - **Region**: `Southeast Asia`
4. **IP Addresses tab**:
   - **IPv4 address space**: `10.10.0.0/16`
   - Click **Add subnet**:
     - **Subnet name**: `subnet-dev-public-1`
     - **Subnet address range**: `10.10.1.0/24`
   - Add additional subnets:
     - `subnet-dev-public-2`: `10.10.2.0/24`
     - `subnet-dev-private-1`: `10.10.10.0/24`
     - `subnet-dev-private-2`: `10.10.11.0/24`
     - `subnet-dev-db-1`: `10.10.20.0/24`
     - `subnet-dev-db-2`: `10.10.21.0/24`
5. **Security tab**: Configure as needed
6. Click **Review + create** > **Create**

#### Create Staging VNet
1. Navigate to **Virtual networks** > **Create**
2. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `vnet-staging`
   - **Region**: `Southeast Asia`
3. **IP Addresses tab**:
   - **IPv4 address space**: `10.20.0.0/16`
   - Add subnets:
     - `subnet-staging-public-1`: `10.20.1.0/24`
     - `subnet-staging-public-2`: `10.20.2.0/24`
     - `subnet-staging-private-1`: `10.20.10.0/24`
     - `subnet-staging-private-2`: `10.20.11.0/24`
     - `subnet-staging-db-1`: `10.20.20.0/24`
     - `subnet-staging-db-2`: `10.20.21.0/24`
4. Click **Review + create** > **Create**

### 2. Create Linux VMs via Portal

#### Create VM in Dev Environment
1. Navigate to **Virtual machines** > **Create**
2. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Virtual machine name**: `vm-dev-private`
   - **Region**: `Southeast Asia`
   - **Image**: `Ubuntu Server 22.04 LTS`
   - **Size**: `Standard_B1s`
   - **Authentication type**: `SSH public key`
   - **Username**: `azureuser`
   - **SSH public key source**: `Generate new key pair` or `Use existing`
3. **Networking tab**:
   - **Virtual network**: `vnet-dev`
   - **Subnet**: `subnet-dev-private-1`
   - **Public IP**: `None`
   - **Private IP**: `Static` - `10.10.10.10`
4. Click **Review + create** > **Create**

#### Create VM in Staging Environment
1. Repeat VM creation process with:
   - **Virtual machine name**: `vm-staging-private`
   - **Virtual network**: `vnet-staging`
   - **Subnet**: `subnet-staging-private-1`
   - **Private IP**: `Static` - `10.20.10.10`

### 3. Create VNet Peering via Portal

#### Create Dev to Staging Peering
1. Navigate to **Virtual networks** > `vnet-dev`
2. Click **Peerings** in left menu
3. Click **Add**
4. **This virtual network**:
   - **Peering link name**: `dev-to-staging`
   - **Traffic to remote virtual network**: `Allow`
   - **Traffic forwarded from remote virtual network**: `Allow`
   - **Virtual network gateway or Route Server**: `None`
5. **Remote virtual network**:
   - **Peering link name**: `staging-to-dev`
   - **Virtual network deployment model**: `Resource manager`
   - **Subscription**: Select your subscription
   - **Virtual network**: `vnet-staging`
   - **Traffic to remote virtual network**: `Allow`
   - **Traffic forwarded from remote virtual network**: `Allow`
   - **Virtual network gateway or Route Server**: `None`
6. Click **Add**

#### Verify Peering Status
1. Navigate to **Virtual networks** > `vnet-dev` > **Peerings**
2. Verify peering status shows **Connected**
3. Check `vnet-staging` > **Peerings** for reciprocal connection

### 4. Create Network Security Groups via Portal

#### Create NSG for Dev Environment
1. Navigate to **Network security groups** > **Create**
2. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `nsg-dev-private`
   - **Region**: `Southeast Asia`
3. Click **Review + create** > **Create**
4. Navigate to created NSG > **Inbound security rules**
5. Click **Add** to create rules:
   - **Rule 1**: Allow SSH from staging
     - **Source**: `IP Addresses`
     - **Source IP addresses/CIDR ranges**: `10.20.0.0/16`
     - **Destination port ranges**: `22`
     - **Protocol**: `TCP`
     - **Action**: `Allow`
     - **Priority**: `100`
     - **Name**: `allow-ssh-from-staging`
   - **Rule 2**: Allow internal dev communication
     - **Source**: `IP Addresses`
     - **Source IP addresses/CIDR ranges**: `10.10.0.0/16`
     - **Destination port ranges**: `*`
     - **Protocol**: `Any`
     - **Action**: `Allow`
     - **Priority**: `110`
     - **Name**: `allow-internal-dev`

#### Associate NSG with Subnet
1. Navigate to **Virtual networks** > `vnet-dev` > **Subnets**
2. Click `subnet-dev-private-1`
3. **Network security group**: Select `nsg-dev-private`
4. Click **Save**

#### Create NSG for Staging Environment
1. Repeat NSG creation process for staging:
   - **Name**: `nsg-staging-private`
   - Create similar rules for staging environment
   - Associate with `subnet-staging-private-1`

### 5. Create Azure Bastion via Portal

#### Add Bastion Subnet
1. Navigate to **Virtual networks** > `vnet-dev` > **Subnets**
2. Click **+ Subnet**
3. **Name**: `AzureBastionSubnet` (exact name required)
4. **Subnet address range**: `10.10.100.0/26`
5. Click **Save**

#### Create Bastion Host
1. Navigate to **Bastions** > **Create**
2. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `bastion-dev`
   - **Region**: `Southeast Asia`
   - **Tier**: `Basic`
   - **Virtual network**: `vnet-dev`
   - **Subnet**: `AzureBastionSubnet` (auto-selected)
3. **Public IP address**: `Create new`
   - **Public IP name**: `pip-bastion-dev`
4. Click **Review + create** > **Create**

### 6. Test Connectivity via Portal

#### Connect to VM via Bastion
1. Navigate to **Virtual machines** > `vm-dev-private`
2. Click **Connect** > **Bastion**
3. **Authentication Type**: `SSH Private Key from Local File`
4. **Username**: `azureuser`
5. **Local File**: Upload your private key file
6. Click **Connect**

#### Test Cross-Environment Connectivity
1. From Bastion session to dev VM:
   ```bash
   # Test ping to staging VM
   ping 10.20.10.10
   
   # Test SSH to staging VM
   ssh azureuser@10.20.10.10
   ```

### 7. Create Application Security Groups via Portal

#### Create ASGs
1. Navigate to **Application security groups** > **Create**
2. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `asg-dev-app-servers`
   - **Region**: `Southeast Asia`
3. Repeat for `asg-staging-app-servers`

#### Associate VMs with ASGs
1. Navigate to **Virtual machines** > `vm-dev-private` > **Networking**
2. Click **Application security groups**
3. Click **Configure the application security groups**
4. Select `asg-dev-app-servers`
5. Click **Save**
6. Repeat for staging VM

### 8. Monitor Peering via Portal

#### View Peering Metrics
1. Navigate to **Virtual networks** > `vnet-dev` > **Peerings**
2. Click on peering name to view details
3. Check **Peering state**: Should show `Connected`
4. View **Provisioning state**: Should show `Succeeded`

#### Network Watcher Integration
1. Navigate to **Network Watcher**
2. Use **Connection troubleshoot** to test VM-to-VM connectivity
3. Configure **Connection monitor** for ongoing monitoring

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create Resource Group
New-AzResourceGroup -Name "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia"

# Create Dev VNet with subnets
$devSubnets = @(
    New-AzVirtualNetworkSubnetConfig -Name "subnet-dev-public-1" -AddressPrefix "10.10.1.0/24"
    New-AzVirtualNetworkSubnetConfig -Name "subnet-dev-private-1" -AddressPrefix "10.10.10.0/24"
    New-AzVirtualNetworkSubnetConfig -Name "subnet-dev-db-1" -AddressPrefix "10.10.20.0/24"
)
$devVNet = New-AzVirtualNetwork -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "vnet-dev" -AddressPrefix "10.10.0.0/16" -Subnet $devSubnets

# Create Staging VNet with subnets
$stagingSubnets = @(
    New-AzVirtualNetworkSubnetConfig -Name "subnet-staging-public-1" -AddressPrefix "10.20.1.0/24"
    New-AzVirtualNetworkSubnetConfig -Name "subnet-staging-private-1" -AddressPrefix "10.20.10.0/24"
    New-AzVirtualNetworkSubnetConfig -Name "subnet-staging-db-1" -AddressPrefix "10.20.20.0/24"
)
$stagingVNet = New-AzVirtualNetwork -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "vnet-staging" -AddressPrefix "10.20.0.0/16" -Subnet $stagingSubnets

# Create VNet Peering
Add-AzVirtualNetworkPeering -Name "dev-to-staging" -VirtualNetwork $devVNet -RemoteVirtualNetworkId $stagingVNet.Id -AllowForwardedTraffic
Add-AzVirtualNetworkPeering -Name "staging-to-dev" -VirtualNetwork $stagingVNet -RemoteVirtualNetworkId $devVNet.Id -AllowForwardedTraffic

# Create NSG with rules
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "allow-ssh-from-staging" -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix "10.20.0.0/16" -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "nsg-dev-private" -SecurityRules $nsgRule1

# Create Application Security Groups
New-AzApplicationSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "asg-dev-app-servers" -Location "Southeast Asia"
New-AzApplicationSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "asg-staging-app-servers" -Location "Southeast Asia"
```

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
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia

# Create development VNet
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-dev \
  --address-prefix 10.10.0.0/16 \
  --location southeastasia
```

### 2. Create Dev Subnets

```bash
# Create public subnets for dev
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name subnet-dev-public-1 \
  --address-prefix 10.10.1.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name subnet-dev-public-2 \
  --address-prefix 10.10.2.0/24

# Create private subnets for dev
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name subnet-dev-private-1 \
  --address-prefix 10.10.10.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name subnet-dev-private-2 \
  --address-prefix 10.10.11.0/24

# Create database subnets for dev
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name subnet-dev-db-1 \
  --address-prefix 10.10.20.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-staging \
  --address-prefix 10.20.0.0/16 \
  --location southeastasia
```

### 2. Create Staging Subnets

```bash
# Create public subnets for staging
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-staging \
  --name subnet-staging-public-1 \
  --address-prefix 10.20.1.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-staging \
  --name subnet-staging-public-2 \
  --address-prefix 10.20.2.0/24

# Create private subnets for staging
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-staging \
  --name subnet-staging-private-1 \
  --address-prefix 10.20.10.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-staging \
  --name subnet-staging-private-2 \
  --address-prefix 10.20.11.0/24

# Create database subnets for staging
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-staging \
  --name subnet-staging-db-1 \
  --address-prefix 10.20.20.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name dev-to-staging \
  --query "{Name:name, PeeringState:peeringState, ProvisioningState:provisioningState}"

# Check staging to dev peering
az network vnet peering show \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-dev-private \
  --location southeastasia

# Allow SSH from staging environment
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name subnet-dev-private-1 \
  --network-security-group nsg-dev-private
```

### 2. Create NSGs for Staging Environment

```bash
# Create NSG for staging private subnet
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-staging-private \
  --location southeastasia

# Allow SSH from dev environment
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name AzureBastionSubnet \
  --address-prefix 10.10.100.0/26

# Create public IP for Bastion
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-bastion-dev \
  --sku Standard \
  --allocation-method Static \
  --location southeastasia

# Create Azure Bastion
az network bastion create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name bastion-dev \
  --public-ip-address pip-bastion-dev \
  --vnet-name vnet-dev \
  --location southeastasia \
  --sku Basic
```

---

## Testing Connectivity

### 1. Connect to Dev VM via Bastion

```bash
# Connect to dev VM using Bastion
az network bastion ssh \
  --name bastion-dev \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/virtualMachines/vm-dev-private \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-dev-privateVMNic \
  --output table

# Check effective routes on staging VM NIC
az network nic show-effective-route-table \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-staging-privateVMNic \
  --output table
```

---

## Application Deployment Simulation

### 1. Install Web Server on Dev VM

```bash
# Connect to dev VM and install nginx
az vm run-command invoke \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name rt-cross-environment \
  --location southeastasia

# Add route for dev to staging communication
az network route-table route create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --route-table-name rt-cross-environment \
  --name route-dev-to-staging \
  --address-prefix 10.20.0.0/16 \
  --next-hop-type VnetPeering

# Add route for staging to dev communication
az network route-table route create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --locations southeastasia \
  --enabled true

# Test connectivity between VMs
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource vm-dev-private \
  --dest-resource vm-staging-private \
  --dest-port 22
```

### 2. Create Connection Monitor

```bash
# Create connection monitor
az network watcher connection-monitor create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name stflowlogs$(date +%s) \
  --sku Standard_LRS \
  --location southeastasia

# Enable NSG flow logs for dev environment
az network watcher flow-log create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-dev-app-servers \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-staging-app-servers \
  --location southeastasia

# Associate VMs with ASGs
az network nic ip-config update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nic-name vm-dev-privateVMNic \
  --name ipconfigvm-dev-private \
  --application-security-groups asg-dev-app-servers

az network nic ip-config update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nic-name vm-staging-privateVMNic \
  --name ipconfigvm-staging-private \
  --application-security-groups asg-staging-app-servers
```

### 2. Enhanced NSG Rules with ASGs

```bash
# Create rule allowing dev ASG to staging ASG
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
DEV_DISK_ID=$(az vm show --resource-group sa1_test_eic_SudarshanDarade --name vm-dev-private --query "storageProfile.osDisk.managedDisk.id" -o tsv)

az snapshot create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name snapshot-dev-vm-$(date +%Y%m%d) \
  --source $DEV_DISK_ID

# Create snapshot of staging VM OS disk
STAGING_DISK_ID=$(az vm show --resource-group sa1_test_eic_SudarshanDarade --name vm-staging-private --query "storageProfile.osDisk.managedDisk.id" -o tsv)

az snapshot create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name snapshot-staging-vm-$(date +%Y%m%d) \
  --source $STAGING_DISK_ID
```

---

## Performance Optimization

### 1. Enable Accelerated Networking

```bash
# Update dev VM NIC for accelerated networking
az network nic update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-dev-privateVMNic \
  --accelerated-networking true

# Update staging VM NIC for accelerated networking
az network nic update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-staging-privateVMNic \
  --accelerated-networking true
```

### 2. Optimize VM Sizes

```bash
# Resize VMs for better performance if needed
az vm resize \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-dev-private \
  --size Standard_B2s

az vm resize \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-staging-private \
  --size Standard_B2s
```

---

## Troubleshooting

### 1. Common Connectivity Issues

```bash
# Check peering status
az network vnet peering list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --output table

# Verify NSG effective rules
az network nic list-effective-nsg \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-dev-privateVMNic

# Test IP flow
az network watcher test-ip-flow \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/virtualMachines/vm-dev-private \
  --metric "Percentage CPU" \
  --interval PT1M

# Monitor network performance
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/networkInterfaces/vm-dev-privateVMNic \
  --metric "BytesReceivedRate" \
  --interval PT1M
```

---

## Cleanup

```bash
# Delete Bastion (takes time)
az network bastion delete \
  --name bastion-dev \
  --resource-group sa1_test_eic_SudarshanDarade

# Delete VNet peerings
az network vnet peering delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-dev \
  --name dev-to-staging

az network vnet peering delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-staging \
  --name staging-to-dev

# Delete entire resource group
az group delete \
  --name sa1_test_eic_SudarshanDarade \
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
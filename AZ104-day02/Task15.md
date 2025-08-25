# Azure Bastion: Cross-Region and Transitive VNet Peering

This guide covers creating Azure Bastion and using it across regions and in transitive VNet peering scenarios for secure VM access.

## Understanding Azure Bastion

### Azure Bastion
- **Definition**: Fully managed PaaS service providing secure RDP/SSH connectivity
- **Benefits**: No public IPs needed, browser-based access, integrated with Azure portal
- **Security**: Traffic stays within Azure backbone, no exposure to internet
- **Protocols**: RDP (Windows), SSH (Linux), native client support

### Bastion Deployment Models
- **Basic SKU**: Standard features, up to 25 concurrent sessions
- **Standard SKU**: Enhanced features, up to 50 concurrent sessions, native client support
- **Premium SKU**: Advanced features, up to 100 concurrent sessions, private-only mode

### Cross-Region Access Scenarios
- **Hub-Spoke**: Bastion in hub region accessing spokes in different regions
- **Multi-Region**: Separate Bastion instances in each region
- **Transitive Peering**: Access through multiple VNet peering hops

---

## Manual Azure Bastion Creation via Azure Portal

### Creating Azure Bastion via Portal

#### 1. Create Virtual Network with Bastion Subnet
1. Navigate to **Virtual networks**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `vnet-hub-portal`
   - **Region**: `Southeast Asia`
4. **IP Addresses tab**:
   - **IPv4 address space**: `10.0.0.0/16`
   - **Subnets**: Add subnets
     - **Subnet name**: `subnet-hub`
     - **Subnet address range**: `10.0.1.0/24`
   - Click **Add subnet**:
     - **Subnet name**: `AzureBastionSubnet` (exact name required)
     - **Subnet address range**: `10.0.100.0/26` (minimum /26)
5. Click **Review + create** > **Create**

#### 2. Create Azure Bastion
1. Navigate to **Bastions**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `bastion-hub-portal`
   - **Region**: `Southeast Asia`
   - **Tier**: `Standard` (for advanced features)
   - **Instance count**: `2` (for scaling)
   - **Virtual network**: Select `vnet-hub-portal`
   - **Subnet**: `AzureBastionSubnet` (auto-selected)

4. **Advanced tab** (Standard tier):
   - **Native client support**: `Enable`
   - **IP-based connection**: `Enable`
   - **File copy**: `Enable`
   - **Shareable link**: `Enable`

5. **Tags tab**: Add tags as needed
6. Click **Review + create** > **Create**

### Creating Cross-Region VNets via Portal

#### 1. Create Spoke VNet (West US)
1. Navigate to **Virtual networks** > **Create**
2. **Basics tab**:
   - **Resource group**: Create new `rg-spoke-west-portal`
   - **Name**: `vnet-spoke-west-portal`
   - **Region**: `West US`
3. **IP Addresses tab**:
   - **IPv4 address space**: `10.1.0.0/16`
   - **Subnet name**: `subnet-spoke`
   - **Subnet address range**: `10.1.1.0/24`
4. Click **Review + create** > **Create**

#### 2. Create VM in Spoke Network
1. Navigate to **Virtual machines** > **Create**
2. **Basics tab**:
   - **Resource group**: `rg-spoke-west-portal`
   - **Virtual machine name**: `vm-spoke-west`
   - **Region**: `West US`
   - **Image**: `Ubuntu 22.04 LTS`
   - **Size**: `Standard_B1s`
   - **Authentication type**: `SSH public key`
   - **Username**: `azureuser`
   - **SSH public key**: Upload or generate key
3. **Networking tab**:
   - **Virtual network**: `vnet-spoke-west-portal`
   - **Subnet**: `subnet-spoke`
   - **Public IP**: `None`
   - **NIC network security group**: `Basic`
4. Click **Review + create** > **Create**

### VNet Peering Configuration via Portal

#### 1. Create Hub-to-Spoke Peering
1. Navigate to **Virtual networks**
2. Select `vnet-hub-portal`
3. Go to **Settings** > **Peerings**
4. Click **Add**
5. **Add peering**:
   - **This virtual network**:
     - **Peering link name**: `hub-to-west-spoke`
     - **Traffic to remote virtual network**: `Allow`
     - **Traffic forwarded from remote virtual network**: `Allow`
     - **Virtual network gateway or Route Server**: `Use this virtual network's gateway or Route Server`
   - **Remote virtual network**:
     - **Peering link name**: `west-spoke-to-hub`
     - **Virtual network deployment model**: `Resource manager`
     - **Subscription**: Select subscription
     - **Virtual network**: `vnet-spoke-west-portal`
     - **Traffic to remote virtual network**: `Allow`
     - **Traffic forwarded from remote virtual network**: `Allow`
     - **Virtual network gateway or Route Server**: `Use the remote virtual network's gateway or Route Server`
6. Click **Add**

#### 2. Verify Peering Status
1. Check peering status in both VNets
2. Status should show `Connected`
3. **Peering state**: `Connected`
4. **Gateway transit**: Configured as needed

### Transitive Peering Setup via Portal

#### 1. Create Additional Networks
1. **Create East US 2 Spoke**:
   - **Name**: `vnet-spoke-east2-portal`
   - **Region**: `East US 2`
   - **Address space**: `10.3.0.0/16`
   - **Subnet**: `10.3.1.0/24`

2. **Create Transitive Network**:
   - **Name**: `vnet-transitive-portal`
   - **Region**: `East US 2`
   - **Address space**: `10.4.0.0/16`
   - **Subnet**: `10.4.1.0/24`

#### 2. Configure Transitive Peering
1. **Peer Hub ↔ East US 2 Spoke**
2. **Peer East US 2 Spoke ↔ Transitive Network**
3. **Configure Route Tables** (if needed):
   - Navigate to **Route tables** > **Create**
   - **Name**: `rt-transitive-access`
   - **Region**: `East US 2`
   - Add routes for transitive connectivity

### Using Azure Bastion via Portal

#### 1. Connect to VM via Bastion
1. Navigate to **Virtual machines**
2. Select target VM (e.g., `vm-spoke-west`)
3. Click **Connect** > **Bastion**
4. **Connection Settings**:
   - **Authentication Type**: `SSH Private Key from Local File`
   - **Username**: `azureuser`
   - **Local File**: Upload SSH private key
5. Click **Connect**
6. Browser-based SSH session opens

#### 2. Connect to Windows VM via RDP
1. Select Windows VM
2. Click **Connect** > **Bastion**
3. **Connection Settings**:
   - **Authentication Type**: `Password`
   - **Username**: `azureuser`
   - **Password**: Enter password
4. Click **Connect**
5. Browser-based RDP session opens

#### 3. Advanced Connection Options
1. **Native Client Connection**:
   - Click **Connect** > **Bastion**
   - **Connection Settings**: `Native Client`
   - **Protocol**: `SSH` or `RDP`
   - **Port**: Custom port if needed
   - Click **Connect**
   - Download connection file or use CLI command

2. **IP-based Connection**:
   - **Authentication Type**: Select type
   - **Connect using**: `IP Address`
   - **IP Address**: Enter private IP
   - **Port**: Enter port number

### Regional Bastion Deployment via Portal

#### 1. Create Bastion in Each Region
1. **West US Bastion**:
   - Add `AzureBastionSubnet` to `vnet-spoke-west-portal`
   - **Subnet address range**: `10.1.100.0/26`
   - Create Bastion: `bastion-west-portal`

2. **East US 2 Bastion**:
   - Add `AzureBastionSubnet` to `vnet-spoke-east2-portal`
   - **Subnet address range**: `10.3.100.0/26`
   - Create Bastion: `bastion-east2-portal`

#### 2. Compare Access Methods
1. **Hub Bastion Model**:
   - Single Bastion in hub region
   - Access all regions through peering
   - Lower cost, higher latency

2. **Regional Bastion Model**:
   - Bastion in each region
   - Local access, lower latency
   - Higher cost, better performance

### Monitoring and Diagnostics via Portal

#### 1. Bastion Metrics
1. Navigate to your Bastion
2. Go to **Monitoring** > **Metrics**
3. **Metrics**: Select metrics:
   - `Sessions`
   - `Total Sessions`
   - `Data Processed`
4. **Time range**: Configure period
5. **Chart type**: Line, bar, etc.

#### 2. Diagnostic Logs
1. Go to **Monitoring** > **Diagnostic settings**
2. Click **Add diagnostic setting**
3. **Diagnostic setting name**: `bastion-diagnostics`
4. **Logs**: Select categories:
   - `BastionAuditLogs`
5. **Destination details**: Log Analytics workspace
6. Click **Save**

#### 3. Connection Troubleshooting
1. Navigate to **Network Watcher**
2. Go to **Network diagnostic tools** > **Connection troubleshoot**
3. **Source**: Select Bastion or VM
4. **Destination**: Select target VM
5. **Destination port**: `22` (SSH) or `3389` (RDP)
6. Click **Check**
7. Review connectivity results

### Security Configuration via Portal

#### 1. Network Security Groups for Bastion
1. Navigate to **Network security groups**
2. Create NSG: `nsg-bastion-subnet`
3. **Inbound rules**:
   - **Allow HTTPS from Internet**: Priority 100, Port 443
   - **Allow GatewayManager**: Priority 110, Service Tag
   - **Allow Azure Load Balancer**: Priority 120
4. **Outbound rules**:
   - **Allow SSH/RDP to VNet**: Priority 100, Ports 22,3389
   - **Allow Azure Cloud**: Priority 110, Service Tag
5. **Associate with subnet**:
   - Go to **Subnets** > Select `AzureBastionSubnet`
   - **Network security group**: Select NSG

#### 2. Access Control (IAM)
1. Navigate to Bastion resource
2. Go to **Access control (IAM)**
3. Click **Add** > **Add role assignment**
4. **Role**: `Virtual Machine User Login` or custom role
5. **Assign access to**: User, group, or service principal
6. **Select**: Choose users/groups
7. Click **Save**

### Cost Management via Portal

#### 1. Cost Analysis
1. Navigate to **Cost Management + Billing**
2. Go to **Cost analysis**
3. **Scope**: Select subscription/resource group
4. **Filter**: Add filter for Bastion resources
5. **Group by**: Resource type, Location
6. Analyze Bastion costs across regions

#### 2. Budgets and Alerts
1. Go to **Budgets**
2. Click **Add**
3. **Budget details**:
   - **Name**: `Bastion-Budget`
   - **Amount**: Set monthly limit
   - **Filters**: Bastion resources
4. **Alert conditions**: Set thresholds
5. **Alert recipients**: Add email addresses

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create virtual network with Bastion subnet
$bastionSubnet = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix "10.0.100.0/26"
$hubSubnet = New-AzVirtualNetworkSubnetConfig -Name "subnet-hub" -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "vnet-hub-ps" -AddressPrefix "10.0.0.0/16" -Subnet $bastionSubnet,$hubSubnet

# Create public IP for Bastion
$publicIP = New-AzPublicIpAddress -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "pip-bastion-ps" -AllocationMethod Static -Sku Standard

# Create Azure Bastion
New-AzBastion -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "bastion-hub-ps" -PublicIpAddress $publicIP -VirtualNetwork $vnet -Sku "Standard"

# Create spoke virtual network
$spokeSubnet = New-AzVirtualNetworkSubnetConfig -Name "subnet-spoke" -AddressPrefix "10.1.1.0/24"
$spokeVnet = New-AzVirtualNetwork -ResourceGroupName "rg-spoke-ps" -Location "West US" -Name "vnet-spoke-ps" -AddressPrefix "10.1.0.0/16" -Subnet $spokeSubnet

# Create VNet peering
Add-AzVirtualNetworkPeering -Name "hub-to-spoke-ps" -VirtualNetwork $vnet -RemoteVirtualNetworkId $spokeVnet.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name "spoke-to-hub-ps" -VirtualNetwork $spokeVnet -RemoteVirtualNetworkId $vnet.Id -AllowForwardedTraffic -UseRemoteGateways

# Create VM in spoke network
$vmConfig = New-AzVMConfig -VMName "vm-spoke-ps" -VMSize "Standard_B1s"
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName "vm-spoke-ps" -Credential (Get-Credential)
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest"
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id (New-AzNetworkInterface -ResourceGroupName "rg-spoke-ps" -Location "West US" -Name "nic-vm-spoke-ps" -SubnetId $spokeVnet.Subnets[0].Id).Id

New-AzVM -ResourceGroupName "rg-spoke-ps" -Location "West US" -VM $vmConfig

# Connect to VM via Bastion (requires Azure PowerShell with Bastion module)
Connect-AzBastion -ResourceGroupName "sa1_test_eic_SudarshanDarade" -BastionName "bastion-hub-ps" -TargetVMId "/subscriptions/{subscription-id}/resourceGroups/rg-spoke-ps/providers/Microsoft.Compute/virtualMachines/vm-spoke-ps" -Protocol SSH
```

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Multiple regions for testing
- Virtual networks and VMs in different regions

---

## Basic Azure Bastion Setup

### 1. Create Hub Network (East US)

```bash
# Create resource group in East US
az group create \
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia

# Create hub virtual network
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-hub-southeastasia \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-hub \
  --subnet-prefix 10.0.1.0/24

# Create AzureBastionSubnet (required name)
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-hub-southeastasia \
  --name AzureBastionSubnet \
  --address-prefix 10.0.100.0/26
```

### 2. Create Azure Bastion

```bash
# Create public IP for Bastion
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-bastion-hub \
  --sku Standard \
  --allocation-method Static

# Create Azure Bastion
az network bastion create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name bastion-hub \
  --public-ip-address pip-bastion-hub \
  --vnet-name vnet-hub-southeastasia \
  --location southeastasia \
  --sku Standard
```

### 3. Create Test VM in Hub

```bash
# Create VM in hub network
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-hub-southeastasia \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-hub-southeastasia \
  --subnet subnet-hub \
  --public-ip "" \
  --size Standard_B1s
```

---

## Cross-Region Spoke Networks

### 1. Create Spoke Network (West US)

```bash
# Create resource group in West US
az group create \
  --name rg-bastion-spoke-west \
  --location westus

# Create spoke virtual network in West US
az network vnet create \
  --resource-group rg-bastion-spoke-west \
  --name vnet-spoke-westus \
  --address-prefix 10.1.0.0/16 \
  --subnet-name subnet-spoke \
  --subnet-prefix 10.1.1.0/24

# Create VM in spoke network
az vm create \
  --resource-group rg-bastion-spoke-west \
  --name vm-spoke-westus \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-spoke-westus \
  --subnet subnet-spoke \
  --public-ip "" \
  --size Standard_B1s
```

### 2. Create Spoke Network (Central US)

```bash
# Create resource group in Central US
az group create \
  --name rg-bastion-spoke-central \
  --location centralus

# Create spoke virtual network in Central US
az network vnet create \
  --resource-group rg-bastion-spoke-central \
  --name vnet-spoke-centralus \
  --address-prefix 10.2.0.0/16 \
  --subnet-name subnet-spoke \
  --subnet-prefix 10.2.1.0/24

# Create VM in spoke network
az vm create \
  --resource-group rg-bastion-spoke-central \
  --name vm-spoke-centralus \
  --image Win2022Datacenter \
  --admin-username azureuser \
  --admin-password 'P@ssw0rd123!' \
  --vnet-name vnet-spoke-centralus \
  --subnet subnet-spoke \
  --public-ip "" \
  --size Standard_B2s
```

---

## VNet Peering Configuration

### 1. Hub-to-Spoke Peering

```bash
# Peer hub to west spoke
az network vnet peering create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name hub-to-west-spoke \
  --vnet-name vnet-hub-southeastasia \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Network/virtualNetworks/vnet-spoke-westus \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer west spoke to hub
az network vnet peering create \
  --resource-group rg-bastion-spoke-west \
  --name west-spoke-to-hub \
  --vnet-name vnet-spoke-westus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/virtualNetworks/vnet-hub-southeastasia \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --use-remote-gateways

# Peer hub to central spoke
az network vnet peering create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name hub-to-central-spoke \
  --vnet-name vnet-hub-southeastasia \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-central/providers/Microsoft.Network/virtualNetworks/vnet-spoke-centralus \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer central spoke to hub
az network vnet peering create \
  --resource-group rg-bastion-spoke-central \
  --name central-spoke-to-hub \
  --vnet-name vnet-spoke-centralus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/virtualNetworks/vnet-hub-southeastasia \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --use-remote-gateways
```

### 2. Verify Peering Status

```bash
# Check peering status
az network vnet peering list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-hub-southeastasia \
  --output table

az network vnet peering list \
  --resource-group rg-bastion-spoke-west \
  --vnet-name vnet-spoke-westus \
  --output table
```

---

## Transitive VNet Peering Setup

### 1. Create Additional Spoke (East US 2)

```bash
# Create resource group in East US 2
az group create \
  --name rg-bastion-spoke-east2 \
  --location southeastasia2

# Create spoke virtual network
az network vnet create \
  --resource-group rg-bastion-spoke-east2 \
  --name vnet-spoke-southeastasia2 \
  --address-prefix 10.3.0.0/16 \
  --subnet-name subnet-spoke \
  --subnet-prefix 10.3.1.0/24

# Create VM in spoke network
az vm create \
  --resource-group rg-bastion-spoke-east2 \
  --name vm-spoke-southeastasia2 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-spoke-southeastasia2 \
  --subnet subnet-spoke \
  --public-ip "" \
  --size Standard_B1s
```

### 2. Create Transitive Network

```bash
# Create transitive network (connected to East US 2 spoke)
az group create \
  --name rg-bastion-transitive \
  --location southeastasia2

az network vnet create \
  --resource-group rg-bastion-transitive \
  --name vnet-transitive \
  --address-prefix 10.4.0.0/16 \
  --subnet-name subnet-transitive \
  --subnet-prefix 10.4.1.0/24

# Create VM in transitive network
az vm create \
  --resource-group rg-bastion-transitive \
  --name vm-transitive \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-transitive \
  --subnet subnet-transitive \
  --public-ip "" \
  --size Standard_B1s
```

### 3. Configure Transitive Peering

```bash
# Peer East US 2 spoke to transitive network
az network vnet peering create \
  --resource-group rg-bastion-spoke-east2 \
  --name southeastasia2-to-transitive \
  --vnet-name vnet-spoke-southeastasia2 \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-transitive/providers/Microsoft.Network/virtualNetworks/vnet-transitive \
  --allow-vnet-access \
  --allow-forwarded-traffic

# Peer transitive network to East US 2 spoke
az network vnet peering create \
  --resource-group rg-bastion-transitive \
  --name transitive-to-southeastasia2 \
  --vnet-name vnet-transitive \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-east2/providers/Microsoft.Network/virtualNetworks/vnet-spoke-southeastasia2 \
  --allow-vnet-access \
  --allow-forwarded-traffic

# Peer hub to East US 2 spoke
az network vnet peering create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name hub-to-southeastasia2-spoke \
  --vnet-name vnet-hub-southeastasia \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-east2/providers/Microsoft.Network/virtualNetworks/vnet-spoke-southeastasia2 \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer East US 2 spoke to hub
az network vnet peering create \
  --resource-group rg-bastion-spoke-east2 \
  --name southeastasia2-spoke-to-hub \
  --vnet-name vnet-spoke-southeastasia2 \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/virtualNetworks/vnet-hub-southeastasia \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --use-remote-gateways
```

---

## Route Tables for Transitive Access

### 1. Create Route Table

```bash
# Create route table for transitive access
az network route-table create \
  --resource-group rg-bastion-spoke-east2 \
  --name rt-transitive-access \
  --location southeastasia2

# Add route to transitive network via East US 2 spoke
az network route-table route create \
  --resource-group rg-bastion-spoke-east2 \
  --route-table-name rt-transitive-access \
  --name route-to-transitive \
  --address-prefix 10.4.0.0/16 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 10.3.1.4

# Associate route table with hub subnet
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-hub-southeastasia \
  --name subnet-hub \
  --route-table /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-east2/providers/Microsoft.Network/routeTables/rt-transitive-access
```

### 2. Enable IP Forwarding

```bash
# Enable IP forwarding on East US 2 spoke VM (acting as router)
az network nic update \
  --resource-group rg-bastion-spoke-east2 \
  --name vm-spoke-southeastasia2VMNic \
  --ip-forwarding true

# Configure IP forwarding in the VM
az vm run-command invoke \
  --resource-group rg-bastion-spoke-east2 \
  --name vm-spoke-southeastasia2 \
  --command-id RunShellScript \
  --scripts "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
```

---

## Regional Bastion Deployment

### 1. Create Bastion in West US

```bash
# Create AzureBastionSubnet in West US spoke
az network vnet subnet create \
  --resource-group rg-bastion-spoke-west \
  --vnet-name vnet-spoke-westus \
  --name AzureBastionSubnet \
  --address-prefix 10.1.100.0/26

# Create public IP for West US Bastion
az network public-ip create \
  --resource-group rg-bastion-spoke-west \
  --name pip-bastion-west \
  --sku Standard \
  --allocation-method Static \
  --location westus

# Create Azure Bastion in West US
az network bastion create \
  --resource-group rg-bastion-spoke-west \
  --name bastion-west \
  --public-ip-address pip-bastion-west \
  --vnet-name vnet-spoke-westus \
  --location westus \
  --sku Standard
```

### 2. Create Bastion in Central US

```bash
# Create AzureBastionSubnet in Central US spoke
az network vnet subnet create \
  --resource-group rg-bastion-spoke-central \
  --vnet-name vnet-spoke-centralus \
  --name AzureBastionSubnet \
  --address-prefix 10.2.100.0/26

# Create public IP for Central US Bastion
az network public-ip create \
  --resource-group rg-bastion-spoke-central \
  --name pip-bastion-central \
  --sku Standard \
  --allocation-method Static \
  --location centralus

# Create Azure Bastion in Central US
az network bastion create \
  --resource-group rg-bastion-spoke-central \
  --name bastion-central \
  --public-ip-address pip-bastion-central \
  --vnet-name vnet-spoke-centralus \
  --location centralus \
  --sku Standard
```

---

## Testing Connectivity

### 1. Test Direct Connectivity

```bash
# Test connectivity from hub to spoke VMs
az network bastion ssh \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Compute/virtualMachines/vm-spoke-westus \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key

# Test RDP to Windows VM
az network bastion rdp \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-central/providers/Microsoft.Compute/virtualMachines/vm-spoke-centralus
```

### 2. Test Cross-Region Access

```bash
# Access West US VM from East US Bastion
az network bastion ssh \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Compute/virtualMachines/vm-spoke-westus \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key

# Access Central US VM from East US Bastion
az network bastion rdp \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-central/providers/Microsoft.Compute/virtualMachines/vm-spoke-centralus
```

### 3. Test Transitive Access

```bash
# Access transitive network VM through hub Bastion
az network bastion ssh \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-transitive/providers/Microsoft.Compute/virtualMachines/vm-transitive \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key
```

---

## Advanced Bastion Configuration

### 1. Native Client Support

```bash
# Update Bastion to support native client
az network bastion update \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --enable-tunneling true

# Connect using native SSH client
az network bastion tunnel \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Compute/virtualMachines/vm-spoke-westus \
  --resource-port 22 \
  --port 2222

# In another terminal, use native SSH
ssh azureuser@127.0.0.1 -p 2222 -i ~/.ssh/azure-key
```

### 2. File Transfer Support

```bash
# Enable file transfer (requires Standard SKU or higher)
az network bastion update \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --enable-file-copy true

# Upload file to VM
az network bastion ssh \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Compute/virtualMachines/vm-spoke-westus \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key \
  --enable-file-copy
```

### 3. IP-based Connection

```bash
# Enable IP-based connection
az network bastion update \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --enable-ip-connect true

# Connect using private IP
az network bastion ssh \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --target-ip-address 10.1.1.4 \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key
```

---

## Monitoring and Diagnostics

### 1. Bastion Diagnostics

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name bastion-analytics \
  --location southeastasia

# Enable diagnostic logs
az monitor diagnostic-settings create \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/bastionHosts/bastion-hub \
  --name bastion-diagnostics \
  --logs '[{"category":"BastionAuditLogs","enabled":true}]' \
  --workspace /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/bastion-analytics
```

### 2. Connection Monitoring

```bash
# Check Bastion status
az network bastion show \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "{Name:name, ProvisioningState:provisioningState, Sku:sku.name}"

# List active sessions (requires PowerShell or portal)
az network bastion show \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "ipConfigurations[0].privateIpAddress"
```

---

## Security Best Practices

### 1. Network Security Groups

```bash
# Create NSG for Bastion subnet
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-bastion-subnet \
  --location southeastasia

# Allow HTTPS inbound from Internet
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-bastion-subnet \
  --name allow-https-inbound \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow gateway manager inbound
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-bastion-subnet \
  --name allow-gateway-manager \
  --priority 110 \
  --source-address-prefixes GatewayManager \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow SSH/RDP outbound to VNet
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-bastion-subnet \
  --name allow-ssh-rdp-outbound \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-address-prefixes VirtualNetwork \
  --destination-port-ranges 22 3389 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp

# Associate NSG with Bastion subnet
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-hub-southeastasia \
  --name AzureBastionSubnet \
  --network-security-group nsg-bastion-subnet
```

### 2. Access Control

```bash
# Create custom role for Bastion access
az role definition create --role-definition '{
  "Name": "Bastion User",
  "Description": "Can connect to VMs through Azure Bastion",
  "Actions": [
    "Microsoft.Network/bastionHosts/read",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Network/bastionHosts/connect/action"
  ],
  "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'

# Assign role to user
az role assignment create \
  --assignee user@domain.com \
  --role "Bastion User" \
  --scope /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade
```

---

## Cost Optimization

### 1. Shared Bastion Strategy

```bash
# Use single Bastion for multiple regions (hub model)
# Calculate cost savings
echo "Hub Bastion Model:"
echo "- 1 Bastion instance: ~$140/month"
echo "- Cross-region data transfer: ~$0.02/GB"
echo ""
echo "Regional Bastion Model:"
echo "- 3 Bastion instances: ~$420/month"
echo "- No cross-region transfer costs"
```

### 2. Bastion Scaling

```bash
# Scale Bastion based on usage
az network bastion update \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --scale-units 2

# Monitor usage and adjust scale units
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/bastionHosts/bastion-hub \
  --metric "Sessions" \
  --interval PT1H
```

---

## Troubleshooting

### 1. Connectivity Issues

```bash
# Check VNet peering status
az network vnet peering show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-hub-southeastasia \
  --name hub-to-west-spoke \
  --query "{Name:name, PeeringState:peeringState, ProvisioningState:provisioningState}"

# Test network connectivity
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource bastion-hub \
  --dest-resource vm-spoke-westus \
  --dest-port 22

# Check effective routes
az network nic show-effective-route-table \
  --resource-group rg-bastion-spoke-west \
  --name vm-spoke-westusVMNic
```

### 2. Bastion Issues

```bash
# Check Bastion health
az network bastion show \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "{ProvisioningState:provisioningState, DnsName:dnsName}"

# Verify subnet configuration
az network vnet subnet show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-hub-southeastasia \
  --name AzureBastionSubnet \
  --query "{AddressPrefix:addressPrefix, ProvisioningState:provisioningState}"
```

---

## Cleanup

```bash
# Delete Bastion hosts
az network bastion delete \
  --name bastion-hub \
  --resource-group sa1_test_eic_SudarshanDarade

az network bastion delete \
  --name bastion-west \
  --resource-group rg-bastion-spoke-west

# Delete resource groups
az group delete --name sa1_test_eic_SudarshanDarade --yes --no-wait
az group delete --name rg-bastion-spoke-west --yes --no-wait
az group delete --name rg-bastion-spoke-central --yes --no-wait
az group delete --name rg-bastion-spoke-east2 --yes --no-wait
az group delete --name rg-bastion-transitive --yes --no-wait
```

---

## Summary

This guide covered:
- Creating Azure Bastion in hub-spoke architecture
- Cross-region VM access through VNet peering
- Transitive VNet peering with route tables
- Regional Bastion deployment strategies
- Advanced features: native client, file transfer, IP-based connections
- Security best practices and access control
- Cost optimization strategies
- Monitoring and troubleshooting

Azure Bastion provides secure, scalable remote access to VMs across regions and complex network topologies without requiring public IP addresses or VPN connections.
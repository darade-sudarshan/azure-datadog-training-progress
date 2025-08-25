# Azure Network Security Groups (NSG) and Application Security Groups (ASG)

This guide covers Azure Network Security Groups and Application Security Groups for implementing network security and micro-segmentation in Azure virtual networks.

## Understanding NSG and ASG

### Network Security Groups (NSG)
- **Definition**: Virtual firewall that controls inbound and outbound traffic to Azure resources
- **Scope**: Can be associated with subnets or network interfaces
- **Rules**: Allow or deny traffic based on source, destination, port, and protocol
- **Priority**: Rules processed in priority order (100-4096, lower numbers first)
- **Default Rules**: Built-in rules that cannot be deleted but can be overridden

### Application Security Groups (ASG)
- **Definition**: Logical grouping of virtual machines for network security policies
- **Purpose**: Simplify security rule management by grouping resources by function
- **Benefits**: Reduce rule complexity, improve maintainability, support micro-segmentation
- **Usage**: Reference ASGs in NSG rules instead of specific IP addresses

### NSG vs ASG Comparison

| Feature | NSG | ASG |
|---------|-----|-----|
| Purpose | Traffic filtering | Resource grouping |
| Scope | Subnet/NIC level | Logical grouping |
| Rules | Allow/Deny traffic | Referenced in NSG rules |
| Management | Rule-based | Group-based |
| Scalability | IP-based rules | Function-based groups |

### Default NSG Rules

| Priority | Name | Direction | Access | Protocol | Source | Destination | Port |
|----------|------|-----------|--------|----------|--------|-------------|------|
| 65000 | AllowVnetInBound | Inbound | Allow | * | VirtualNetwork | VirtualNetwork | * |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allow | * | AzureLoadBalancer | * | * |
| 65500 | DenyAllInBound | Inbound | Deny | * | * | * | * |
| 65000 | AllowVnetOutBound | Outbound | Allow | * | VirtualNetwork | VirtualNetwork | * |
| 65001 | AllowInternetOutBound | Outbound | Allow | * | * | Internet | * |
| 65500 | DenyAllOutBound | Outbound | Deny | * | * | * | * |

---

## Manual NSG and ASG Creation via Azure Portal

### Creating Network Security Groups via Portal

#### 1. Create Network Security Group
1. Navigate to **Network security groups**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `nsg-web-tier-portal`
   - **Region**: `Southeast Asia`
4. Click **Review + create** > **Create**

#### 2. Configure NSG Rules via Portal
1. Navigate to your created NSG
2. Go to **Settings** > **Inbound security rules**
3. Click **Add**
4. **Add inbound security rule**:
   - **Source**: `Any` or `IP Addresses`
   - **Source IP addresses/CIDR ranges**: `*` or specific IPs
   - **Source port ranges**: `*`
   - **Destination**: `Any` or `IP Addresses`
   - **Destination IP addresses/CIDR ranges**: `*`
   - **Service**: `Custom` or predefined (HTTP, HTTPS, SSH)
   - **Destination port ranges**: `80` (for HTTP)
   - **Protocol**: `TCP`
   - **Action**: `Allow`
   - **Priority**: `100`
   - **Name**: `allow-http`
   - **Description**: `Allow HTTP traffic`
5. Click **Add**

#### 3. Create Multiple Rules
1. **HTTPS Rule**:
   - **Service**: `HTTPS`
   - **Destination port ranges**: `443`
   - **Priority**: `110`
   - **Name**: `allow-https`

2. **SSH Rule**:
   - **Source**: `IP Addresses`
   - **Source IP addresses**: `203.0.113.0/24`
   - **Service**: `SSH`
   - **Destination port ranges**: `22`
   - **Priority**: `120`
   - **Name**: `allow-ssh-admin`

3. **Deny All Rule**:
   - **Source**: `Any`
   - **Destination**: `Any`
   - **Service**: `Custom`
   - **Destination port ranges**: `*`
   - **Protocol**: `Any`
   - **Action**: `Deny`
   - **Priority**: `4000`
   - **Name**: `deny-all-inbound`

#### 4. Configure Outbound Rules
1. Go to **Settings** > **Outbound security rules**
2. Click **Add**
3. **Allow HTTPS Outbound**:
   - **Source**: `Any`
   - **Destination**: `Service Tag`
   - **Destination service tag**: `Internet`
   - **Service**: `HTTPS`
   - **Priority**: `100`
   - **Name**: `allow-https-outbound`

### Creating Application Security Groups via Portal

#### 1. Create Application Security Group
1. Navigate to **Application security groups**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `asg-web-servers-portal`
   - **Region**: `Southeast Asia`
4. Click **Review + create** > **Create**

#### 2. Create Multiple ASGs
1. Repeat for different tiers:
   - `asg-app-servers-portal`
   - `asg-db-servers-portal`
   - `asg-management-portal`

#### 3. Create NSG with ASG Rules
1. Create new NSG: `nsg-with-asg-portal`
2. **Add inbound rule with ASG**:
   - **Source**: `Application security group`
   - **Source application security groups**: Select `asg-web-servers-portal`
   - **Destination**: `Application security group`
   - **Destination application security groups**: Select `asg-app-servers-portal`
   - **Service**: `Custom`
   - **Destination port ranges**: `8080`
   - **Priority**: `100`
   - **Name**: `allow-web-to-app`

### Associating NSGs and ASGs via Portal

#### 1. Associate NSG with Subnet
1. Navigate to **Virtual networks**
2. Select your VNet
3. Go to **Settings** > **Subnets**
4. Click on subnet name
5. **Network security group**: Select your NSG
6. Click **Save**

#### 2. Associate NSG with Network Interface
1. Navigate to **Network interfaces**
2. Select VM's network interface
3. Go to **Settings** > **Network security group**
4. **Network security group**: Select NSG
5. Click **Save**

#### 3. Associate VM with ASG
1. Navigate to **Virtual machines**
2. Select your VM
3. Go to **Networking** > **Application security groups**
4. Click **Configure the application security groups**
5. **Application security groups**: Select ASGs
6. Click **Save**

### Advanced NSG Configuration via Portal

#### 1. Service Tags Configuration
1. **Add inbound rule**:
   - **Source**: `Service Tag`
   - **Source service tag**: `AzureLoadBalancer`
   - **Destination**: `Any`
   - **Service**: `Custom`
   - **Destination port ranges**: `*`
   - **Action**: `Allow`
   - **Priority**: `100`
   - **Name**: `allow-azure-lb`

2. **Regional Service Tags**:
   - **Source service tag**: `Storage.SoutheastAsia`
   - **Destination port ranges**: `443`
   - **Name**: `allow-storage-regional`

#### 2. Multiple Sources/Destinations
1. **Add rule with multiple IPs**:
   - **Source**: `IP Addresses`
   - **Source IP addresses**: `10.0.1.0/24,10.0.2.0/24,192.168.1.0/24`
   - **Destination**: `Application security group`
   - **Destination ASGs**: Select multiple ASGs
   - **Destination port ranges**: `80,443,8080`

### Flow Logs Configuration via Portal

#### 1. Enable NSG Flow Logs
1. Navigate to **Network Watcher**
2. Go to **Logs** > **NSG flow logs**
3. Click **Create**
4. **Flow log settings**:
   - **Target resource**: Select your NSG
   - **Storage account**: Select or create storage account
   - **Retention (days)**: `30`
   - **Flow log version**: `Version 2`
   - **Enable traffic analytics**: `Yes` (optional)
   - **Traffic analytics processing interval**: `10 minutes`
   - **Log Analytics workspace**: Select workspace
5. Click **Create**

#### 2. View Flow Logs
1. Navigate to **Storage accounts**
2. Select flow logs storage account
3. Go to **Data storage** > **Containers**
4. Navigate to: `insights-logs-networksecuritygroupflowevent`
5. Download and analyze log files

### Monitoring and Diagnostics via Portal

#### 1. NSG Diagnostics
1. Navigate to your NSG
2. Go to **Monitoring** > **Diagnostic settings**
3. Click **Add diagnostic setting**
4. **Diagnostic setting name**: `nsg-diagnostics`
5. **Logs**: Select categories:
   - `NetworkSecurityGroupEvent`
   - `NetworkSecurityGroupRuleCounter`
6. **Destination details**: Log Analytics workspace
7. Click **Save**

#### 2. View NSG Metrics
1. Go to **Monitoring** > **Metrics**
2. **Metric**: Select available metrics
3. **Time range**: Configure period
4. **Chart type**: Line, bar, etc.

#### 3. Effective Security Rules
1. Navigate to **Virtual machines**
2. Select VM
3. Go to **Networking** > **Effective security rules**
4. View combined rules from subnet and NIC NSGs
5. **Download**: Export rules to CSV

### Security Testing via Portal

#### 1. Connection Troubleshoot
1. Navigate to **Network Watcher**
2. Go to **Network diagnostic tools** > **Connection troubleshoot**
3. **Source**: Select source VM
4. **Destination**: Select destination VM or IP
5. **Destination port**: Specify port
6. Click **Check**
7. Review connectivity results and NSG evaluation

#### 2. IP Flow Verify
1. Go to **Network diagnostic tools** > **IP flow verify**
2. **Virtual machine**: Select VM
3. **Network interface**: Select NIC
4. **Direction**: `Inbound` or `Outbound`
5. **Protocol**: `TCP` or `UDP`
6. **Local IP address**: VM IP
7. **Local port**: Destination port
8. **Remote IP address**: Source IP
9. **Remote port**: Source port
10. Click **Check**

#### 3. Next Hop
1. Go to **Network diagnostic tools** > **Next hop**
2. **Virtual machine**: Select VM
3. **Source IP address**: VM IP
4. **Destination IP address**: Target IP
5. Click **Check**
6. Review routing information

### Use Case Templates via Portal

#### 1. Three-Tier Application Template
1. **Create NSG**: `nsg-3tier-template`
2. **Web Tier Rules**:
   - Allow HTTP/HTTPS from Internet (Priority 100-110)
   - Allow SSH from management subnet (Priority 120)
   - Deny all other inbound (Priority 4000)

3. **App Tier Rules**:
   - Allow 8080 from web tier only (Priority 100)
   - Allow SSH from management (Priority 110)
   - Deny all other inbound (Priority 4000)

4. **DB Tier Rules**:
   - Allow 3306/5432 from app tier only (Priority 100)
   - Allow SSH from management (Priority 110)
   - Deny all other inbound (Priority 4000)

#### 2. Microservices Template
1. **Create ASGs**:
   - `asg-frontend`, `asg-auth`, `asg-payment`, `asg-order`
2. **Create NSG**: `nsg-microservices`
3. **Rules**:
   - Internet → Frontend (80,443)
   - Frontend → Auth (8080)
   - Frontend → Order (8081)
   - Order → Payment (8082)
   - Management → All services (22,3389)

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create Network Security Group
New-AzNetworkSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "nsg-portal-ps"

# Create NSG rules
$rule1 = New-AzNetworkSecurityRuleConfig -Name "allow-http" -Description "Allow HTTP" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "80"

$rule2 = New-AzNetworkSecurityRuleConfig -Name "allow-https" -Description "Allow HTTPS" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 110 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443"

$rule3 = New-AzNetworkSecurityRuleConfig -Name "allow-ssh" -Description "Allow SSH" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 120 -SourceAddressPrefix "203.0.113.0/24" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "22"

# Create NSG with rules
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "nsg-with-rules-ps" -SecurityRules $rule1,$rule2,$rule3

# Create Application Security Groups
New-AzApplicationSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "asg-web-ps" -Location "Southeast Asia"
New-AzApplicationSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "asg-app-ps" -Location "Southeast Asia"

# Get ASGs for rule creation
$asgWeb = Get-AzApplicationSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "asg-web-ps"
$asgApp = Get-AzApplicationSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "asg-app-ps"

# Create NSG rule with ASGs
$asgRule = New-AzNetworkSecurityRuleConfig -Name "allow-web-to-app" -Description "Allow web to app" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceApplicationSecurityGroup $asgWeb -SourcePortRange "*" -DestinationApplicationSecurityGroup $asgApp -DestinationPortRange "8080"

# Create NSG with ASG rules
New-AzNetworkSecurityGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -Name "nsg-asg-ps" -SecurityRules $asgRule

# Associate NSG with subnet
$vnet = Get-AzVirtualNetwork -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "vnet-security-demo"
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "subnet-web"
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "subnet-web" -AddressPrefix $subnet.AddressPrefix -NetworkSecurityGroup $nsg
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Associate VM NIC with ASG
$nic = Get-AzNetworkInterface -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "vm-web-01VMNic"
$nic.IpConfigurations[0].ApplicationSecurityGroups = $asgWeb
Set-AzNetworkInterface -NetworkInterface $nic
```

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Virtual network and subnets created
- Virtual machines for testing (optional)

---

## Creating Network Security Groups

### 1. Create Resource Group and VNet

```bash
# Create resource group
az group create \
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia

# Create virtual network
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-security-demo \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Create additional subnets
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-app \
  --address-prefix 10.0.2.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-db \
  --address-prefix 10.0.3.0/24
```

### 2. Create Basic NSG

```bash
# Create NSG for web tier
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-web-tier \
  --location southeastasia

# Create NSG for app tier
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-app-tier \
  --location southeastasia

# Create NSG for database tier
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-db-tier \
  --location southeastasia
```

### 3. Create NSG Rules

```bash
# Web tier rules - Allow HTTP, HTTPS, SSH
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web-tier \
  --name allow-http \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web-tier \
  --name allow-https \
  --priority 110 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web-tier \
  --name allow-ssh \
  --priority 120 \
  --source-address-prefixes '203.0.113.0/24' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# App tier rules - Allow traffic from web tier only
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-app-tier \
  --name allow-web-to-app \
  --priority 100 \
  --source-address-prefixes '10.0.1.0/24' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 8080 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-app-tier \
  --name allow-ssh-from-web \
  --priority 110 \
  --source-address-prefixes '10.0.1.0/24' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Database tier rules - Allow traffic from app tier only
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-db-tier \
  --name allow-app-to-db \
  --priority 100 \
  --source-address-prefixes '10.0.2.0/24' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 3306 5432 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-db-tier \
  --name allow-ssh-from-app \
  --priority 110 \
  --source-address-prefixes '10.0.2.0/24' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

---

## Creating Application Security Groups

### 1. Create ASGs

```bash
# Create ASGs for different application tiers
az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-web-servers \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-app-servers \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-db-servers \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-management \
  --location southeastasia
```

### 2. Create NSG with ASG Rules

```bash
# Create NSG that uses ASGs
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-with-asg \
  --location southeastasia

# Allow HTTP/HTTPS to web servers
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-with-asg \
  --name allow-web-traffic \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-asgs asg-web-servers \
  --destination-port-ranges 80 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow web servers to communicate with app servers
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-with-asg \
  --name allow-web-to-app \
  --priority 110 \
  --source-asgs asg-web-servers \
  --destination-asgs asg-app-servers \
  --destination-port-ranges 8080 8443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow app servers to communicate with database servers
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-with-asg \
  --name allow-app-to-db \
  --priority 120 \
  --source-asgs asg-app-servers \
  --destination-asgs asg-db-servers \
  --destination-port-ranges 3306 5432 1433 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow management access to all servers
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-with-asg \
  --name allow-management-ssh \
  --priority 130 \
  --source-asgs asg-management \
  --destination-asgs asg-web-servers asg-app-servers asg-db-servers \
  --destination-port-ranges 22 3389 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

---

## Associating NSGs and ASGs

### 1. Associate NSG with Subnets

```bash
# Associate NSGs with subnets
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --network-security-group nsg-web-tier

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-app \
  --network-security-group nsg-app-tier

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-db \
  --network-security-group nsg-db-tier
```

### 2. Create VMs and Associate with ASGs

```bash
# Create web server VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-web-01 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-security-demo \
  --subnet subnet-web \
  --nsg "" \
  --size Standard_B1s

# Associate web server with ASG
az network nic ip-config update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nic-name vm-web-01VMNic \
  --name ipconfigvm-web-01 \
  --application-security-groups asg-web-servers

# Create app server VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-app-01 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-security-demo \
  --subnet subnet-app \
  --nsg "" \
  --size Standard_B1s

# Associate app server with ASG
az network nic ip-config update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nic-name vm-app-01VMNic \
  --name ipconfigvm-app-01 \
  --application-security-groups asg-app-servers

# Create database server VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-db-01 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-security-demo \
  --subnet subnet-db \
  --nsg "" \
  --size Standard_B1s

# Associate database server with ASG
az network nic ip-config update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nic-name vm-db-01VMNic \
  --name ipconfigvm-db-01 \
  --application-security-groups asg-db-servers
```

---

## Advanced NSG Scenarios

### 1. Service Tags in NSG Rules

```bash
# Create NSG with service tags
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-service-tags \
  --location southeastasia

# Allow Azure Load Balancer
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-service-tags \
  --name allow-azure-lb \
  --priority 100 \
  --source-address-prefixes AzureLoadBalancer \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --direction Inbound \
  --access Allow \
  --protocol '*'

# Allow Azure Storage access
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-service-tags \
  --name allow-storage-outbound \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-address-prefixes Storage \
  --destination-port-ranges 443 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp

# Allow SQL Database access
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-service-tags \
  --name allow-sql-outbound \
  --priority 110 \
  --source-address-prefixes '*' \
  --destination-address-prefixes Sql \
  --destination-port-ranges 1433 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp
```

### 2. Regional Service Tags

```bash
# Allow access to specific regional services
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-service-tags \
  --name allow-storage-southeastasia \
  --priority 120 \
  --source-address-prefixes '*' \
  --destination-address-prefixes Storage.southeastasia \
  --destination-port-ranges 443 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp
```

### 3. Augmented Security Rules

```bash
# Create rule with multiple sources and destinations
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-with-asg \
  --name allow-multiple-sources \
  --priority 200 \
  --source-address-prefixes '10.0.1.0/24' '10.0.2.0/24' \
  --source-asgs asg-management \
  --destination-asgs asg-web-servers asg-app-servers \
  --destination-port-ranges 80 443 8080 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

---

## Use Case Implementations

### 1. Three-Tier Web Application

```bash
# Create comprehensive 3-tier security setup
# Web tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-3tier-web \
  --location southeastasia

# Allow internet traffic to web tier
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-3tier-web \
  --name allow-internet-web \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow management access
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-3tier-web \
  --name allow-management \
  --priority 110 \
  --source-address-prefixes '203.0.113.0/24' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 3389 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Deny all other inbound traffic
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-3tier-web \
  --name deny-all-inbound \
  --priority 4000 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --direction Inbound \
  --access Deny \
  --protocol '*'
```

### 2. DMZ Configuration

```bash
# Create DMZ NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-dmz \
  --location southeastasia

# Allow specific external services
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-dmz \
  --name allow-external-web \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow DMZ to internal network
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-dmz \
  --name allow-dmz-to-internal \
  --priority 100 \
  --source-address-prefixes '10.0.10.0/24' \
  --destination-address-prefixes '10.0.0.0/16' \
  --destination-port-ranges 80 443 8080 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp

# Block DMZ from accessing internet directly
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-dmz \
  --name deny-dmz-internet \
  --priority 4000 \
  --source-address-prefixes '*' \
  --destination-address-prefixes Internet \
  --destination-port-ranges '*' \
  --direction Outbound \
  --access Deny \
  --protocol '*'
```

### 3. Development Environment Security

```bash
# Create development environment ASGs
az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-dev-web \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-dev-api \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-dev-db \
  --location southeastasia

# Create development NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-development \
  --location southeastasia

# Allow developers access to all dev resources
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-development \
  --name allow-dev-access \
  --priority 100 \
  --source-address-prefixes '192.168.1.0/24' \
  --destination-asgs asg-dev-web asg-dev-api asg-dev-db \
  --destination-port-ranges 22 3389 80 443 8080 3306 5432 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow inter-service communication
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-development \
  --name allow-inter-service \
  --priority 110 \
  --source-asgs asg-dev-web asg-dev-api \
  --destination-asgs asg-dev-api asg-dev-db \
  --destination-port-ranges '*' \
  --direction Inbound \
  --access Allow \
  --protocol '*'
```

### 4. Microservices Security

```bash
# Create microservices ASGs
az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-frontend-service \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-auth-service \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-payment-service \
  --location southeastasia

az network asg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-order-service \
  --location southeastasia

# Create microservices NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-microservices \
  --location southeastasia

# Allow external access to frontend only
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-microservices \
  --name allow-frontend-external \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-asgs asg-frontend-service \
  --destination-port-ranges 80 443 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow frontend to auth service
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-microservices \
  --name allow-frontend-to-auth \
  --priority 110 \
  --source-asgs asg-frontend-service \
  --destination-asgs asg-auth-service \
  --destination-port-ranges 8080 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow frontend to order service
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-microservices \
  --name allow-frontend-to-order \
  --priority 120 \
  --source-asgs asg-frontend-service \
  --destination-asgs asg-order-service \
  --destination-port-ranges 8081 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow order service to payment service
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-microservices \
  --name allow-order-to-payment \
  --priority 130 \
  --source-asgs asg-order-service \
  --destination-asgs asg-payment-service \
  --destination-port-ranges 8082 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

---

## Monitoring and Logging

### 1. Enable NSG Flow Logs

```bash
# Create storage account for flow logs
az storage account create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name stflowlogs$(date +%s) \
  --sku Standard_LRS \
  --location southeastasia

# Enable NSG flow logs
az network watcher flow-log create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-web \
  --nsg nsg-web-tier \
  --storage-account stflowlogs* \
  --enabled true \
  --retention 30 \
  --format JSON \
  --log-version 2
```

### 2. NSG Diagnostics

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name nsg-analytics \
  --location southeastasia

# Enable NSG diagnostic logs
az monitor diagnostic-settings create \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/networkSecurityGroups/nsg-web-tier \
  --name nsg-diagnostics \
  --logs '[{"category":"NetworkSecurityGroupEvent","enabled":true},{"category":"NetworkSecurityGroupRuleCounter","enabled":true}]' \
  --workspace /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/nsg-analytics
```

---

## Management and Operations

### 1. View NSG Information

```bash
# List all NSGs
az network nsg list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Show NSG details
az network nsg show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-web-tier \
  --query "{Name:name, Rules:securityRules[].{Name:name, Priority:priority, Access:access, Direction:direction}}"

# List NSG rules
az network nsg rule list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web-tier \
  --output table

# Show effective security rules for a NIC
az network nic list-effective-nsg \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-web-01VMNic
```

### 2. View ASG Information

```bash
# List all ASGs
az network asg list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Show ASG details
az network asg show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-web-servers

# List NICs associated with ASG
az network asg show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-web-servers \
  --query "ipConfigurations[].id"
```

### 3. Update NSG Rules

```bash
# Update existing rule
az network nsg rule update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web-tier \
  --name allow-http \
  --source-address-prefixes '203.0.113.0/24' '198.51.100.0/24'

# Delete NSG rule
az network nsg rule delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web-tier \
  --name allow-ssh
```

---

## Security Best Practices

### 1. Principle of Least Privilege

```bash
# Create restrictive NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-restrictive \
  --location southeastasia

# Allow only specific required ports
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-restrictive \
  --name allow-specific-app \
  --priority 100 \
  --source-address-prefixes '10.0.1.0/24' \
  --destination-address-prefixes '10.0.2.0/24' \
  --destination-port-ranges 8080 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Explicitly deny all other traffic
az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-restrictive \
  --name deny-all-other \
  --priority 4000 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --direction Inbound \
  --access Deny \
  --protocol '*'
```

### 2. Defense in Depth

```bash
# Create layered security with both subnet and NIC level NSGs
# Subnet level NSG (coarse-grained)
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-subnet-defense \
  --location southeastasia

# NIC level NSG (fine-grained)
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-nic-defense \
  --location southeastasia

# Associate subnet NSG
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --network-security-group nsg-subnet-defense

# Associate NIC NSG
az network nic update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-web-01VMNic \
  --network-security-group nsg-nic-defense
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check NSG associations
az network vnet subnet show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --query "networkSecurityGroup.id"

# Verify effective routes
az network nic show-effective-route-table \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-web-01VMNic

# Check connectivity
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource vm-web-01 \
  --dest-resource vm-app-01 \
  --dest-port 8080
```

### 2. Diagnostic Commands

```bash
# Verify NSG rule evaluation
az network watcher test-ip-flow \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web-01 \
  --direction Inbound \
  --protocol TCP \
  --local 10.0.1.4:80 \
  --remote 203.0.113.10:12345

# Check next hop
az network watcher show-next-hop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web-01 \
  --source-ip 10.0.1.4 \
  --dest-ip 10.0.2.4
```

---

## Cleanup

```bash
# Remove NSG associations
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --remove networkSecurityGroup

# Delete NSGs
az network nsg delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-web-tier

# Delete ASGs
az network asg delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name asg-web-servers

# Delete resource group
az group delete \
  --name sa1_test_eic_SudarshanDarade \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Understanding NSGs and ASGs for network security
- Creating and configuring NSG rules with priorities and service tags
- Implementing ASGs for logical resource grouping
- Advanced scenarios: 3-tier applications, DMZ, microservices
- Monitoring with flow logs and diagnostics
- Security best practices and troubleshooting
- Management operations and rule updates

NSGs and ASGs provide powerful network security capabilities for implementing micro-segmentation, defense in depth, and simplified security management in Azure virtual networks.
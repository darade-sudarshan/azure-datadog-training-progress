# Task 22: Azure DNS - Local vs Public vs Private DNS

---

## Method 1: Using Azure Portal (GUI)

### Step 1: Create Resource Group

1. **Navigate to Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with your Azure account

2. **Create Resource Group**
   - Click "Resource groups" in the left menu
   - Click "+ Create"
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Region**: `Southeast Asia`
   - Click "Review + create" → "Create"

### Step 2: Create Public DNS Zone

1. **Navigate to DNS Zones**
   - Search "DNS zones" in the top search bar
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `contoso.com`
   - **Resource group location**: `Southeast Asia`

3. **Review and Create**
   - Click "Review + create" → "Create"
   - Wait for deployment to complete

4. **Get Name Servers**
   - Go to the created DNS zone `contoso.com`
   - Click "Overview"
   - Copy the **Name servers** (you'll need these for domain registration)

### Step 3: Add Public DNS Records

1. **Navigate to DNS Zone**
   - Go to the created DNS zone `contoso.com`
   - Click "+ Record set"

2. **Create A Record**
   - **Name**: `www`
   - **Type**: `A`
   - **TTL**: `3600`
   - **TTL unit**: `Seconds`
   - **IP address**: `20.1.1.1`
   - Click "OK"

3. **Create CNAME Record**
   - Click "+ Record set"
   - **Name**: `api`
   - **Type**: `CNAME`
   - **TTL**: `3600`
   - **Alias**: `www.contoso.com`
   - Click "OK"

4. **Create MX Record**
   - Click "+ Record set"
   - **Name**: `@` (root domain)
   - **Type**: `MX`
   - **TTL**: `3600`
   - **Preference**: `10`
   - **Mail exchange**: `mail.contoso.com`
   - Click "OK"

5. **Create TXT Record (Optional)**
   - Click "+ Record set"
   - **Name**: `@`
   - **Type**: `TXT`
   - **TTL**: `3600`
   - **Value**: `"v=spf1 include:_spf.google.com ~all"`
   - Click "OK"

### Step 4: Create Virtual Network for Private DNS

1. **Navigate to Virtual Networks**
   - Search "Virtual networks"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `vnet-private`
   - **Region**: `Southeast Asia`

3. **IP Addresses Tab**
   - **IPv4 address space**: `10.0.0.0/16`
   - Click "+ Add subnet"
   - **Subnet name**: `subnet-web`
   - **Subnet address range**: `10.0.1.0/24`
   - Click "Add"

4. **Review and Create**
   - Click "Review + create" → "Create"

### Step 5: Create Private DNS Zone

1. **Navigate to Private DNS Zones**
   - Search "Private DNS zones"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `internal.contoso.com`
   - **Resource group location**: `Southeast Asia`

3. **Review and Create**
   - Click "Review + create" → "Create"

### Step 6: Link Private DNS Zone to Virtual Network

1. **Navigate to Private DNS Zone**
   - Go to the created private DNS zone `internal.contoso.com`
   - Click "Virtual network links" in the left menu
   - Click "+ Add"

2. **Add Virtual Network Link**
   - **Link name**: `link-vnet-private`
   - **Subscription**: Select your subscription
   - **Virtual network**: `vnet-private`
   - **Enable auto registration**: `Yes`
   - Click "OK"

### Step 7: Add Private DNS Records

1. **Navigate to Private DNS Zone**
   - Go to `internal.contoso.com`
   - Click "+ Record set"

2. **Create Database A Record**
   - **Name**: `db`
   - **Type**: `A`
   - **TTL**: `3600`
   - **IP address**: `10.0.1.10`
   - Click "OK"

3. **Create API A Record**
   - Click "+ Record set"
   - **Name**: `api`
   - **Type**: `A`
   - **TTL**: `3600`
   - **IP address**: `10.0.1.20`
   - Click "OK"

4. **Create File Server A Record**
   - Click "+ Record set"
   - **Name**: `files`
   - **Type**: `A`
   - **TTL**: `3600`
   - **IP address**: `10.0.1.30`
   - Click "OK"

### Step 8: Create Test Virtual Machine

1. **Navigate to Virtual Machines**
   - Search "Virtual machines"
   - Click "+ Create" → "Azure virtual machine"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Virtual machine name**: `vm-dns-test`
   - **Region**: `Southeast Asia`
   - **Image**: `Ubuntu Server 22.04 LTS`
   - **Size**: `Standard_B1s`
   - **Authentication type**: `SSH public key`
   - **Username**: `azureuser`
   - **SSH public key source**: `Generate new key pair`
   - **Key pair name**: `vm-dns-test-key`

3. **Networking Tab**
   - **Virtual network**: `vnet-private`
   - **Subnet**: `subnet-web`
   - **Public IP**: `Create new`
   - **NIC network security group**: `Basic`
   - **Public inbound ports**: `Allow selected ports`
   - **Select inbound ports**: `SSH (22)`

4. **Review and Create**
   - Click "Review + create" → "Create"
   - Download the SSH key

### Step 9: Test DNS Resolution

1. **Connect to Test VM**
   - Go to the created VM `vm-dns-test`
   - Click "Connect" → "SSH"
   - Use the downloaded SSH key to connect

2. **Test Private DNS Resolution**
   ```bash
   # Test private DNS records
   nslookup db.internal.contoso.com
   nslookup api.internal.contoso.com
   nslookup files.internal.contoso.com
   
   # Test with dig
   dig db.internal.contoso.com
   dig api.internal.contoso.com
   ```

3. **Test Public DNS Resolution**
   ```bash
   # Test public DNS records
   nslookup www.contoso.com
   nslookup api.contoso.com
   
   # Test from external DNS
   nslookup www.contoso.com 8.8.8.8
   ```

### Step 10: Monitor and Manage DNS

1. **View DNS Analytics**
   - Go to Public DNS zone `contoso.com`
   - Click "Metrics" in the left menu
   - Add metrics like:
     - Query Volume
     - Record Set Count
     - Query Volume by Record Type

2. **Check Private DNS Links**
   - Go to Private DNS zone `internal.contoso.com`
   - Click "Virtual network links"
   - Verify the link status is "Completed"
   - Check auto-registration status

3. **View DNS Records**
   - In both DNS zones, click "Overview"
   - Review all created records
   - Check TTL values and record types

### Step 11: Advanced DNS Configuration

#### Create DNS Forwarder (Optional)

1. **Create DNS Forwarder VM**
   - Create another VM in the same VNet
   - Install BIND or similar DNS software
   - Configure conditional forwarding rules

2. **Configure Custom DNS in VNet**
   - Go to Virtual Network `vnet-private`
   - Click "DNS servers" in the left menu
   - Select "Custom"
   - Add the DNS forwarder VM IP
   - Click "Save"

#### Set Up Traffic Manager (Optional)

1. **Navigate to Traffic Manager Profiles**
   - Search "Traffic Manager profiles"
   - Click "+ Create"
   - Configure for DNS-based load balancing

2. **Add Endpoints**
   - Add multiple endpoints for failover
   - Configure health checks
   - Set routing method (Performance, Weighted, etc.)

### Step 12: Verification and Testing

1. **Verify Public DNS Propagation**
   - Use online DNS propagation checkers
   - Test from different global locations
   - Verify all record types resolve correctly

2. **Test Private DNS from Multiple VMs**
   - Create additional VMs in the same VNet
   - Test DNS resolution from each VM
   - Verify auto-registration works

3. **Monitor DNS Query Logs**
   - Enable diagnostic settings
   - Send logs to Log Analytics workspace
   - Create custom queries for DNS analysis

---

## Method 2: Using Azure CLI

## DNS Types Overview

### 1. Local DNS (On-Premises)
- **Location**: On-premises infrastructure
- **Scope**: Internal network only
- **Use Case**: Corporate internal resources
- **Example**: company.local, internal.corp

### 2. Public DNS (Azure DNS)
- **Location**: Azure cloud
- **Scope**: Internet-accessible
- **Use Case**: Public websites, services
- **Example**: contoso.com, api.contoso.com

### 3. Private DNS (Azure Private DNS)
- **Location**: Azure cloud
- **Scope**: Azure VNet only
- **Use Case**: Internal Azure resources
- **Example**: internal.contoso.com, db.private

## Public DNS Zone Implementation

### Create Public DNS Zone
```bash
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia

# Create public DNS zone
az network dns zone create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name contoso.com

# Get name servers
az network dns zone show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name contoso.com \
  --query nameServers
```

### Add DNS Records
```bash
# A Record
az network dns record-set a add-record \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name contoso.com \
  --record-set-name www \
  --ipv4-address 20.1.1.1

# CNAME Record
az network dns record-set cname set-record \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name contoso.com \
  --record-set-name api \
  --cname www.contoso.com

# MX Record
az network dns record-set mx add-record \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name contoso.com \
  --record-set-name @ \
  --exchange mail.contoso.com \
  --preference 10
```

## Private DNS Zone Implementation

### Create Private DNS Zone
```bash
# Create VNet
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-private \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Create private DNS zone
az network private-dns zone create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name internal.contoso.com

# Link to VNet
az network private-dns link vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name internal.contoso.com \
  --name link-vnet-private \
  --virtual-network vnet-private \
  --registration-enabled true
```

### Add Private DNS Records
```bash
# A Record for internal service
az network private-dns record-set a add-record \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name internal.contoso.com \
  --record-set-name db \
  --ipv4-address 10.0.1.10

# A Record for API
az network private-dns record-set a add-record \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name internal.contoso.com \
  --record-set-name api \
  --ipv4-address 10.0.1.20
```

## DNS Comparison Table

| Feature | Local DNS | Public DNS | Private DNS |
|---------|-----------|------------|-------------|
| **Accessibility** | Internal only | Internet | VNet only |
| **Management** | On-premises | Azure portal/CLI | Azure portal/CLI |
| **Cost** | Infrastructure cost | Pay per zone/query | Pay per zone/query |
| **Scalability** | Limited | High | High |
| **Integration** | AD/DHCP | Global DNS | Azure services |
| **Security** | Network isolation | Public exposure | VNet isolation |

## Use Case Examples

### Public DNS - Web Application
```bash
# Frontend
www.contoso.com → 20.1.1.1 (Load Balancer)

# API Gateway
api.contoso.com → 20.1.1.2 (App Gateway)

# CDN
cdn.contoso.com → CNAME to Azure CDN
```

### Private DNS - Internal Services
```bash
# Database
db.internal.contoso.com → 10.0.2.10

# Internal API
api.internal.contoso.com → 10.0.2.20

# File Server
files.internal.contoso.com → 10.0.2.30
```

### Local DNS - Corporate Network
```bash
# Domain Controller
dc01.company.local → 192.168.1.10

# File Server
fileserver.company.local → 192.168.1.20

# Print Server
print.company.local → 192.168.1.30
```

## DNS Resolution Flow

### Public DNS Resolution
```
Client → ISP DNS → Root DNS → TLD DNS → Azure DNS → IP Address
```

### Private DNS Resolution
```
Azure VM → Azure DNS → Private DNS Zone → Internal IP
```

### Hybrid DNS Resolution
```bash
# Create DNS forwarder VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-dns-forwarder \
  --image Ubuntu2204 \
  --vnet-name vnet-private \
  --subnet subnet-web \
  --admin-username azureuser \
  --generate-ssh-keys

# Configure conditional forwarding
# company.local → On-premises DNS (192.168.1.10)
# contoso.com → Azure Public DNS
# internal.contoso.com → Azure Private DNS
```

## Testing DNS Resolution

### Test Public DNS
```bash
# From internet
nslookup www.contoso.com
dig www.contoso.com

# Check propagation
nslookup www.contoso.com 8.8.8.8
```

### Test Private DNS
```bash
# From Azure VM
nslookup db.internal.contoso.com
dig api.internal.contoso.com

# Check VNet link
az network private-dns link vnet list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name internal.contoso.com
```

## Best Practices

### Public DNS
- Use CNAME for aliases
- Set appropriate TTL values
- Monitor DNS queries
- Use traffic manager for failover

### Private DNS
- Link to required VNets only
- Use descriptive naming
- Enable auto-registration
- Plan for cross-VNet resolution

### Hybrid Scenarios
- Use conditional forwarding
- Implement DNS forwarders
- Plan namespace overlap
- Test resolution paths

## Verification Commands
```bash
# List public DNS zones
az network dns zone list --resource-group sa1_test_eic_SudarshanDarade

# List private DNS zones
az network private-dns zone list --resource-group sa1_test_eic_SudarshanDarade

# Check DNS records
az network dns record-set list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name contoso.com

az network private-dns record-set a list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name internal.contoso.com
```

## DNS Architecture Summary
- **Public DNS**: Internet-facing services and websites
- **Private DNS**: Internal Azure resources and services  
- **Local DNS**: On-premises corporate resources
- **Hybrid**: Combination using conditional forwarding
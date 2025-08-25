# Task 19: 3-Tier VNet with VMSS and Standard Load Balancer

## Architecture Overview
3-tier VNet hosting 2 VMSS each in private subnets with Standard Load Balancer, NAT rules, outbound rules, multiple backend pools and public frontend addresses.

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

### Step 2: Create Virtual Network with Subnets

1. **Navigate to Virtual Networks**
   - Search "Virtual networks" in the top search bar
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `vnet-3tier`
   - **Region**: `Southeast Asia`

3. **IP Addresses Tab**
   - **IPv4 address space**: `10.0.0.0/16`
   - Click "+ Add subnet" for each tier:
   
   **Web Tier Subnets:**
   - **Subnet name**: `subnet-web-1`, **Address range**: `10.0.1.0/24`
   - **Subnet name**: `subnet-web-2`, **Address range**: `10.0.2.0/24`
   
   **App Tier Subnets:**
   - **Subnet name**: `subnet-app-1`, **Address range**: `10.0.3.0/24`
   - **Subnet name**: `subnet-app-2`, **Address range**: `10.0.4.0/24`
   
   **DB Tier Subnets:**
   - **Subnet name**: `subnet-db-1`, **Address range**: `10.0.5.0/24`
   - **Subnet name**: `subnet-db-2`, **Address range**: `10.0.6.0/24`

4. **Review and Create**
   - Click "Review + create" → "Create"

### Step 3: Create Public IP Addresses

1. **Navigate to Public IP Addresses**
   - Search "Public IP addresses"
   - Click "+ Create"

2. **Create Multiple Public IPs**
   Create the following public IPs with these settings:
   - **SKU**: `Standard`
   - **Assignment**: `Static`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   
   **Public IP Names:**
   - `pip-web-frontend-1`
   - `pip-web-frontend-2`
   - `pip-app-frontend`
   - `pip-outbound`

### Step 4: Create Standard Load Balancer

1. **Navigate to Load Balancers**
   - Search "Load balancers"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `lb-standard-3tier`
   - **Region**: `Southeast Asia`
   - **SKU**: `Standard`
   - **Type**: `Public`

3. **Frontend IP Configuration**
   - **Name**: `frontend-web-1`
   - **Public IP address**: `pip-web-frontend-1`

4. **Backend Pools**
   - **Name**: `backend-web-1`
   - **Virtual network**: `vnet-3tier`
   - **Backend pool configuration**: `NIC`

5. **Review and Create**
   - Click "Review + create" → "Create"

### Step 5: Configure Additional Frontend IPs

1. **Navigate to Load Balancer**
   - Go to the created load balancer `lb-standard-3tier`
   - Click "Frontend IP configuration" in the left menu

2. **Add Frontend IPs**
   - Click "+ Add"
   - **Name**: `frontend-web-2`, **Public IP**: `pip-web-frontend-2`
   - **Name**: `frontend-app`, **Public IP**: `pip-app-frontend`
   - **Name**: `frontend-outbound`, **Public IP**: `pip-outbound`

### Step 6: Create Backend Pools

1. **Navigate to Backend Pools**
   - In the load balancer, click "Backend pools"
   - Click "+ Add" for each pool:
   
   **Backend Pool Names:**
   - `backend-web-2`
   - `backend-app-1`
   - `backend-app-2`
   - `backend-db-1`
   - `backend-db-2`

### Step 7: Create Health Probes

1. **Navigate to Health Probes**
   - Click "Health probes"
   - Click "+ Add"

2. **Create Probes**
   **Web Probe:**
   - **Name**: `probe-web`
   - **Protocol**: `HTTP`
   - **Port**: `80`
   - **Path**: `/`
   
   **App Probe:**
   - **Name**: `probe-app`
   - **Protocol**: `HTTP`
   - **Port**: `8080`
   - **Path**: `/health`
   
   **DB Probe:**
   - **Name**: `probe-db`
   - **Protocol**: `TCP`
   - **Port**: `3306`

### Step 8: Create Load Balancing Rules

1. **Navigate to Load Balancing Rules**
   - Click "Load balancing rules"
   - Click "+ Add"

2. **Create Rules**
   **Web Rule 1:**
   - **Name**: `rule-web-1`
   - **Frontend IP**: `frontend-web-1`
   - **Protocol**: `TCP`
   - **Port**: `80`
   - **Backend pool**: `backend-web-1`
   - **Health probe**: `probe-web`
   
   **Web Rule 2:**
   - **Name**: `rule-web-2`
   - **Frontend IP**: `frontend-web-2`
   - **Protocol**: `TCP`
   - **Port**: `80`
   - **Backend pool**: `backend-web-2`
   - **Health probe**: `probe-web`
   
   **App Rule:**
   - **Name**: `rule-app`
   - **Frontend IP**: `frontend-app`
   - **Protocol**: `TCP`
   - **Port**: `8080`
   - **Backend pool**: `backend-app-1`
   - **Health probe**: `probe-app`

### Step 9: Create Network Security Groups

1. **Create Web Tier NSG**
   - Search "Network security groups"
   - Click "+ Create"
   - **Name**: `nsg-web`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   
   **Add Rules:**
   - **HTTP**: Port 80, Priority 100
   - **SSH**: Port 22, Priority 110

2. **Create App Tier NSG**
   - **Name**: `nsg-app`
   - **Add Rules:**
   - **App Traffic**: Port 8080, Source: 10.0.1.0/24,10.0.2.0/24, Priority 100
   - **SSH**: Port 22, Priority 110

3. **Create DB Tier NSG**
   - **Name**: `nsg-db`
   - **Add Rules:**
   - **MySQL**: Port 3306, Source: 10.0.3.0/24,10.0.4.0/24, Priority 100

4. **Associate NSGs with Subnets**
   - Go to each subnet in the VNet
   - Associate appropriate NSG with each subnet

### Step 10: Create Virtual Machine Scale Sets

1. **Navigate to Virtual Machine Scale Sets**
   - Search "Virtual machine scale sets"
   - Click "+ Create"

2. **Create Web Tier VMSS 1**
   **Basics:**
   - **Name**: `vmss-web-1`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Region**: `Southeast Asia`
   - **Image**: `Ubuntu Server 22.04 LTS`
   - **Size**: `Standard_B1s`
   - **Instance count**: `2`
   - **Username**: `azureuser`
   - **Authentication**: SSH public key
   
   **Networking:**
   - **Virtual network**: `vnet-3tier`
   - **Subnet**: `subnet-web-1`
   - **Load balancer**: `lb-standard-3tier`
   - **Backend pool**: `backend-web-1`
   
   **Management:**
   - **Upgrade policy**: `Automatic`

3. **Repeat for Other VMSS**
   Create similar VMSS for:
   - `vmss-web-2` in `subnet-web-2` with `backend-web-2`
   - `vmss-app-1` in `subnet-app-1` with `backend-app-1`
   - `vmss-app-2` in `subnet-app-2` with `backend-app-2`
   - `vmss-db-1` in `subnet-db-1` with `backend-db-1`
   - `vmss-db-2` in `subnet-db-2` with `backend-db-2`

### Step 11: Configure NAT Rules

1. **Navigate to Load Balancer**
   - Go to `lb-standard-3tier`
   - Click "Inbound NAT pools"
   - Click "+ Add"

2. **Create NAT Pools**
   **Web VMSS 1 SSH:**
   - **Name**: `nat-pool-web-1-ssh`
   - **Frontend IP**: `frontend-web-1`
   - **Protocol**: `TCP`
   - **Frontend port range**: `50001-50010`
   - **Backend port**: `22`
   
   **Web VMSS 2 SSH:**
   - **Name**: `nat-pool-web-2-ssh`
   - **Frontend IP**: `frontend-web-2`
   - **Protocol**: `TCP`
   - **Frontend port range**: `50011-50020`
   - **Backend port**: `22`
   
   **App VMSS SSH:**
   - **Name**: `nat-pool-app-1-ssh`
   - **Frontend IP**: `frontend-app`
   - **Protocol**: `TCP`
   - **Frontend port range**: `50021-50030`
   - **Backend port**: `22`

### Step 12: Configure Outbound Rules

1. **Navigate to Outbound Rules**
   - In the load balancer, click "Outbound rules"
   - Click "+ Add"

2. **Create Outbound Rule**
   - **Name**: `outbound-rule-all`
   - **Frontend IP**: `frontend-outbound`
   - **Protocol**: `All`
   - **Backend pool**: Select all backend pools

### Step 13: Verification

1. **Check Load Balancer Status**
   - Go to load balancer overview
   - Verify all frontend IPs are assigned
   - Check backend pool health

2. **Test VMSS Connectivity**
   - Go to each VMSS
   - Check instance health
   - Verify load balancer association

3. **Monitor Health Probes**
   - Check health probe status
   - Verify backend instance health

---

## Method 2: Using Azure CLI

## Resource Group
```bash
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia
```

## Virtual Network and Subnets
```bash
# Create VNet
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-3tier \
  --address-prefix 10.0.0.0/16

# Web Tier Subnets
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-web-1 \
  --address-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-web-2 \
  --address-prefix 10.0.2.0/24

# App Tier Subnets
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-app-1 \
  --address-prefix 10.0.3.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-app-2 \
  --address-prefix 10.0.4.0/24

# DB Tier Subnets
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-db-1 \
  --address-prefix 10.0.5.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-db-2 \
  --address-prefix 10.0.6.0/24
```

## Public IP Addresses
```bash
# Frontend Public IPs
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-web-frontend-1 \
  --sku Standard \
  --allocation-method Static

az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-web-frontend-2 \
  --sku Standard \
  --allocation-method Static

az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-app-frontend \
  --sku Standard \
  --allocation-method Static

# Outbound Public IP
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-outbound \
  --sku Standard \
  --allocation-method Static
```

## Standard Load Balancer
```bash
az network lb create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name lb-standard-3tier \
  --sku Standard \
  --public-ip-address pip-web-frontend-1 \
  --frontend-ip-name frontend-web-1

# Additional Frontend IP Configurations
az network lb frontend-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name frontend-web-2 \
  --public-ip-address pip-web-frontend-2

az network lb frontend-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name frontend-app \
  --public-ip-address pip-app-frontend

az network lb frontend-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name frontend-outbound \
  --public-ip-address pip-outbound
```

## Backend Pools
```bash
# Web Tier Backend Pools
az network lb address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-web-1

az network lb address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-web-2

# App Tier Backend Pools
az network lb address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-app-1

az network lb address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-app-2

# DB Tier Backend Pools
az network lb address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-db-1

az network lb address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-db-2
```

## Health Probes
```bash
# Web Tier Health Probe
az network lb probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name probe-web \
  --protocol Http \
  --port 80 \
  --path /

# App Tier Health Probe
az network lb probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name probe-app \
  --protocol Http \
  --port 8080 \
  --path /health

# DB Tier Health Probe
az network lb probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name probe-db \
  --protocol Tcp \
  --port 3306
```

## Load Balancing Rules
```bash
# Web Tier Load Balancing Rules
az network lb rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name rule-web-1 \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name frontend-web-1 \
  --backend-pool-name backend-web-1 \
  --probe-name probe-web

az network lb rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name rule-web-2 \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name frontend-web-2 \
  --backend-pool-name backend-web-2 \
  --probe-name probe-web

# App Tier Load Balancing Rule
az network lb rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name rule-app \
  --protocol Tcp \
  --frontend-port 8080 \
  --backend-port 8080 \
  --frontend-ip-name frontend-app \
  --backend-pool-name backend-app-1 \
  --probe-name probe-app
```

## NAT Rules
```bash
# SSH NAT Rules for Web Tier VMSS 1
az network lb inbound-nat-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name nat-pool-web-1-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50001 \
  --frontend-port-range-end 50010 \
  --backend-port 22 \
  --frontend-ip-name frontend-web-1

# SSH NAT Rules for Web Tier VMSS 2
az network lb inbound-nat-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name nat-pool-web-2-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50011 \
  --frontend-port-range-end 50020 \
  --backend-port 22 \
  --frontend-ip-name frontend-web-2

# SSH NAT Rules for App Tier VMSS
az network lb inbound-nat-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name nat-pool-app-1-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50021 \
  --frontend-port-range-end 50030 \
  --backend-port 22 \
  --frontend-ip-name frontend-app

az network lb inbound-nat-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name nat-pool-app-2-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50031 \
  --frontend-port-range-end 50040 \
  --backend-port 22 \
  --frontend-ip-name frontend-app
```

## Outbound Rules
```bash
az network lb outbound-rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name outbound-rule-all \
  --protocol All \
  --frontend-ip-configs frontend-outbound \
  --backend-pool backend-web-1 backend-web-2 backend-app-1 backend-app-2 backend-db-1 backend-db-2
```

## Network Security Groups
```bash
# Web Tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-web

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web \
  --name allow-http \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 80

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web \
  --name allow-ssh \
  --priority 110 \
  --protocol Tcp \
  --destination-port-ranges 22

# App Tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-app

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-app \
  --name allow-app \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 8080 \
  --source-address-prefixes 10.0.1.0/24 10.0.2.0/24

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-app \
  --name allow-ssh \
  --priority 110 \
  --protocol Tcp \
  --destination-port-ranges 22

# DB Tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-db

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-db \
  --name allow-mysql \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 3306 \
  --source-address-prefixes 10.0.3.0/24 10.0.4.0/24

# Associate NSGs with Subnets
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-web-1 \
  --network-security-group nsg-web

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-web-2 \
  --network-security-group nsg-web

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-app-1 \
  --network-security-group nsg-app

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-app-2 \
  --network-security-group nsg-app

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-db-1 \
  --network-security-group nsg-db

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-db-2 \
  --network-security-group nsg-db
```

## Virtual Machine Scale Sets
```bash
# Web Tier VMSS 1
az vmss create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vmss-web-1 \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vnet-3tier \
  --subnet subnet-web-1 \
  --lb lb-standard-3tier \
  --lb-nat-pool-name nat-pool-web-1-ssh \
  --backend-pool-name backend-web-1 \
  --upgrade-policy-mode automatic

# Web Tier VMSS 2
az vmss create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vmss-web-2 \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vnet-3tier \
  --subnet subnet-web-2 \
  --lb lb-standard-3tier \
  --lb-nat-pool-name nat-pool-web-2-ssh \
  --backend-pool-name backend-web-2 \
  --upgrade-policy-mode automatic

# App Tier VMSS 1
az vmss create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vmss-app-1 \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vnet-3tier \
  --subnet subnet-app-1 \
  --lb lb-standard-3tier \
  --lb-nat-pool-name nat-pool-app-1-ssh \
  --backend-pool-name backend-app-1 \
  --upgrade-policy-mode automatic

# App Tier VMSS 2
az vmss create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vmss-app-2 \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vnet-3tier \
  --subnet subnet-app-2 \
  --lb lb-standard-3tier \
  --lb-nat-pool-name nat-pool-app-2-ssh \
  --backend-pool-name backend-app-2 \
  --upgrade-policy-mode automatic

# DB Tier VMSS 1
az vmss create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vmss-db-1 \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vnet-3tier \
  --subnet subnet-db-1 \
  --backend-pool-name backend-db-1 \
  --upgrade-policy-mode automatic

# DB Tier VMSS 2
az vmss create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vmss-db-2 \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vnet-3tier \
  --subnet subnet-db-2 \
  --backend-pool-name backend-db-2 \
  --upgrade-policy-mode automatic
```

## Verification Commands
```bash
# Check Load Balancer Configuration
az network lb show --resource-group sa1_test_eic_SudarshanDarade --name lb-standard-3tier

# Check VMSS Status
az vmss list --resource-group sa1_test_eic_SudarshanDarade --output table

# Check Backend Pool Members
az network lb address-pool show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --lb-name lb-standard-3tier \
  --name backend-web-1

# Get Public IP Addresses
az network public-ip list --resource-group sa1_test_eic_SudarshanDarade --output table
```

## Architecture Summary
- **3-Tier Architecture**: Web, App, and DB tiers with dedicated subnets
- **6 VMSS**: 2 per tier for high availability
- **Standard Load Balancer**: With multiple frontend IPs and backend pools
- **NAT Rules**: SSH access to VMSS instances
- **Outbound Rules**: Controlled internet access
- **Network Security**: NSGs with tier-specific rules
- **Private Subnets**: All VMSS deployed in private subnets
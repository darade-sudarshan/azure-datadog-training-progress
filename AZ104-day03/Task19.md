# Task 19: 3-Tier VNet with VMSS and Standard Load Balancer

## Architecture Overview
3-tier VNet hosting 2 VMSS each in private subnets with Standard Load Balancer, NAT rules, outbound rules, multiple backend pools and public frontend addresses.

## Resource Group
```bash
az group create --name rg-3tier-vmss --location eastus
```

## Virtual Network and Subnets
```bash
# Create VNet
az network vnet create \
  --resource-group rg-3tier-vmss \
  --name vnet-3tier \
  --address-prefix 10.0.0.0/16

# Web Tier Subnets
az network vnet subnet create \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-web-1 \
  --address-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-web-2 \
  --address-prefix 10.0.2.0/24

# App Tier Subnets
az network vnet subnet create \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-app-1 \
  --address-prefix 10.0.3.0/24

az network vnet subnet create \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-app-2 \
  --address-prefix 10.0.4.0/24

# DB Tier Subnets
az network vnet subnet create \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-db-1 \
  --address-prefix 10.0.5.0/24

az network vnet subnet create \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-db-2 \
  --address-prefix 10.0.6.0/24
```

## Public IP Addresses
```bash
# Frontend Public IPs
az network public-ip create \
  --resource-group rg-3tier-vmss \
  --name pip-web-frontend-1 \
  --sku Standard \
  --allocation-method Static

az network public-ip create \
  --resource-group rg-3tier-vmss \
  --name pip-web-frontend-2 \
  --sku Standard \
  --allocation-method Static

az network public-ip create \
  --resource-group rg-3tier-vmss \
  --name pip-app-frontend \
  --sku Standard \
  --allocation-method Static

# Outbound Public IP
az network public-ip create \
  --resource-group rg-3tier-vmss \
  --name pip-outbound \
  --sku Standard \
  --allocation-method Static
```

## Standard Load Balancer
```bash
az network lb create \
  --resource-group rg-3tier-vmss \
  --name lb-standard-3tier \
  --sku Standard \
  --public-ip-address pip-web-frontend-1 \
  --frontend-ip-name frontend-web-1

# Additional Frontend IP Configurations
az network lb frontend-ip create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name frontend-web-2 \
  --public-ip-address pip-web-frontend-2

az network lb frontend-ip create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name frontend-app \
  --public-ip-address pip-app-frontend

az network lb frontend-ip create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name frontend-outbound \
  --public-ip-address pip-outbound
```

## Backend Pools
```bash
# Web Tier Backend Pools
az network lb address-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-web-1

az network lb address-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-web-2

# App Tier Backend Pools
az network lb address-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-app-1

az network lb address-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-app-2

# DB Tier Backend Pools
az network lb address-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-db-1

az network lb address-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-db-2
```

## Health Probes
```bash
# Web Tier Health Probe
az network lb probe create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name probe-web \
  --protocol Http \
  --port 80 \
  --path /

# App Tier Health Probe
az network lb probe create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name probe-app \
  --protocol Http \
  --port 8080 \
  --path /health

# DB Tier Health Probe
az network lb probe create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name probe-db \
  --protocol Tcp \
  --port 3306
```

## Load Balancing Rules
```bash
# Web Tier Load Balancing Rules
az network lb rule create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name rule-web-1 \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name frontend-web-1 \
  --backend-pool-name backend-web-1 \
  --probe-name probe-web

az network lb rule create \
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name nat-pool-web-1-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50001 \
  --frontend-port-range-end 50010 \
  --backend-port 22 \
  --frontend-ip-name frontend-web-1

# SSH NAT Rules for Web Tier VMSS 2
az network lb inbound-nat-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name nat-pool-web-2-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50011 \
  --frontend-port-range-end 50020 \
  --backend-port 22 \
  --frontend-ip-name frontend-web-2

# SSH NAT Rules for App Tier VMSS
az network lb inbound-nat-pool create \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name nat-pool-app-1-ssh \
  --protocol Tcp \
  --frontend-port-range-start 50021 \
  --frontend-port-range-end 50030 \
  --backend-port 22 \
  --frontend-ip-name frontend-app

az network lb inbound-nat-pool create \
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
  --name nsg-web

az network nsg rule create \
  --resource-group rg-3tier-vmss \
  --nsg-name nsg-web \
  --name allow-http \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 80

az network nsg rule create \
  --resource-group rg-3tier-vmss \
  --nsg-name nsg-web \
  --name allow-ssh \
  --priority 110 \
  --protocol Tcp \
  --destination-port-ranges 22

# App Tier NSG
az network nsg create \
  --resource-group rg-3tier-vmss \
  --name nsg-app

az network nsg rule create \
  --resource-group rg-3tier-vmss \
  --nsg-name nsg-app \
  --name allow-app \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 8080 \
  --source-address-prefixes 10.0.1.0/24 10.0.2.0/24

az network nsg rule create \
  --resource-group rg-3tier-vmss \
  --nsg-name nsg-app \
  --name allow-ssh \
  --priority 110 \
  --protocol Tcp \
  --destination-port-ranges 22

# DB Tier NSG
az network nsg create \
  --resource-group rg-3tier-vmss \
  --name nsg-db

az network nsg rule create \
  --resource-group rg-3tier-vmss \
  --nsg-name nsg-db \
  --name allow-mysql \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 3306 \
  --source-address-prefixes 10.0.3.0/24 10.0.4.0/24

# Associate NSGs with Subnets
az network vnet subnet update \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-web-1 \
  --network-security-group nsg-web

az network vnet subnet update \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-web-2 \
  --network-security-group nsg-web

az network vnet subnet update \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-app-1 \
  --network-security-group nsg-app

az network vnet subnet update \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-app-2 \
  --network-security-group nsg-app

az network vnet subnet update \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-db-1 \
  --network-security-group nsg-db

az network vnet subnet update \
  --resource-group rg-3tier-vmss \
  --vnet-name vnet-3tier \
  --name subnet-db-2 \
  --network-security-group nsg-db
```

## Virtual Machine Scale Sets
```bash
# Web Tier VMSS 1
az vmss create \
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
  --resource-group rg-3tier-vmss \
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
az network lb show --resource-group rg-3tier-vmss --name lb-standard-3tier

# Check VMSS Status
az vmss list --resource-group rg-3tier-vmss --output table

# Check Backend Pool Members
az network lb address-pool show \
  --resource-group rg-3tier-vmss \
  --lb-name lb-standard-3tier \
  --name backend-web-1

# Get Public IP Addresses
az network public-ip list --resource-group rg-3tier-vmss --output table
```

## Architecture Summary
- **3-Tier Architecture**: Web, App, and DB tiers with dedicated subnets
- **6 VMSS**: 2 per tier for high availability
- **Standard Load Balancer**: With multiple frontend IPs and backend pools
- **NAT Rules**: SSH access to VMSS instances
- **Outbound Rules**: Controlled internet access
- **Network Security**: NSGs with tier-specific rules
- **Private Subnets**: All VMSS deployed in private subnets
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
  --name rg-network-security \
  --location eastus

# Create virtual network
az network vnet create \
  --resource-group rg-network-security \
  --name vnet-security-demo \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Create additional subnets
az network vnet subnet create \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-app \
  --address-prefix 10.0.2.0/24

az network vnet subnet create \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-db \
  --address-prefix 10.0.3.0/24
```

### 2. Create Basic NSG

```bash
# Create NSG for web tier
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-web-tier \
  --location eastus

# Create NSG for app tier
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-app-tier \
  --location eastus

# Create NSG for database tier
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-db-tier \
  --location eastus
```

### 3. Create NSG Rules

```bash
# Web tier rules - Allow HTTP, HTTPS, SSH
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name asg-web-servers \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-app-servers \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-db-servers \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-management \
  --location eastus
```

### 2. Create NSG with ASG Rules

```bash
# Create NSG that uses ASGs
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-with-asg \
  --location eastus

# Allow HTTP/HTTPS to web servers
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --network-security-group nsg-web-tier

az network vnet subnet update \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-app \
  --network-security-group nsg-app-tier

az network vnet subnet update \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-db \
  --network-security-group nsg-db-tier
```

### 2. Create VMs and Associate with ASGs

```bash
# Create web server VM
az vm create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --nic-name vm-web-01VMNic \
  --name ipconfigvm-web-01 \
  --application-security-groups asg-web-servers

# Create app server VM
az vm create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --nic-name vm-app-01VMNic \
  --name ipconfigvm-app-01 \
  --application-security-groups asg-app-servers

# Create database server VM
az vm create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name nsg-service-tags \
  --location eastus

# Allow Azure Load Balancer
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --nsg-name nsg-service-tags \
  --name allow-storage-eastus \
  --priority 120 \
  --source-address-prefixes '*' \
  --destination-address-prefixes Storage.EastUS \
  --destination-port-ranges 443 \
  --direction Outbound \
  --access Allow \
  --protocol Tcp
```

### 3. Augmented Security Rules

```bash
# Create rule with multiple sources and destinations
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name nsg-3tier-web \
  --location eastus

# Allow internet traffic to web tier
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name nsg-dmz \
  --location eastus

# Allow specific external services
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name asg-dev-web \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-dev-api \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-dev-db \
  --location eastus

# Create development NSG
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-development \
  --location eastus

# Allow developers access to all dev resources
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name asg-frontend-service \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-auth-service \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-payment-service \
  --location eastus

az network asg create \
  --resource-group rg-network-security \
  --name asg-order-service \
  --location eastus

# Create microservices NSG
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-microservices \
  --location eastus

# Allow external access to frontend only
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name stflowlogs$(date +%s) \
  --sku Standard_LRS \
  --location eastus

# Enable NSG flow logs
az network watcher flow-log create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --workspace-name nsg-analytics \
  --location eastus

# Enable NSG diagnostic logs
az monitor diagnostic-settings create \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-network-security/providers/Microsoft.Network/networkSecurityGroups/nsg-web-tier \
  --name nsg-diagnostics \
  --logs '[{"category":"NetworkSecurityGroupEvent","enabled":true},{"category":"NetworkSecurityGroupRuleCounter","enabled":true}]' \
  --workspace /subscriptions/{subscription-id}/resourceGroups/rg-network-security/providers/Microsoft.OperationalInsights/workspaces/nsg-analytics
```

---

## Management and Operations

### 1. View NSG Information

```bash
# List all NSGs
az network nsg list \
  --resource-group rg-network-security \
  --output table

# Show NSG details
az network nsg show \
  --resource-group rg-network-security \
  --name nsg-web-tier \
  --query "{Name:name, Rules:securityRules[].{Name:name, Priority:priority, Access:access, Direction:direction}}"

# List NSG rules
az network nsg rule list \
  --resource-group rg-network-security \
  --nsg-name nsg-web-tier \
  --output table

# Show effective security rules for a NIC
az network nic list-effective-nsg \
  --resource-group rg-network-security \
  --name vm-web-01VMNic
```

### 2. View ASG Information

```bash
# List all ASGs
az network asg list \
  --resource-group rg-network-security \
  --output table

# Show ASG details
az network asg show \
  --resource-group rg-network-security \
  --name asg-web-servers

# List NICs associated with ASG
az network asg show \
  --resource-group rg-network-security \
  --name asg-web-servers \
  --query "ipConfigurations[].id"
```

### 3. Update NSG Rules

```bash
# Update existing rule
az network nsg rule update \
  --resource-group rg-network-security \
  --nsg-name nsg-web-tier \
  --name allow-http \
  --source-address-prefixes '203.0.113.0/24' '198.51.100.0/24'

# Delete NSG rule
az network nsg rule delete \
  --resource-group rg-network-security \
  --nsg-name nsg-web-tier \
  --name allow-ssh
```

---

## Security Best Practices

### 1. Principle of Least Privilege

```bash
# Create restrictive NSG
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-restrictive \
  --location eastus

# Allow only specific required ports
az network nsg rule create \
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
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
  --resource-group rg-network-security \
  --name nsg-subnet-defense \
  --location eastus

# NIC level NSG (fine-grained)
az network nsg create \
  --resource-group rg-network-security \
  --name nsg-nic-defense \
  --location eastus

# Associate subnet NSG
az network vnet subnet update \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --network-security-group nsg-subnet-defense

# Associate NIC NSG
az network nic update \
  --resource-group rg-network-security \
  --name vm-web-01VMNic \
  --network-security-group nsg-nic-defense
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check NSG associations
az network vnet subnet show \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --query "networkSecurityGroup.id"

# Verify effective routes
az network nic show-effective-route-table \
  --resource-group rg-network-security \
  --name vm-web-01VMNic

# Check connectivity
az network watcher test-connectivity \
  --resource-group rg-network-security \
  --source-resource vm-web-01 \
  --dest-resource vm-app-01 \
  --dest-port 8080
```

### 2. Diagnostic Commands

```bash
# Verify NSG rule evaluation
az network watcher test-ip-flow \
  --resource-group rg-network-security \
  --vm vm-web-01 \
  --direction Inbound \
  --protocol TCP \
  --local 10.0.1.4:80 \
  --remote 203.0.113.10:12345

# Check next hop
az network watcher show-next-hop \
  --resource-group rg-network-security \
  --vm vm-web-01 \
  --source-ip 10.0.1.4 \
  --dest-ip 10.0.2.4
```

---

## Cleanup

```bash
# Remove NSG associations
az network vnet subnet update \
  --resource-group rg-network-security \
  --vnet-name vnet-security-demo \
  --name subnet-web \
  --remove networkSecurityGroup

# Delete NSGs
az network nsg delete \
  --resource-group rg-network-security \
  --name nsg-web-tier

# Delete ASGs
az network asg delete \
  --resource-group rg-network-security \
  --name asg-web-servers

# Delete resource group
az group delete \
  --name rg-network-security \
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
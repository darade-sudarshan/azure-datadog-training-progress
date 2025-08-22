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
  --name rg-bastion-hub \
  --location eastus

# Create hub virtual network
az network vnet create \
  --resource-group rg-bastion-hub \
  --name vnet-hub-eastus \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-hub \
  --subnet-prefix 10.0.1.0/24

# Create AzureBastionSubnet (required name)
az network vnet subnet create \
  --resource-group rg-bastion-hub \
  --vnet-name vnet-hub-eastus \
  --name AzureBastionSubnet \
  --address-prefix 10.0.100.0/26
```

### 2. Create Azure Bastion

```bash
# Create public IP for Bastion
az network public-ip create \
  --resource-group rg-bastion-hub \
  --name pip-bastion-hub \
  --sku Standard \
  --allocation-method Static

# Create Azure Bastion
az network bastion create \
  --resource-group rg-bastion-hub \
  --name bastion-hub \
  --public-ip-address pip-bastion-hub \
  --vnet-name vnet-hub-eastus \
  --location eastus \
  --sku Standard
```

### 3. Create Test VM in Hub

```bash
# Create VM in hub network
az vm create \
  --resource-group rg-bastion-hub \
  --name vm-hub-eastus \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-hub-eastus \
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
  --resource-group rg-bastion-hub \
  --name hub-to-west-spoke \
  --vnet-name vnet-hub-eastus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Network/virtualNetworks/vnet-spoke-westus \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer west spoke to hub
az network vnet peering create \
  --resource-group rg-bastion-spoke-west \
  --name west-spoke-to-hub \
  --vnet-name vnet-spoke-westus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --use-remote-gateways

# Peer hub to central spoke
az network vnet peering create \
  --resource-group rg-bastion-hub \
  --name hub-to-central-spoke \
  --vnet-name vnet-hub-eastus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-central/providers/Microsoft.Network/virtualNetworks/vnet-spoke-centralus \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer central spoke to hub
az network vnet peering create \
  --resource-group rg-bastion-spoke-central \
  --name central-spoke-to-hub \
  --vnet-name vnet-spoke-centralus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --use-remote-gateways
```

### 2. Verify Peering Status

```bash
# Check peering status
az network vnet peering list \
  --resource-group rg-bastion-hub \
  --vnet-name vnet-hub-eastus \
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
  --location eastus2

# Create spoke virtual network
az network vnet create \
  --resource-group rg-bastion-spoke-east2 \
  --name vnet-spoke-eastus2 \
  --address-prefix 10.3.0.0/16 \
  --subnet-name subnet-spoke \
  --subnet-prefix 10.3.1.0/24

# Create VM in spoke network
az vm create \
  --resource-group rg-bastion-spoke-east2 \
  --name vm-spoke-eastus2 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-spoke-eastus2 \
  --subnet subnet-spoke \
  --public-ip "" \
  --size Standard_B1s
```

### 2. Create Transitive Network

```bash
# Create transitive network (connected to East US 2 spoke)
az group create \
  --name rg-bastion-transitive \
  --location eastus2

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
  --name eastus2-to-transitive \
  --vnet-name vnet-spoke-eastus2 \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-transitive/providers/Microsoft.Network/virtualNetworks/vnet-transitive \
  --allow-vnet-access \
  --allow-forwarded-traffic

# Peer transitive network to East US 2 spoke
az network vnet peering create \
  --resource-group rg-bastion-transitive \
  --name transitive-to-eastus2 \
  --vnet-name vnet-transitive \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-east2/providers/Microsoft.Network/virtualNetworks/vnet-spoke-eastus2 \
  --allow-vnet-access \
  --allow-forwarded-traffic

# Peer hub to East US 2 spoke
az network vnet peering create \
  --resource-group rg-bastion-hub \
  --name hub-to-eastus2-spoke \
  --vnet-name vnet-hub-eastus \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-east2/providers/Microsoft.Network/virtualNetworks/vnet-spoke-eastus2 \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Peer East US 2 spoke to hub
az network vnet peering create \
  --resource-group rg-bastion-spoke-east2 \
  --name eastus2-spoke-to-hub \
  --vnet-name vnet-spoke-eastus2 \
  --remote-vnet /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus \
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
  --location eastus2

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
  --resource-group rg-bastion-hub \
  --vnet-name vnet-hub-eastus \
  --name subnet-hub \
  --route-table /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-east2/providers/Microsoft.Network/routeTables/rt-transitive-access
```

### 2. Enable IP Forwarding

```bash
# Enable IP forwarding on East US 2 spoke VM (acting as router)
az network nic update \
  --resource-group rg-bastion-spoke-east2 \
  --name vm-spoke-eastus2VMNic \
  --ip-forwarding true

# Configure IP forwarding in the VM
az vm run-command invoke \
  --resource-group rg-bastion-spoke-east2 \
  --name vm-spoke-eastus2 \
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
  --resource-group rg-bastion-hub \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Compute/virtualMachines/vm-spoke-westus \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key

# Test RDP to Windows VM
az network bastion rdp \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-central/providers/Microsoft.Compute/virtualMachines/vm-spoke-centralus
```

### 2. Test Cross-Region Access

```bash
# Access West US VM from East US Bastion
az network bastion ssh \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-west/providers/Microsoft.Compute/virtualMachines/vm-spoke-westus \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure-key

# Access Central US VM from East US Bastion
az network bastion rdp \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
  --target-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-bastion-spoke-central/providers/Microsoft.Compute/virtualMachines/vm-spoke-centralus
```

### 3. Test Transitive Access

```bash
# Access transitive network VM through hub Bastion
az network bastion ssh \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
  --enable-tunneling true

# Connect using native SSH client
az network bastion tunnel \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
  --enable-file-copy true

# Upload file to VM
az network bastion ssh \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
  --enable-ip-connect true

# Connect using private IP
az network bastion ssh \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
  --workspace-name bastion-analytics \
  --location eastus

# Enable diagnostic logs
az monitor diagnostic-settings create \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub/providers/Microsoft.Network/bastionHosts/bastion-hub \
  --name bastion-diagnostics \
  --logs '[{"category":"BastionAuditLogs","enabled":true}]' \
  --workspace /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub/providers/Microsoft.OperationalInsights/workspaces/bastion-analytics
```

### 2. Connection Monitoring

```bash
# Check Bastion status
az network bastion show \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
  --query "{Name:name, ProvisioningState:provisioningState, Sku:sku.name}"

# List active sessions (requires PowerShell or portal)
az network bastion show \
  --name bastion-hub \
  --resource-group rg-bastion-hub \
  --query "ipConfigurations[0].privateIpAddress"
```

---

## Security Best Practices

### 1. Network Security Groups

```bash
# Create NSG for Bastion subnet
az network nsg create \
  --resource-group rg-bastion-hub \
  --name nsg-bastion-subnet \
  --location eastus

# Allow HTTPS inbound from Internet
az network nsg rule create \
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
  --vnet-name vnet-hub-eastus \
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
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub
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
  --resource-group rg-bastion-hub \
  --scale-units 2

# Monitor usage and adjust scale units
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-bastion-hub/providers/Microsoft.Network/bastionHosts/bastion-hub \
  --metric "Sessions" \
  --interval PT1H
```

---

## Troubleshooting

### 1. Connectivity Issues

```bash
# Check VNet peering status
az network vnet peering show \
  --resource-group rg-bastion-hub \
  --vnet-name vnet-hub-eastus \
  --name hub-to-west-spoke \
  --query "{Name:name, PeeringState:peeringState, ProvisioningState:provisioningState}"

# Test network connectivity
az network watcher test-connectivity \
  --resource-group rg-bastion-hub \
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
  --resource-group rg-bastion-hub \
  --query "{ProvisioningState:provisioningState, DnsName:dnsName}"

# Verify subnet configuration
az network vnet subnet show \
  --resource-group rg-bastion-hub \
  --vnet-name vnet-hub-eastus \
  --name AzureBastionSubnet \
  --query "{AddressPrefix:addressPrefix, ProvisioningState:provisioningState}"
```

---

## Cleanup

```bash
# Delete Bastion hosts
az network bastion delete \
  --name bastion-hub \
  --resource-group rg-bastion-hub

az network bastion delete \
  --name bastion-west \
  --resource-group rg-bastion-spoke-west

# Delete resource groups
az group delete --name rg-bastion-hub --yes --no-wait
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
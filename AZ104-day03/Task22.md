# Task 22: Azure DNS - Local vs Public vs Private DNS

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
az group create --name rg-dns-demo --location eastus

# Create public DNS zone
az network dns zone create \
  --resource-group rg-dns-demo \
  --name contoso.com

# Get name servers
az network dns zone show \
  --resource-group rg-dns-demo \
  --name contoso.com \
  --query nameServers
```

### Add DNS Records
```bash
# A Record
az network dns record-set a add-record \
  --resource-group rg-dns-demo \
  --zone-name contoso.com \
  --record-set-name www \
  --ipv4-address 20.1.1.1

# CNAME Record
az network dns record-set cname set-record \
  --resource-group rg-dns-demo \
  --zone-name contoso.com \
  --record-set-name api \
  --cname www.contoso.com

# MX Record
az network dns record-set mx add-record \
  --resource-group rg-dns-demo \
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
  --resource-group rg-dns-demo \
  --name vnet-private \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Create private DNS zone
az network private-dns zone create \
  --resource-group rg-dns-demo \
  --name internal.contoso.com

# Link to VNet
az network private-dns link vnet create \
  --resource-group rg-dns-demo \
  --zone-name internal.contoso.com \
  --name link-vnet-private \
  --virtual-network vnet-private \
  --registration-enabled true
```

### Add Private DNS Records
```bash
# A Record for internal service
az network private-dns record-set a add-record \
  --resource-group rg-dns-demo \
  --zone-name internal.contoso.com \
  --record-set-name db \
  --ipv4-address 10.0.1.10

# A Record for API
az network private-dns record-set a add-record \
  --resource-group rg-dns-demo \
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
  --resource-group rg-dns-demo \
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
  --resource-group rg-dns-demo \
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
az network dns zone list --resource-group rg-dns-demo

# List private DNS zones
az network private-dns zone list --resource-group rg-dns-demo

# Check DNS records
az network dns record-set list \
  --resource-group rg-dns-demo \
  --zone-name contoso.com

az network private-dns record-set a list \
  --resource-group rg-dns-demo \
  --zone-name internal.contoso.com
```

## DNS Architecture Summary
- **Public DNS**: Internet-facing services and websites
- **Private DNS**: Internal Azure resources and services  
- **Local DNS**: On-premises corporate resources
- **Hybrid**: Combination using conditional forwarding
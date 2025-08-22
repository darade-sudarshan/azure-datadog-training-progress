# Azure Load Balancer with Linux VMs and Nginx Web Application

This guide covers creating a basic Azure Load Balancer with two Linux VMs hosting nginx web applications for high availability and load distribution.

## Understanding Azure Load Balancer

### Azure Load Balancer
- **Definition**: Layer 4 (TCP/UDP) load balancer distributing traffic across healthy VM instances
- **Types**: Basic and Standard SKUs with different feature sets
- **Components**: Frontend IP, Backend Pool, Health Probes, Load Balancing Rules
- **Benefits**: High availability, automatic failover, scalability

### Load Balancer Components
- **Frontend IP Configuration**: Public or private IP address receiving traffic
- **Backend Pool**: Collection of VMs or VM scale set instances
- **Health Probes**: Monitor application health on backend instances
- **Load Balancing Rules**: Define how traffic is distributed
- **Inbound NAT Rules**: Direct traffic to specific VM instances

### SKU Comparison

| Feature | Basic | Standard |
|---------|-------|----------|
| Backend Pool Size | Up to 300 instances | Up to 1000 instances |
| Health Probe | HTTP, TCP | HTTP, HTTPS, TCP |
| Availability Zones | No | Yes |
| SLA | None | 99.99% |
| Diagnostics | Limited | Comprehensive |
| Public IP SKU | Basic (Dynamic) | Standard (Static) |

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- SSH key pair for Linux VMs
- Basic understanding of networking concepts

---

## Creating the Infrastructure

### 1. Create Resource Group and Virtual Network

```bash
# Create resource group
az group create \
  --name rg-loadbalancer-demo \
  --location eastus

# Create virtual network
az network vnet create \
  --resource-group rg-loadbalancer-demo \
  --name vnet-lb-demo \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-lb-key -N ""
```

### 2. Create Availability Set

```bash
# Create availability set for VMs
az vm availability-set create \
  --resource-group rg-loadbalancer-demo \
  --name avset-web-servers \
  --platform-fault-domain-count 2 \
  --platform-update-domain-count 2 \
  --location eastus
```

### 3. Create Network Security Group

```bash
# Create NSG
az network nsg create \
  --resource-group rg-loadbalancer-demo \
  --name nsg-web-servers \
  --location eastus

# Allow HTTP traffic
az network nsg rule create \
  --resource-group rg-loadbalancer-demo \
  --nsg-name nsg-web-servers \
  --name allow-http \
  --priority 100 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp

# Allow SSH traffic
az network nsg rule create \
  --resource-group rg-loadbalancer-demo \
  --nsg-name nsg-web-servers \
  --name allow-ssh \
  --priority 110 \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

---

## Creating Linux VMs

### 1. Create First Web Server VM

```bash
# Create VM1
az vm create \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-lb-key.pub \
  --vnet-name vnet-lb-demo \
  --subnet subnet-web \
  --availability-set avset-web-servers \
  --nsg nsg-web-servers \
  --public-ip "" \
  --size Standard_B1s \
  --storage-sku Standard_LRS
```

### 2. Create Second Web Server VM

```bash
# Create VM2
az vm create \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-02 \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-lb-key.pub \
  --vnet-name vnet-lb-demo \
  --subnet subnet-web \
  --availability-set avset-web-servers \
  --nsg nsg-web-servers \
  --public-ip "" \
  --size Standard_B1s \
  --storage-sku Standard_LRS
```

---

## Installing and Configuring Nginx

### 1. Install Nginx on VM1

```bash
# Install nginx on VM1
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --command-id RunShellScript \
  --scripts "
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo '<h1>Web Server 01</h1><p>Hostname: $(hostname)</p><p>Private IP: $(hostname -I)</p><p>Server Time: $(date)</p>' | sudo tee /var/www/html/index.html
    sudo systemctl restart nginx
  "
```

### 2. Install Nginx on VM2

```bash
# Install nginx on VM2
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-02 \
  --command-id RunShellScript \
  --scripts "
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo '<h1>Web Server 02</h1><p>Hostname: $(hostname)</p><p>Private IP: $(hostname -I)</p><p>Server Time: $(date)</p>' | sudo tee /var/www/html/index.html
    sudo systemctl restart nginx
  "
```

### 3. Verify Nginx Installation

```bash
# Get VM private IPs
VM1_IP=$(az vm show -d --resource-group rg-loadbalancer-demo --name vm-web-01 --query privateIps -o tsv)
VM2_IP=$(az vm show -d --resource-group rg-loadbalancer-demo --name vm-web-02 --query privateIps -o tsv)

echo "VM1 Private IP: $VM1_IP"
echo "VM2 Private IP: $VM2_IP"
```

---

## Creating Azure Load Balancer

### 1. Create Public IP for Load Balancer

```bash
# Create public IP
az network public-ip create \
  --resource-group rg-loadbalancer-demo \
  --name pip-loadbalancer \
  --sku Basic \
  --allocation-method Dynamic \
  --location eastus
```

### 2. Create Load Balancer

```bash
# Create load balancer
az network lb create \
  --resource-group rg-loadbalancer-demo \
  --name lb-web-servers \
  --sku Basic \
  --public-ip-address pip-loadbalancer \
  --frontend-ip-name frontend-ip \
  --backend-pool-name backend-pool \
  --location eastus
```

### 3. Create Health Probe

```bash
# Create health probe
az network lb probe create \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name health-probe-http \
  --protocol Http \
  --port 80 \
  --path / \
  --interval 15 \
  --threshold 2
```

### 4. Create Load Balancing Rule

```bash
# Create load balancing rule
az network lb rule create \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name lb-rule-http \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name frontend-ip \
  --backend-pool-name backend-pool \
  --probe-name health-probe-http \
  --load-distribution Default
```

---

## Adding VMs to Backend Pool

### 1. Add VM1 to Backend Pool

```bash
# Get VM1 NIC ID
VM1_NIC_ID=$(az vm show --resource-group rg-loadbalancer-demo --name vm-web-01 --query "networkProfile.networkInterfaces[0].id" -o tsv)

# Add VM1 to backend pool
az network nic ip-config address-pool add \
  --resource-group rg-loadbalancer-demo \
  --nic-name vm-web-01VMNic \
  --ip-config-name ipconfigvm-web-01 \
  --lb-name lb-web-servers \
  --address-pool backend-pool
```

### 2. Add VM2 to Backend Pool

```bash
# Add VM2 to backend pool
az network nic ip-config address-pool add \
  --resource-group rg-loadbalancer-demo \
  --nic-name vm-web-02VMNic \
  --ip-config-name ipconfigvm-web-02 \
  --lb-name lb-web-servers \
  --address-pool backend-pool
```

---

## Testing Load Balancer

### 1. Get Load Balancer Public IP

```bash
# Get load balancer public IP
LB_PUBLIC_IP=$(az network public-ip show \
  --resource-group rg-loadbalancer-demo \
  --name pip-loadbalancer \
  --query ipAddress -o tsv)

echo "Load Balancer Public IP: $LB_PUBLIC_IP"
```

### 2. Test Load Distribution

```bash
# Test load balancer multiple times
echo "Testing load balancer distribution:"
for i in {1..10}; do
  echo "Request $i:"
  curl -s http://$LB_PUBLIC_IP | grep -E "<h1>|<p>Hostname:"
  echo "---"
  sleep 1
done
```

### 3. Continuous Testing Script

```bash
# Create continuous testing script
cat > test-loadbalancer.sh << 'EOF'
#!/bin/bash
LB_IP=$1
if [ -z "$LB_IP" ]; then
  echo "Usage: $0 <load-balancer-ip>"
  exit 1
fi

echo "Testing load balancer at $LB_IP"
echo "Press Ctrl+C to stop"

while true; do
  RESPONSE=$(curl -s http://$LB_IP)
  SERVER=$(echo "$RESPONSE" | grep -o "Web Server [0-9][0-9]" | head -1)
  HOSTNAME=$(echo "$RESPONSE" | grep -o "Hostname: [^<]*" | head -1)
  echo "$(date): $SERVER - $HOSTNAME"
  sleep 2
done
EOF

chmod +x test-loadbalancer.sh
./test-loadbalancer.sh $LB_PUBLIC_IP
```

---

## Monitoring and Health Checks

### 1. Check Backend Pool Health

```bash
# Check backend pool status
az network lb show \
  --resource-group rg-loadbalancer-demo \
  --name lb-web-servers \
  --query "backendAddressPools[0].backendIpConfigurations[].{Id:id}" \
  --output table

# Check health probe status
az network lb probe show \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name health-probe-http \
  --query "{Name:name, Protocol:protocol, Port:port, IntervalInSeconds:intervalInSeconds, NumberOfProbes:numberOfProbes}"
```

### 2. Monitor Load Balancer Metrics

```bash
# Get load balancer metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-loadbalancer-demo/providers/Microsoft.Network/loadBalancers/lb-web-servers \
  --metric "ByteCount" "PacketCount" \
  --interval PT1M \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z

# Check data path availability
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-loadbalancer-demo/providers/Microsoft.Network/loadBalancers/lb-web-servers \
  --metric "DipAvailability" \
  --interval PT1M
```

---

## Advanced Load Balancer Configuration

### 1. Create Inbound NAT Rules for SSH

```bash
# Create NAT rule for VM1 SSH
az network lb inbound-nat-rule create \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name nat-rule-vm1-ssh \
  --protocol Tcp \
  --frontend-port 2201 \
  --backend-port 22 \
  --frontend-ip-name frontend-ip

# Create NAT rule for VM2 SSH
az network lb inbound-nat-rule create \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name nat-rule-vm2-ssh \
  --protocol Tcp \
  --frontend-port 2202 \
  --backend-port 22 \
  --frontend-ip-name frontend-ip

# Associate NAT rules with VMs
az network nic ip-config inbound-nat-rule add \
  --resource-group rg-loadbalancer-demo \
  --nic-name vm-web-01VMNic \
  --ip-config-name ipconfigvm-web-01 \
  --lb-name lb-web-servers \
  --inbound-nat-rule nat-rule-vm1-ssh

az network nic ip-config inbound-nat-rule add \
  --resource-group rg-loadbalancer-demo \
  --nic-name vm-web-02VMNic \
  --ip-config-name ipconfigvm-web-02 \
  --lb-name lb-web-servers \
  --inbound-nat-rule nat-rule-vm2-ssh
```

### 2. Test SSH Access via NAT Rules

```bash
# SSH to VM1 via load balancer
ssh -i ~/.ssh/azure-lb-key azureuser@$LB_PUBLIC_IP -p 2201

# SSH to VM2 via load balancer
ssh -i ~/.ssh/azure-lb-key azureuser@$LB_PUBLIC_IP -p 2202
```

### 3. Configure Session Persistence

```bash
# Update load balancing rule for session persistence
az network lb rule update \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name lb-rule-http \
  --load-distribution SourceIP
```

---

## High Availability Testing

### 1. Simulate Server Failure

```bash
# Stop nginx on VM1 to simulate failure
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --command-id RunShellScript \
  --scripts "sudo systemctl stop nginx"

# Test load balancer (should only show VM2)
for i in {1..5}; do
  curl -s http://$LB_PUBLIC_IP | grep -E "<h1>|<p>Hostname:"
  sleep 1
done
```

### 2. Restore Service

```bash
# Start nginx on VM1
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --command-id RunShellScript \
  --scripts "sudo systemctl start nginx"

# Verify both servers are back online
for i in {1..10}; do
  curl -s http://$LB_PUBLIC_IP | grep -E "<h1>|<p>Hostname:"
  sleep 1
done
```

---

## Load Balancer Diagnostics

### 1. Basic Monitoring

```bash
# Note: Basic SKU has limited diagnostic capabilities
# Check load balancer status
az network lb show \
  --resource-group rg-loadbalancer-demo \
  --name lb-web-servers \
  --query "{Name:name, Sku:sku.name, ProvisioningState:provisioningState}"

# Monitor backend pool health manually
az network lb probe show \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name health-probe-http
```

### 2. Basic Health Monitoring

```bash
# Basic health check script
cat > check-lb-health.sh << 'EOF'
#!/bin/bash
LB_IP=$(az network public-ip show --resource-group rg-loadbalancer-demo --name pip-loadbalancer --query ipAddress -o tsv)
echo "Testing load balancer health at $LB_IP"
for i in {1..5}; do
  if curl -s --connect-timeout 5 http://$LB_IP > /dev/null; then
    echo "$(date): Load balancer responding"
  else
    echo "$(date): Load balancer not responding"
  fi
  sleep 10
done
EOF

chmod +x check-lb-health.sh
```

---

## Performance Optimization

### 1. Optimize Nginx Configuration

```bash
# Optimize nginx configuration on both VMs
NGINX_CONFIG='
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name _;
    
    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Add health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    location / {
        try_files $uri $uri/ =404;
    }
}
'

# Apply configuration to VM1
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --command-id RunShellScript \
  --scripts "
    echo '$NGINX_CONFIG' | sudo tee /etc/nginx/sites-available/default
    sudo nginx -t && sudo systemctl reload nginx
  "

# Apply configuration to VM2
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-02 \
  --command-id RunShellScript \
  --scripts "
    echo '$NGINX_CONFIG' | sudo tee /etc/nginx/sites-available/default
    sudo nginx -t && sudo systemctl reload nginx
  "
```

### 2. Update Health Probe

```bash
# Update health probe to use dedicated endpoint
az network lb probe update \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name health-probe-http \
  --path /health \
  --interval 5 \
  --threshold 2
```

---

## Security Enhancements

### 1. Restrict SSH Access

```bash
# Update NSG to restrict SSH access
az network nsg rule update \
  --resource-group rg-loadbalancer-demo \
  --nsg-name nsg-web-servers \
  --name allow-ssh \
  --source-address-prefixes '203.0.113.0/24'  # Replace with your IP range
```

### 2. Add HTTPS Support

```bash
# Create self-signed certificates on VMs
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --command-id RunShellScript \
  --scripts "
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/nginx-selfsigned.key \
      -out /etc/ssl/certs/nginx-selfsigned.crt \
      -subj '/C=US/ST=State/L=City/O=Organization/CN=vm-web-01'
  "

# Add HTTPS load balancing rule
az network lb rule create \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name lb-rule-https \
  --protocol Tcp \
  --frontend-port 443 \
  --backend-port 443 \
  --frontend-ip-name frontend-ip \
  --backend-pool-name backend-pool \
  --probe-name health-probe-http
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check backend pool members
az network lb address-pool show \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name backend-pool \
  --query "backendIpConfigurations[].{Id:id, PrivateIpAddress:privateIpAddress}"

# Verify health probe status
az network lb probe show \
  --resource-group rg-loadbalancer-demo \
  --lb-name lb-web-servers \
  --name health-probe-http

# Check NSG rules
az network nsg rule list \
  --resource-group rg-loadbalancer-demo \
  --nsg-name nsg-web-servers \
  --output table
```

### 2. Connectivity Testing

```bash
# Test individual VM connectivity
VM1_PRIVATE_IP=$(az vm show -d --resource-group rg-loadbalancer-demo --name vm-web-01 --query privateIps -o tsv)
VM2_PRIVATE_IP=$(az vm show -d --resource-group rg-loadbalancer-demo --name vm-web-02 --query privateIps -o tsv)

# Create a test VM in the same subnet for internal testing
az vm create \
  --resource-group rg-loadbalancer-demo \
  --name vm-test \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-lb-key.pub \
  --vnet-name vnet-lb-demo \
  --subnet subnet-web \
  --nsg nsg-web-servers \
  --size Standard_B1s

# Test internal connectivity from test VM
az vm run-command invoke \
  --resource-group rg-loadbalancer-demo \
  --name vm-test \
  --command-id RunShellScript \
  --scripts "
    curl -s http://$VM1_PRIVATE_IP | head -1
    curl -s http://$VM2_PRIVATE_IP | head -1
  "
```

---

## Cleanup

```bash
# Delete load balancer
az network lb delete \
  --resource-group rg-loadbalancer-demo \
  --name lb-web-servers

# Delete public IP
az network public-ip delete \
  --resource-group rg-loadbalancer-demo \
  --name pip-loadbalancer

# Delete VMs
az vm delete \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-01 \
  --yes

az vm delete \
  --resource-group rg-loadbalancer-demo \
  --name vm-web-02 \
  --yes

# Delete resource group
az group delete \
  --name rg-loadbalancer-demo \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Creating Azure Load Balancer with Basic SKU
- Setting up two Linux VMs with nginx web servers
- Configuring backend pools and health probes
- Implementing load balancing rules for traffic distribution
- Adding inbound NAT rules for SSH access
- Testing high availability and failover scenarios
- Basic monitoring and health checks
- Performance optimization and security enhancements
- Troubleshooting common connectivity issues

The Azure Load Balancer Basic SKU provides cost-effective high availability and scalability for web applications by distributing traffic across multiple healthy backend instances with automatic failover capabilities.
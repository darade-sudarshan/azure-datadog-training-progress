# Task 21: Application Gateway - Multiple Site Implementation

## Resource Group
```bash
az group create --name rg-appgw-multisite --location eastus
```

## Virtual Network
```bash
az network vnet create \
  --resource-group rg-appgw-multisite \
  --name vnet-appgw \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-appgw \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group rg-appgw-multisite \
  --vnet-name vnet-appgw \
  --name subnet-backend \
  --address-prefix 10.0.2.0/24
```

## Public IPs
```bash
az network public-ip create \
  --resource-group rg-appgw-multisite \
  --name pip-appgw \
  --allocation-method Static \
  --sku Standard
```

## Backend VMs
```bash
# Site A VM
az vm create \
  --resource-group rg-appgw-multisite \
  --name vm-site-a \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-site-a.txt

# Site B VM
az vm create \
  --resource-group rg-appgw-multisite \
  --name vm-site-b \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-site-b.txt

# Site C VM
az vm create \
  --resource-group rg-appgw-multisite \
  --name vm-site-c \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-site-c.txt
```

## Cloud-init Scripts
```bash
# Site A
cat > cloud-init-site-a.txt << 'EOF'
#cloud-config
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Welcome to Site A - www.contoso.com</h1>
      <p>This is the main corporate website</p>
runcmd:
  - systemctl restart nginx
EOF

# Site B
cat > cloud-init-site-b.txt << 'EOF'
#cloud-config
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Welcome to Site B - api.contoso.com</h1>
      <p>This is the API service website</p>
runcmd:
  - systemctl restart nginx
EOF

# Site C
cat > cloud-init-site-c.txt << 'EOF'
#cloud-config
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Welcome to Site C - blog.contoso.com</h1>
      <p>This is the blog website</p>
runcmd:
  - systemctl restart nginx
EOF
```

## Application Gateway
```bash
az network application-gateway create \
  --resource-group rg-appgw-multisite \
  --name appgw-multisite \
  --location eastus \
  --vnet-name vnet-appgw \
  --subnet subnet-appgw \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address pip-appgw
```

## Backend Pools
```bash
# Site A Backend Pool
az network application-gateway address-pool create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name pool-site-a \
  --servers 10.0.2.4

# Site B Backend Pool
az network application-gateway address-pool create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name pool-site-b \
  --servers 10.0.2.5

# Site C Backend Pool
az network application-gateway address-pool create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name pool-site-c \
  --servers 10.0.2.6
```

## HTTP Settings
```bash
az network application-gateway http-settings create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name http-settings-site-a \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

az network application-gateway http-settings create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name http-settings-site-b \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

az network application-gateway http-settings create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name http-settings-site-c \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled
```

## HTTP Listeners
```bash
# Site A Listener
az network application-gateway http-listener create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name listener-site-a \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port appGatewayFrontendPort \
  --host-name www.contoso.com

# Site B Listener
az network application-gateway http-listener create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name listener-site-b \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port appGatewayFrontendPort \
  --host-name api.contoso.com

# Site C Listener
az network application-gateway http-listener create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name listener-site-c \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port appGatewayFrontendPort \
  --host-name blog.contoso.com
```

## Routing Rules
```bash
# Site A Rule
az network application-gateway rule create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name rule-site-a \
  --http-listener listener-site-a \
  --rule-type Basic \
  --address-pool pool-site-a \
  --http-settings http-settings-site-a

# Site B Rule
az network application-gateway rule create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name rule-site-b \
  --http-listener listener-site-b \
  --rule-type Basic \
  --address-pool pool-site-b \
  --http-settings http-settings-site-b

# Site C Rule
az network application-gateway rule create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name rule-site-c \
  --http-listener listener-site-c \
  --rule-type Basic \
  --address-pool pool-site-c \
  --http-settings http-settings-site-c
```

## Health Probes
```bash
az network application-gateway probe create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name probe-site-a \
  --protocol Http \
  --host-name www.contoso.com \
  --path /

az network application-gateway probe create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name probe-site-b \
  --protocol Http \
  --host-name api.contoso.com \
  --path /

az network application-gateway probe create \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name probe-site-c \
  --protocol Http \
  --host-name blog.contoso.com \
  --path /
```

## Update HTTP Settings with Probes
```bash
az network application-gateway http-settings update \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name http-settings-site-a \
  --probe probe-site-a

az network application-gateway http-settings update \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name http-settings-site-b \
  --probe probe-site-b

az network application-gateway http-settings update \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite \
  --name http-settings-site-c \
  --probe probe-site-c
```

## DNS Configuration (Local Testing)
```bash
# Get Application Gateway Public IP
APPGW_IP=$(az network public-ip show \
  --resource-group rg-appgw-multisite \
  --name pip-appgw \
  --query ipAddress -o tsv)

echo "Application Gateway IP: $APPGW_IP"

# Add to /etc/hosts for testing
echo "$APPGW_IP www.contoso.com" | sudo tee -a /etc/hosts
echo "$APPGW_IP api.contoso.com" | sudo tee -a /etc/hosts
echo "$APPGW_IP blog.contoso.com" | sudo tee -a /etc/hosts
```

## Test Multiple Sites
```bash
# Test Site A
curl -H "Host: www.contoso.com" http://$APPGW_IP/

# Test Site B
curl -H "Host: api.contoso.com" http://$APPGW_IP/

# Test Site C
curl -H "Host: blog.contoso.com" http://$APPGW_IP/

# Or use domain names if DNS is configured
curl http://www.contoso.com/
curl http://api.contoso.com/
curl http://blog.contoso.com/
```

## Verification
```bash
# Check Application Gateway configuration
az network application-gateway show \
  --resource-group rg-appgw-multisite \
  --name appgw-multisite

# Check backend health
az network application-gateway show-backend-health \
  --resource-group rg-appgw-multisite \
  --name appgw-multisite

# List all listeners
az network application-gateway http-listener list \
  --resource-group rg-appgw-multisite \
  --gateway-name appgw-multisite
```

## Multi-Site Configuration Summary
- **www.contoso.com** → Site A Backend
- **api.contoso.com** → Site B Backend  
- **blog.contoso.com** → Site C Backend
- Each site has dedicated listeners, backend pools, and health probes
- Host-based routing using HTTP Host headers
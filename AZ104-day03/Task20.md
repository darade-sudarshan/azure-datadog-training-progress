# Task 20: Application Gateway with URL Routing

## Resource Group
```bash
az group create --name rg-appgw-routing --location eastus
```

## Virtual Network
```bash
az network vnet create \
  --resource-group rg-appgw-routing \
  --name vnet-appgw \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-appgw \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group rg-appgw-routing \
  --vnet-name vnet-appgw \
  --name subnet-backend \
  --address-prefix 10.0.2.0/24
```

## Public IP
```bash
az network public-ip create \
  --resource-group rg-appgw-routing \
  --name pip-appgw \
  --allocation-method Static \
  --sku Standard
```

## Backend VMs
```bash
# VM 1 - API Server
az vm create \
  --resource-group rg-appgw-routing \
  --name vm-api \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-api.txt

# VM 2 - Web Server
az vm create \
  --resource-group rg-appgw-routing \
  --name vm-web \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-web.txt
```

## Cloud-init Scripts
```bash
# Create cloud-init-api.txt
cat > cloud-init-api.txt << 'EOF'
#cloud-config
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/api/health
    content: |
      {"status": "healthy", "service": "api"}
  - path: /etc/nginx/sites-available/api
    content: |
      server {
        listen 80;
        location /api/ {
          root /var/www/html;
          try_files $uri $uri/ =404;
        }
      }
runcmd:
  - mkdir -p /var/www/html/api
  - ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
  - rm /etc/nginx/sites-enabled/default
  - systemctl restart nginx
EOF

# Create cloud-init-web.txt
cat > cloud-init-web.txt << 'EOF'
#cloud-config
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Web Server</h1>
  - path: /var/www/html/images/sample.html
    content: |
      <h1>Images Service</h1>
runcmd:
  - mkdir -p /var/www/html/images
  - systemctl restart nginx
EOF
```

## Application Gateway
```bash
az network application-gateway create \
  --resource-group rg-appgw-routing \
  --name appgw-routing \
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
# API Backend Pool
az network application-gateway address-pool create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name pool-api \
  --servers 10.0.2.4

# Web Backend Pool
az network application-gateway address-pool create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name pool-web \
  --servers 10.0.2.5
```

## HTTP Settings
```bash
az network application-gateway http-settings create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name http-settings-api \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

az network application-gateway http-settings create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name http-settings-web \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled
```

## URL Path Maps
```bash
az network application-gateway url-path-map create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name url-path-map \
  --paths /api/* \
  --address-pool pool-api \
  --default-address-pool pool-web \
  --default-http-settings appGatewayBackendHttpSettings \
  --http-settings http-settings-api

az network application-gateway url-path-map rule create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --path-map-name url-path-map \
  --name rule-images \
  --paths /images/* \
  --address-pool pool-web \
  --http-settings http-settings-web
```

## Routing Rule
```bash
az network application-gateway rule create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name rule-url-routing \
  --http-listener appGatewayHttpListener \
  --rule-type PathBasedRouting \
  --url-path-map url-path-map
```

## Health Probes
```bash
az network application-gateway probe create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name probe-api \
  --protocol Http \
  --host-name-from-http-settings true \
  --path /api/health

az network application-gateway probe create \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name probe-web \
  --protocol Http \
  --host-name-from-http-settings true \
  --path /
```

## Update HTTP Settings with Probes
```bash
az network application-gateway http-settings update \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name http-settings-api \
  --probe probe-api

az network application-gateway http-settings update \
  --resource-group rg-appgw-routing \
  --gateway-name appgw-routing \
  --name http-settings-web \
  --probe probe-web
```

## Test URLs
```bash
# Get Application Gateway Public IP
APPGW_IP=$(az network public-ip show \
  --resource-group rg-appgw-routing \
  --name pip-appgw \
  --query ipAddress -o tsv)

echo "Application Gateway IP: $APPGW_IP"

# Test URL routing
curl http://$APPGW_IP/          # Routes to Web Server
curl http://$APPGW_IP/api/health # Routes to API Server
curl http://$APPGW_IP/images/    # Routes to Web Server
```

## Verification
```bash
# Check Application Gateway status
az network application-gateway show \
  --resource-group rg-appgw-routing \
  --name appgw-routing

# Check backend health
az network application-gateway show-backend-health \
  --resource-group rg-appgw-routing \
  --name appgw-routing
```

## URL Routing Rules Summary
- **/** → Web Server (default)
- **/api/*** → API Server
- **/images/*** → Web Server
- Health probes monitor backend availability
# Task 20: Application Gateway with URL Routing

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

### Step 2: Create Virtual Network

1. **Navigate to Virtual Networks**
   - Search "Virtual networks" in the top search bar
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `vnet-appgw`
   - **Region**: `Southeast Asia`

3. **IP Addresses Tab**
   - **IPv4 address space**: `10.0.0.0/16`
   - Click "+ Add subnet"
   
   **Application Gateway Subnet:**
   - **Subnet name**: `subnet-appgw`
   - **Subnet address range**: `10.0.1.0/24`
   
   **Backend Subnet:**
   - **Subnet name**: `subnet-backend`
   - **Subnet address range**: `10.0.2.0/24`

4. **Review and Create**
   - Click "Review + create" → "Create"

### Step 3: Create Public IP Address

1. **Navigate to Public IP Addresses**
   - Search "Public IP addresses"
   - Click "+ Create"

2. **Configure Public IP**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `pip-appgw`
   - **Region**: `Southeast Asia`
   - **SKU**: `Standard`
   - **Assignment**: `Static`
   - Click "Review + create" → "Create"

### Step 4: Create Backend Virtual Machines

#### Create API Server VM

1. **Navigate to Virtual Machines**
   - Search "Virtual machines"
   - Click "+ Create" → "Azure virtual machine"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Virtual machine name**: `vm-api`
   - **Region**: `Southeast Asia`
   - **Image**: `Ubuntu Server 22.04 LTS`
   - **Size**: `Standard_B1s`
   - **Authentication type**: `SSH public key`
   - **Username**: `azureuser`
   - **SSH public key source**: `Generate new key pair`
   - **Key pair name**: `vm-api-key`

3. **Networking Tab**
   - **Virtual network**: `vnet-appgw`
   - **Subnet**: `subnet-backend`
   - **Public IP**: `None`

4. **Advanced Tab**
   - **Custom data**: Paste the following script:
   ```bash
   #!/bin/bash
   apt update
   apt install -y nginx
   mkdir -p /var/www/html/api
   echo '{"status": "healthy", "service": "api"}' > /var/www/html/api/health
   cat > /etc/nginx/sites-available/api << 'EOF'
   server {
     listen 80;
     location /api/ {
       root /var/www/html;
       try_files $uri $uri/ =404;
     }
   }
   EOF
   ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
   rm /etc/nginx/sites-enabled/default
   systemctl restart nginx
   ```

5. **Review and Create**
   - Click "Review + create" → "Create"
   - Download the SSH key

#### Create Web Server VM

1. **Repeat VM Creation Process**
   - **Virtual machine name**: `vm-web`
   - **Key pair name**: `vm-web-key`
   - Same networking configuration

2. **Custom Data Script**:
   ```bash
   #!/bin/bash
   apt update
   apt install -y nginx
   echo '<h1>Web Server</h1>' > /var/www/html/index.html
   mkdir -p /var/www/html/images
   echo '<h1>Images Service</h1>' > /var/www/html/images/sample.html
   systemctl restart nginx
   ```

### Step 5: Create Application Gateway

1. **Navigate to Application Gateways**
   - Search "Application gateways"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Application gateway name**: `appgw-routing`
   - **Region**: `Southeast Asia`
   - **Tier**: `Standard V2`
   - **Enable autoscaling**: `No`
   - **Instance count**: `2`
   - **Availability zone**: `None`
   - **HTTP2**: `Disabled`

3. **Frontends Tab**
   - **Frontend IP address type**: `Public`
   - **Public IP address**: `pip-appgw`

4. **Backends Tab**
   - Click "+ Add a backend pool"
   
   **API Backend Pool:**
   - **Name**: `pool-api`
   - **Add backend pool without targets**: `No`
   - **Target type**: `IP address or FQDN`
   - **Target**: `10.0.2.4` (API VM private IP)
   - Click "Add"
   
   **Web Backend Pool:**
   - **Name**: `pool-web`
   - **Target**: `10.0.2.5` (Web VM private IP)
   - Click "Add"

5. **Configuration Tab**
   - Click "+ Add a routing rule"
   
   **Basic Routing Rule:**
   - **Rule name**: `rule-url-routing`
   - **Priority**: `100`
   
   **Listener Tab:**
   - **Listener name**: `listener-http`
   - **Frontend IP**: `Public`
   - **Protocol**: `HTTP`
   - **Port**: `80`
   - **Listener type**: `Basic`
   
   **Backend targets Tab:**
   - **Target type**: `Backend pool`
   - **Backend target**: `pool-web` (default)
   - **Backend settings**: Click "Add new"
     - **Backend settings name**: `http-settings-web`
     - **Backend protocol**: `HTTP`
     - **Backend port**: `80`
     - **Cookie-based affinity**: `Disable`
     - Click "Add"
   - Click "Add"

6. **Tags Tab** (Optional)
   - Add tags if needed

7. **Review + Create**
   - Click "Review + create" → "Create"
   - Wait for deployment to complete (10-15 minutes)

### Step 6: Configure URL Path-Based Routing

1. **Navigate to Application Gateway**
   - Go to the created application gateway `appgw-routing`

2. **Create Additional Backend Settings**
   - Click "Backend settings" in the left menu
   - Click "+ Add"
   - **Name**: `http-settings-api`
   - **Backend protocol**: `HTTP`
   - **Backend port**: `80`
   - **Cookie-based affinity**: `Disable`
   - Click "Add"

3. **Create Health Probes**
   - Click "Health probes" in the left menu
   - Click "+ Add"
   
   **API Health Probe:**
   - **Name**: `probe-api`
   - **Protocol**: `HTTP`
   - **Host**: `Pick host name from backend HTTP settings`
   - **Path**: `/api/health`
   - **Interval**: `30`
   - **Timeout**: `30`
   - **Unhealthy threshold**: `3`
   - Click "Add"
   
   **Web Health Probe:**
   - **Name**: `probe-web`
   - **Protocol**: `HTTP`
   - **Host**: `Pick host name from backend HTTP settings`
   - **Path**: `/`
   - Click "Add"

4. **Update Backend Settings with Probes**
   - Go to "Backend settings"
   - Click on `http-settings-api`
   - **Custom probe**: `Yes`
   - **Custom probe**: `probe-api`
   - Click "Save"
   
   - Click on `http-settings-web`
   - **Custom probe**: `Yes`
   - **Custom probe**: `probe-web`
   - Click "Save"

5. **Create URL Path Map**
   - Click "Path-based rules" in the left menu
   - Click "+ Add path-based rule"
   - **Path map name**: `url-path-map`
   - **Associated listener**: `listener-http`
   
   **Default backend settings:**
   - **Backend pool**: `pool-web`
   - **Backend settings**: `http-settings-web`
   
   **Path-based rules:**
   - Click "+ Add path rule"
   - **Path**: `/api/*`
   - **Backend pool**: `pool-api`
   - **Backend settings**: `http-settings-api`
   - Click "Add"
   
   - Click "+ Add path rule"
   - **Path**: `/images/*`
   - **Backend pool**: `pool-web`
   - **Backend settings**: `http-settings-web`
   - Click "Add"
   
   - Click "Add" to save the path map

### Step 7: Test URL Routing

1. **Get Application Gateway Public IP**
   - Go to "Frontend IP configurations"
   - Copy the public IP address

2. **Test Different URLs**
   - Open web browser or use curl
   - Test these URLs:
     - `http://[public-ip]/` → Should route to Web Server
     - `http://[public-ip]/api/health` → Should route to API Server
     - `http://[public-ip]/images/sample.html` → Should route to Web Server

3. **Monitor Backend Health**
   - Go to "Backend health" in the left menu
   - Verify all backend pools show "Healthy" status

### Step 8: Verification and Monitoring

1. **Check Application Gateway Status**
   - Go to "Overview" tab
   - Verify operational state is "Running"
   - Check provisioning state is "Succeeded"

2. **Monitor Metrics**
   - Go to "Metrics" in the left menu
   - Add metrics like:
     - Total Requests
     - Failed Requests
     - Backend Response Status
     - Throughput

3. **View Logs**
   - Go to "Diagnostic settings"
   - Enable logging to Log Analytics workspace
   - Monitor access logs and performance logs

4. **Test Failover**
   - Stop one of the backend VMs
   - Verify traffic routes to healthy backend
   - Check backend health status

---

## Method 2: Using Azure CLI

## Resource Group
```bash
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia
```

## Virtual Network
```bash
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-appgw \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-appgw \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-appgw \
  --name subnet-backend \
  --address-prefix 10.0.2.0/24
```

## Public IP
```bash
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-appgw \
  --allocation-method Static \
  --sku Standard
```

## Backend VMs
```bash
# VM 1 - API Server
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-api \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-api.txt

# VM 2 - Web Server
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-routing \
  --location southeastasia \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name pool-api \
  --servers 10.0.2.4

# Web Backend Pool
az network application-gateway address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name pool-web \
  --servers 10.0.2.5
```

## HTTP Settings
```bash
az network application-gateway http-settings create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name http-settings-api \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

az network application-gateway http-settings create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name http-settings-web \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled
```

## URL Path Maps
```bash
az network application-gateway url-path-map create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name url-path-map \
  --paths /api/* \
  --address-pool pool-api \
  --default-address-pool pool-web \
  --default-http-settings appGatewayBackendHttpSettings \
  --http-settings http-settings-api

az network application-gateway url-path-map rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name rule-url-routing \
  --http-listener appGatewayHttpListener \
  --rule-type PathBasedRouting \
  --url-path-map url-path-map
```

## Health Probes
```bash
az network application-gateway probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name probe-api \
  --protocol Http \
  --host-name-from-http-settings true \
  --path /api/health

az network application-gateway probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name probe-web \
  --protocol Http \
  --host-name-from-http-settings true \
  --path /
```

## Update HTTP Settings with Probes
```bash
az network application-gateway http-settings update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name http-settings-api \
  --probe probe-api

az network application-gateway http-settings update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-routing \
  --name http-settings-web \
  --probe probe-web
```

## Test URLs
```bash
# Get Application Gateway Public IP
APPGW_IP=$(az network public-ip show \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-routing

# Check backend health
az network application-gateway show-backend-health \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-routing
```

## URL Routing Rules Summary
- **/** → Web Server (default)
- **/api/*** → API Server
- **/images/*** → Web Server
- Health probes monitor backend availability
# Task 21: Application Gateway - Multiple Site Implementation

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

#### Create Site A VM (www.contoso.com)

1. **Navigate to Virtual Machines**
   - Search "Virtual machines"
   - Click "+ Create" → "Azure virtual machine"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Virtual machine name**: `vm-site-a`
   - **Region**: `Southeast Asia`
   - **Image**: `Ubuntu Server 22.04 LTS`
   - **Size**: `Standard_B1s`
   - **Authentication type**: `SSH public key`
   - **Username**: `azureuser`
   - **SSH public key source**: `Generate new key pair`
   - **Key pair name**: `vm-site-a-key`

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
   echo '<h1>Welcome to Site A - www.contoso.com</h1><p>This is the main corporate website</p>' > /var/www/html/index.html
   systemctl restart nginx
   ```

5. **Review and Create**
   - Click "Review + create" → "Create"
   - Download the SSH key

#### Create Site B VM (api.contoso.com)

1. **Repeat VM Creation Process**
   - **Virtual machine name**: `vm-site-b`
   - **Key pair name**: `vm-site-b-key`
   - Same networking configuration

2. **Custom Data Script**:
   ```bash
   #!/bin/bash
   apt update
   apt install -y nginx
   echo '<h1>Welcome to Site B - api.contoso.com</h1><p>This is the API service website</p>' > /var/www/html/index.html
   systemctl restart nginx
   ```

#### Create Site C VM (blog.contoso.com)

1. **Repeat VM Creation Process**
   - **Virtual machine name**: `vm-site-c`
   - **Key pair name**: `vm-site-c-key`
   - Same networking configuration

2. **Custom Data Script**:
   ```bash
   #!/bin/bash
   apt update
   apt install -y nginx
   echo '<h1>Welcome to Site C - blog.contoso.com</h1><p>This is the blog website</p>' > /var/www/html/index.html
   systemctl restart nginx
   ```

### Step 5: Create Application Gateway

1. **Navigate to Application Gateways**
   - Search "Application gateways"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Application gateway name**: `appgw-multisite`
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
   
   **Site A Backend Pool:**
   - **Name**: `pool-site-a`
   - **Add backend pool without targets**: `No`
   - **Target type**: `IP address or FQDN`
   - **Target**: `10.0.2.4` (Site A VM private IP)
   - Click "Add"
   
   **Site B Backend Pool:**
   - **Name**: `pool-site-b`
   - **Target**: `10.0.2.5` (Site B VM private IP)
   - Click "Add"
   
   **Site C Backend Pool:**
   - **Name**: `pool-site-c`
   - **Target**: `10.0.2.6` (Site C VM private IP)
   - Click "Add"

5. **Configuration Tab**
   - Click "+ Add a routing rule"
   
   **Site A Routing Rule:**
   - **Rule name**: `rule-site-a`
   - **Priority**: `100`
   
   **Listener Tab:**
   - **Listener name**: `listener-site-a`
   - **Frontend IP**: `Public`
   - **Protocol**: `HTTP`
   - **Port**: `80`
   - **Listener type**: `Multi site`
   - **Host type**: `Single`
   - **Host name**: `www.contoso.com`
   
   **Backend targets Tab:**
   - **Target type**: `Backend pool`
   - **Backend target**: `pool-site-a`
   - **Backend settings**: Click "Add new"
     - **Backend settings name**: `http-settings-site-a`
     - **Backend protocol**: `HTTP`
     - **Backend port**: `80`
     - **Cookie-based affinity**: `Disable`
     - Click "Add"
   - Click "Add"

6. **Add Additional Routing Rules**
   - Repeat for Site B and Site C with respective hostnames:
     - `api.contoso.com` for Site B
     - `blog.contoso.com` for Site C

7. **Review + Create**
   - Click "Review + create" → "Create"
   - Wait for deployment to complete (10-15 minutes)

### Step 6: Configure Health Probes

1. **Navigate to Application Gateway**
   - Go to the created application gateway `appgw-multisite`

2. **Create Health Probes**
   - Click "Health probes" in the left menu
   - Click "+ Add"
   
   **Site A Health Probe:**
   - **Name**: `probe-site-a`
   - **Protocol**: `HTTP`
   - **Host**: `www.contoso.com`
   - **Path**: `/`
   - **Interval**: `30`
   - **Timeout**: `30`
   - **Unhealthy threshold**: `3`
   - Click "Add"
   
   **Site B Health Probe:**
   - **Name**: `probe-site-b`
   - **Host**: `api.contoso.com`
   - **Path**: `/`
   - Click "Add"
   
   **Site C Health Probe:**
   - **Name**: `probe-site-c`
   - **Host**: `blog.contoso.com`
   - **Path**: `/`
   - Click "Add"

3. **Update Backend Settings with Probes**
   - Go to "Backend settings"
   - Click on `http-settings-site-a`
   - **Custom probe**: `Yes`
   - **Custom probe**: `probe-site-a`
   - Click "Save"
   
   - Repeat for Site B and Site C backend settings

### Step 7: Configure DNS for Testing

1. **Get Application Gateway Public IP**
   - Go to "Frontend IP configurations"
   - Copy the public IP address

2. **Configure Local DNS (for testing)**
   - On your local machine, edit hosts file:
   
   **Windows**: `C:\Windows\System32\drivers\etc\hosts`
   **Linux/Mac**: `/etc/hosts`
   
   Add these entries:
   ```
   [public-ip] www.contoso.com
   [public-ip] api.contoso.com
   [public-ip] blog.contoso.com
   ```

### Step 8: Test Multiple Sites

1. **Test Using Web Browser**
   - Open web browser
   - Navigate to:
     - `http://www.contoso.com` → Should show Site A
     - `http://api.contoso.com` → Should show Site B
     - `http://blog.contoso.com` → Should show Site C

2. **Test Using Command Line**
   ```bash
   # Test with Host headers
   curl -H "Host: www.contoso.com" http://[public-ip]/
   curl -H "Host: api.contoso.com" http://[public-ip]/
   curl -H "Host: blog.contoso.com" http://[public-ip]/
   ```

### Step 9: Monitor and Verify

1. **Check Backend Health**
   - Go to "Backend health" in the left menu
   - Verify all backend pools show "Healthy" status
   - Check that each site's backend is responding correctly

2. **View Listeners**
   - Go to "Listeners" in the left menu
   - Verify all three listeners are configured:
     - `listener-site-a` with hostname `www.contoso.com`
     - `listener-site-b` with hostname `api.contoso.com`
     - `listener-site-c` with hostname `blog.contoso.com`

3. **Check Routing Rules**
   - Go to "Rules" in the left menu
   - Verify each rule maps correct listener to backend pool

4. **Monitor Metrics**
   - Go to "Metrics" in the left menu
   - Add metrics like:
     - Total Requests
     - Failed Requests
     - Backend Response Status
     - Requests per minute by listener

### Step 10: Advanced Configuration (Optional)

1. **SSL Termination**
   - Upload SSL certificates for each domain
   - Configure HTTPS listeners
   - Update routing rules for HTTPS

2. **Custom Error Pages**
   - Configure custom error pages for each site
   - Set up maintenance pages

3. **WAF Integration**
   - Enable Web Application Firewall
   - Configure WAF policies per site

4. **Autoscaling**
   - Enable autoscaling based on metrics
   - Set minimum and maximum instance counts

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

## Public IPs
```bash
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-appgw \
  --allocation-method Static \
  --sku Standard
```

## Backend VMs
```bash
# Site A VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-site-a \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-site-a.txt

# Site B VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-site-b \
  --image Ubuntu2204 \
  --vnet-name vnet-appgw \
  --subnet subnet-backend \
  --admin-username azureuser \
  --generate-ssh-keys \
  --custom-data cloud-init-site-b.txt

# Site C VM
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-multisite \
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
# Site A Backend Pool
az network application-gateway address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name pool-site-a \
  --servers 10.0.2.4

# Site B Backend Pool
az network application-gateway address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name pool-site-b \
  --servers 10.0.2.5

# Site C Backend Pool
az network application-gateway address-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name pool-site-c \
  --servers 10.0.2.6
```

## HTTP Settings
```bash
az network application-gateway http-settings create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name http-settings-site-a \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

az network application-gateway http-settings create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name http-settings-site-b \
  --port 80 \
  --protocol Http \
  --cookie-based-affinity Disabled

az network application-gateway http-settings create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name listener-site-a \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port appGatewayFrontendPort \
  --host-name www.contoso.com

# Site B Listener
az network application-gateway http-listener create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name listener-site-b \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port appGatewayFrontendPort \
  --host-name api.contoso.com

# Site C Listener
az network application-gateway http-listener create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name rule-site-a \
  --http-listener listener-site-a \
  --rule-type Basic \
  --address-pool pool-site-a \
  --http-settings http-settings-site-a

# Site B Rule
az network application-gateway rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name rule-site-b \
  --http-listener listener-site-b \
  --rule-type Basic \
  --address-pool pool-site-b \
  --http-settings http-settings-site-b

# Site C Rule
az network application-gateway rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name probe-site-a \
  --protocol Http \
  --host-name www.contoso.com \
  --path /

az network application-gateway probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name probe-site-b \
  --protocol Http \
  --host-name api.contoso.com \
  --path /

az network application-gateway probe create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name probe-site-c \
  --protocol Http \
  --host-name blog.contoso.com \
  --path /
```

## Update HTTP Settings with Probes
```bash
az network application-gateway http-settings update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name http-settings-site-a \
  --probe probe-site-a

az network application-gateway http-settings update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name http-settings-site-b \
  --probe probe-site-b

az network application-gateway http-settings update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite \
  --name http-settings-site-c \
  --probe probe-site-c
```

## DNS Configuration (Local Testing)
```bash
# Get Application Gateway Public IP
APPGW_IP=$(az network public-ip show \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-multisite

# Check backend health
az network application-gateway show-backend-health \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-multisite

# List all listeners
az network application-gateway http-listener list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gateway-name appgw-multisite
```

## Multi-Site Configuration Summary
- **www.contoso.com** → Site A Backend
- **api.contoso.com** → Site B Backend  
- **blog.contoso.com** → Site C Backend
- Each site has dedicated listeners, backend pools, and health probes
- Host-based routing using HTTP Host headers
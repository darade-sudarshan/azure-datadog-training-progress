# Task 23: Azure Web App Integration in 3-Tier Architecture

## Architecture Overview
3-tier architecture using Azure Web Apps with VNet integration, private endpoints, and database connectivity.

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
   - **Name**: `vnet-3tier`
   - **Region**: `Southeast Asia`

3. **IP Addresses Tab**
   - **IPv4 address space**: `10.0.0.0/16`
   - Click "+ Add subnet" for each tier:
   
   **Web Tier Subnet:**
   - **Subnet name**: `subnet-web`
   - **Subnet address range**: `10.0.1.0/24`
   
   **App Tier Subnet:**
   - **Subnet name**: `subnet-app`
   - **Subnet address range**: `10.0.2.0/24`
   
   **DB Tier Subnet:**
   - **Subnet name**: `subnet-db`
   - **Subnet address range**: `10.0.3.0/24`
   
   **Integration Subnet:**
   - **Subnet name**: `subnet-integration`
   - **Subnet address range**: `10.0.4.0/24`

4. **Review and Create**
   - Click "Review + create" → "Create"

### Step 3: Create App Service Plans

#### Create Web Tier App Service Plan

1. **Navigate to App Service Plans**
   - Search "App Service plans"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `plan-web`
   - **Operating System**: `Linux`
   - **Region**: `Southeast Asia`

3. **Pricing Tier**
   - **Sku and size**: `Premium V2 P1V2`
   - Click "Review + create" → "Create"

#### Create App Tier App Service Plan

1. **Repeat App Service Plan Creation**
   - **Name**: `plan-app`
   - Same configuration as above

### Step 4: Create Azure SQL Database

1. **Navigate to SQL Databases**
   - Search "SQL databases"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Database name**: `database-3tier`
   - **Server**: Click "Create new"
     - **Server name**: `sqlserver-3tier-[unique-suffix]`
     - **Location**: `Southeast Asia`
     - **Authentication method**: `Use SQL authentication`
     - **Server admin login**: `sqladmin`
     - **Password**: `P@ssw0rd123!`
     - Click "OK"

3. **Compute + Storage**
   - **Service tier**: `Standard`
   - **Compute tier**: `Provisioned`
   - **Service objective**: `S1`

4. **Networking Tab**
   - **Connectivity method**: `Private endpoint`
   - **Private endpoint**: Configure later

5. **Review and Create**
   - Click "Review + create" → "Create"

### Step 5: Create Web Apps

#### Create Frontend Web App

1. **Navigate to App Services**
   - Search "App Services"
   - Click "+ Create"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `webapp-frontend-[unique-suffix]`
   - **Publish**: `Code`
   - **Runtime stack**: `Node 18 LTS`
   - **Operating System**: `Linux`
   - **Region**: `Southeast Asia`
   - **App Service Plan**: `plan-web`

3. **Review and Create**
   - Click "Review + create" → "Create"

#### Create API Web App

1. **Repeat Web App Creation**
   - **Name**: `webapp-api-[unique-suffix]`
   - **Runtime stack**: `Node 18 LTS`
   - **App Service Plan**: `plan-app`

#### Create Business Logic Web App

1. **Repeat Web App Creation**
   - **Name**: `webapp-business-[unique-suffix]`
   - **Runtime stack**: `.NET 6 (LTS)`
   - **App Service Plan**: `plan-app`

### Step 6: Configure VNet Integration

1. **Navigate to Frontend Web App**
   - Go to `webapp-frontend-[unique-suffix]`
   - Click "Networking" in the left menu
   - Click "VNet integration"

2. **Add VNet Integration**
   - Click "+ Add VNet"
   - **Virtual Network**: `vnet-3tier`
   - **Subnet**: `subnet-integration`
   - Click "OK"

3. **Repeat for Other Web Apps**
   - Configure VNet integration for API and Business web apps
   - Use the same subnet `subnet-integration`

### Step 7: Create Private Endpoints

#### Create Private Endpoint for SQL Database

1. **Navigate to SQL Server**
   - Go to the created SQL server
   - Click "Private endpoint connections" in the left menu
   - Click "+ Private endpoint"

2. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `pe-sql`
   - **Region**: `Southeast Asia`

3. **Resource Tab**
   - **Connection method**: `Connect to an Azure resource in my directory`
   - **Resource type**: `Microsoft.Sql/servers`
   - **Resource**: Select your SQL server
   - **Target sub-resource**: `sqlServer`

4. **Virtual Network Tab**
   - **Virtual network**: `vnet-3tier`
   - **Subnet**: `subnet-db`
   - **Private IP configuration**: `Dynamically allocate IP address`

5. **DNS Tab**
   - **Integrate with private DNS zone**: `Yes`
   - **Private DNS zone**: `privatelink.database.windows.net`

6. **Review and Create**
   - Click "Review + create" → "Create"

#### Create Private Endpoints for Web Apps

1. **Navigate to API Web App**
   - Go to `webapp-api-[unique-suffix]`
   - Click "Networking" in the left menu
   - Click "Private endpoints"
   - Click "+ Add"

2. **Configure Private Endpoint**
   - **Name**: `pe-api`
   - **Virtual network**: `vnet-3tier`
   - **Subnet**: `subnet-app`
   - **Integrate with private DNS zone**: `Yes`
   - Click "OK"

3. **Repeat for Business Web App**
   - **Name**: `pe-business`
   - Same configuration

### Step 8: Create Application Gateway

1. **Create Public IP**
   - Search "Public IP addresses"
   - Click "+ Create"
   - **Name**: `pip-appgw`
   - **SKU**: `Standard`
   - **Assignment**: `Static`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - Click "Create"

2. **Navigate to Application Gateways**
   - Search "Application gateways"
   - Click "+ Create"

3. **Basics Tab**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Application gateway name**: `appgw-3tier`
   - **Region**: `Southeast Asia`
   - **Tier**: `Standard V2`
   - **Instance count**: `2`

4. **Frontends Tab**
   - **Frontend IP address type**: `Public`
   - **Public IP address**: `pip-appgw`

5. **Backends Tab**
   - Click "+ Add a backend pool"
   - **Name**: `pool-frontend`
   - **Target type**: `App Service`
   - **Target**: Select your frontend web app
   - Click "Add"

6. **Configuration Tab**
   - Click "+ Add a routing rule"
   - **Rule name**: `rule-frontend`
   - **Priority**: `100`
   - **Listener**: Configure HTTP listener on port 80
   - **Backend targets**: `pool-frontend`
   - Click "Add"

7. **Review and Create**
   - Click "Review + create" → "Create"

### Step 9: Configure Application Settings

#### Configure Frontend Web App

1. **Navigate to Frontend Web App**
   - Go to `webapp-frontend-[unique-suffix]`
   - Click "Configuration" in the left menu
   - Click "+ New application setting"

2. **Add API URL Setting**
   - **Name**: `API_URL`
   - **Value**: `https://webapp-api-[unique-suffix].azurewebsites.net`
   - Click "OK"
   - Click "Save"

#### Configure API Web App

1. **Navigate to API Web App**
   - Go to `webapp-api-[unique-suffix]`
   - Click "Configuration" in the left menu

2. **Add Connection String**
   - Click "+ New connection string"
   - **Name**: `DefaultConnection`
   - **Value**: `Server=tcp:sqlserver-3tier-[suffix].database.windows.net,1433;Database=database-3tier;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;`
   - **Type**: `SQLAzure`
   - Click "OK"

3. **Add Business URL Setting**
   - **Name**: `BUSINESS_URL`
   - **Value**: `https://webapp-business-[unique-suffix].azurewebsites.net`
   - Click "Save"

#### Configure Business Web App

1. **Add Connection String**
   - Same SQL connection string as API web app
   - Click "Save"

### Step 10: Create Network Security Groups

1. **Create Web Tier NSG**
   - Search "Network security groups"
   - Click "+ Create"
   - **Name**: `nsg-web`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - Add rules for HTTP (80) and HTTPS (443)

2. **Create App Tier NSG**
   - **Name**: `nsg-app`
   - Add rules for HTTPS (443) from web tier subnet

3. **Create DB Tier NSG**
   - **Name**: `nsg-db`
   - Add rules for SQL (1433) from app tier subnet

4. **Associate NSGs with Subnets**
   - Go to each subnet in the VNet
   - Associate appropriate NSG

### Step 11: Deploy Sample Applications

1. **Create Sample Frontend Code**
   ```javascript
   // package.json
   {
     "name": "frontend",
     "version": "1.0.0",
     "main": "app.js",
     "dependencies": {
       "express": "^4.18.0"
     },
     "scripts": {
       "start": "node app.js"
     }
   }
   
   // app.js
   const express = require('express');
   const app = express();
   
   app.get('/', (req, res) => {
     res.send(`
       <h1>3-Tier Web Application</h1>
       <p>Frontend Tier - Presentation Layer</p>
       <button onclick="callAPI()">Call API</button>
       <script>
         async function callAPI() {
           const response = await fetch('${process.env.API_URL}/api/data');
           const data = await response.text();
           alert(data);
         }
       </script>
     `);
   });
   
   app.listen(process.env.PORT || 3000);
   ```

2. **Deploy Using VS Code or ZIP**
   - Use VS Code Azure extension
   - Or create ZIP file and upload via Portal
   - Go to web app → "Deployment Center"
   - Configure deployment source

### Step 12: Configure Monitoring

1. **Create Application Insights**
   - Search "Application Insights"
   - Click "+ Create"
   - **Name**: `webapp-insights`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Application Type**: `Web`

2. **Configure Web Apps**
   - Go to each web app
   - Click "Application Insights" in the left menu
   - Click "Turn on Application Insights"
   - Select the created Application Insights resource

### Step 13: Test the Application

1. **Get Application Gateway Public IP**
   - Go to Application Gateway
   - Copy the frontend IP address

2. **Test Access**
   - Open web browser
   - Navigate to `http://[appgw-public-ip]`
   - Test the frontend application
   - Verify API calls work through the tiers

3. **Monitor Performance**
   - Go to Application Insights
   - View application map
   - Check performance metrics
   - Review dependency calls

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
  --name vnet-3tier \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-app \
  --address-prefix 10.0.2.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-db \
  --address-prefix 10.0.3.0/24

az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-integration \
  --address-prefix 10.0.4.0/24
```

## App Service Plans
```bash
# Web Tier App Service Plan
az appservice plan create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name plan-web \
  --sku P1V2 \
  --is-linux

# App Tier App Service Plan
az appservice plan create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name plan-app \
  --sku P1V2 \
  --is-linux
```

## Web Apps - Presentation Tier
```bash
# Frontend Web App
az webapp create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --plan plan-web \
  --name webapp-frontend-${RANDOM} \
  --runtime "NODE|18-lts"

# Store web app name
FRONTEND_APP=$(az webapp list --resource-group sa1_test_eic_SudarshanDarade --query "[?contains(name,'frontend')].name" -o tsv)
```

## Web Apps - Application Tier
```bash
# API Web App
az webapp create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --plan plan-app \
  --name webapp-api-${RANDOM} \
  --runtime "NODE|18-lts"

# Business Logic Web App
az webapp create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --plan plan-app \
  --name webapp-business-${RANDOM} \
  --runtime "DOTNETCORE|6.0"

# Store app names
API_APP=$(az webapp list --resource-group sa1_test_eic_SudarshanDarade --query "[?contains(name,'api')].name" -o tsv)
BUSINESS_APP=$(az webapp list --resource-group sa1_test_eic_SudarshanDarade --query "[?contains(name,'business')].name" -o tsv)
```

## Database Tier - Azure SQL
```bash
# SQL Server
az sql server create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sqlserver-3tier-${RANDOM} \
  --admin-user sqladmin \
  --admin-password 'P@ssw0rd123!'

# SQL Database
az sql db create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sqlserver-3tier-${RANDOM} \
  --name database-3tier \
  --service-objective S1

# Store server name
SQL_SERVER=$(az sql server list --resource-group sa1_test_eic_SudarshanDarade --query "[0].name" -o tsv)
```

## VNet Integration
```bash
# Enable VNet integration for web apps
az webapp vnet-integration add \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $FRONTEND_APP \
  --vnet vnet-3tier \
  --subnet subnet-integration

az webapp vnet-integration add \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $API_APP \
  --vnet vnet-3tier \
  --subnet subnet-integration

az webapp vnet-integration add \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $BUSINESS_APP \
  --vnet vnet-3tier \
  --subnet subnet-integration
```

## Private Endpoints
```bash
# Private endpoint for SQL Server
az network private-endpoint create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pe-sql \
  --vnet-name vnet-3tier \
  --subnet subnet-db \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/$SQL_SERVER" \
  --group-id sqlServer \
  --connection-name sql-connection

# Private endpoint for API Web App
az network private-endpoint create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pe-api \
  --vnet-name vnet-3tier \
  --subnet subnet-app \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Web/sites/$API_APP" \
  --group-id sites \
  --connection-name api-connection

# Private endpoint for Business Web App
az network private-endpoint create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pe-business \
  --vnet-name vnet-3tier \
  --subnet subnet-app \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Web/sites/$BUSINESS_APP" \
  --group-id sites \
  --connection-name business-connection
```

## Private DNS Zones
```bash
# Private DNS for Web Apps
az network private-dns zone create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name privatelink.azurewebsites.net

az network private-dns link vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name privatelink.azurewebsites.net \
  --name link-webapp \
  --virtual-network vnet-3tier \
  --registration-enabled false

# Private DNS for SQL
az network private-dns zone create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name privatelink.database.windows.net

az network private-dns link vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --zone-name privatelink.database.windows.net \
  --name link-sql \
  --virtual-network vnet-3tier \
  --registration-enabled false
```

## Application Gateway
```bash
# Public IP for Application Gateway
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-appgw \
  --sku Standard \
  --allocation-method Static

# Application Gateway
az network application-gateway create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name appgw-3tier \
  --location southeastasia \
  --vnet-name vnet-3tier \
  --subnet subnet-web \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address pip-appgw \
  --servers $FRONTEND_APP.azurewebsites.net
```

## App Configuration
```bash
# Configure connection strings
az webapp config connection-string set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $API_APP \
  --connection-string-type SQLAzure \
  --settings DefaultConnection="Server=tcp:$SQL_SERVER.database.windows.net,1433;Database=database-3tier;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;"

az webapp config connection-string set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $BUSINESS_APP \
  --connection-string-type SQLAzure \
  --settings DefaultConnection="Server=tcp:$SQL_SERVER.database.windows.net,1433;Database=database-3tier;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;"

# Configure app settings
az webapp config appsettings set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $FRONTEND_APP \
  --settings API_URL="https://$API_APP.azurewebsites.net"

az webapp config appsettings set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $API_APP \
  --settings BUSINESS_URL="https://$BUSINESS_APP.azurewebsites.net"
```

## Network Security Groups
```bash
# Web tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-web

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-web \
  --name allow-http \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 80 443

# App tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-app

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-app \
  --name allow-webapp \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 443 \
  --source-address-prefixes 10.0.1.0/24

# DB tier NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-db

az network nsg rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --nsg-name nsg-db \
  --name allow-sql \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 1433 \
  --source-address-prefixes 10.0.2.0/24

# Associate NSGs
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-web \
  --network-security-group nsg-web

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-app \
  --network-security-group nsg-app

az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-3tier \
  --name subnet-db \
  --network-security-group nsg-db
```

## Sample Application Code

### Frontend (Node.js)
```javascript
// app.js
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send(`
    <h1>3-Tier Web Application</h1>
    <p>Frontend Tier - Presentation Layer</p>
    <button onclick="callAPI()">Call API</button>
    <script>
      async function callAPI() {
        const response = await fetch('${process.env.API_URL}/api/data');
        const data = await response.text();
        alert(data);
      }
    </script>
  `);
});

app.listen(process.env.PORT || 3000);
```

### API Layer (Node.js)
```javascript
// server.js
const express = require('express');
const app = express();

app.get('/api/data', async (req, res) => {
  try {
    const businessResponse = await fetch(`${process.env.BUSINESS_URL}/business/process`);
    const data = await businessResponse.text();
    res.json({ message: 'API Layer Response', data: data });
  } catch (error) {
    res.status(500).json({ error: 'API Error' });
  }
});

app.listen(process.env.PORT || 3000);
```

## Deployment
```bash
# Deploy sample code (assuming code is in local directories)
az webapp deployment source config-zip \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $FRONTEND_APP \
  --src frontend.zip

az webapp deployment source config-zip \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $API_APP \
  --src api.zip

az webapp deployment source config-zip \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $BUSINESS_APP \
  --src business.zip
```

## Monitoring and Diagnostics
```bash
# Enable Application Insights
az monitor app-insights component create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --app webapp-insights \
  --location southeastasia \
  --application-type web

# Configure web apps to use Application Insights
INSIGHTS_KEY=$(az monitor app-insights component show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --app webapp-insights \
  --query instrumentationKey -o tsv)

az webapp config appsettings set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $FRONTEND_APP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSIGHTS_KEY

az webapp config appsettings set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name $API_APP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSIGHTS_KEY
```

## Testing
```bash
# Get Application Gateway public IP
APPGW_IP=$(az network public-ip show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-appgw \
  --query ipAddress -o tsv)

echo "Access application at: http://$APPGW_IP"

# Test direct web app access
echo "Frontend: https://$FRONTEND_APP.azurewebsites.net"
echo "API: https://$API_APP.azurewebsites.net"
echo "Business: https://$BUSINESS_APP.azurewebsites.net"
```

## Architecture Summary
- **Presentation Tier**: Frontend Web App with Application Gateway
- **Application Tier**: API and Business Logic Web Apps with private endpoints
- **Data Tier**: Azure SQL Database with private endpoint
- **Network**: VNet integration, private endpoints, NSGs
- **Security**: Private DNS zones, network isolation
- **Monitoring**: Application Insights integration
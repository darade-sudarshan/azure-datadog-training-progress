# Task 23: Azure Web App Integration in 3-Tier Architecture

## Architecture Overview
3-tier architecture using Azure Web Apps with VNet integration, private endpoints, and database connectivity.

## Resource Group
```bash
az group create --name rg-webapp-3tier --location eastus
```

## Virtual Network
```bash
az network vnet create \
  --resource-group rg-webapp-3tier \
  --name vnet-3tier \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group rg-webapp-3tier \
  --vnet-name vnet-3tier \
  --name subnet-app \
  --address-prefix 10.0.2.0/24

az network vnet subnet create \
  --resource-group rg-webapp-3tier \
  --vnet-name vnet-3tier \
  --name subnet-db \
  --address-prefix 10.0.3.0/24

az network vnet subnet create \
  --resource-group rg-webapp-3tier \
  --vnet-name vnet-3tier \
  --name subnet-integration \
  --address-prefix 10.0.4.0/24
```

## App Service Plans
```bash
# Web Tier App Service Plan
az appservice plan create \
  --resource-group rg-webapp-3tier \
  --name plan-web \
  --sku P1V2 \
  --is-linux

# App Tier App Service Plan
az appservice plan create \
  --resource-group rg-webapp-3tier \
  --name plan-app \
  --sku P1V2 \
  --is-linux
```

## Web Apps - Presentation Tier
```bash
# Frontend Web App
az webapp create \
  --resource-group rg-webapp-3tier \
  --plan plan-web \
  --name webapp-frontend-${RANDOM} \
  --runtime "NODE|18-lts"

# Store web app name
FRONTEND_APP=$(az webapp list --resource-group rg-webapp-3tier --query "[?contains(name,'frontend')].name" -o tsv)
```

## Web Apps - Application Tier
```bash
# API Web App
az webapp create \
  --resource-group rg-webapp-3tier \
  --plan plan-app \
  --name webapp-api-${RANDOM} \
  --runtime "NODE|18-lts"

# Business Logic Web App
az webapp create \
  --resource-group rg-webapp-3tier \
  --plan plan-app \
  --name webapp-business-${RANDOM} \
  --runtime "DOTNETCORE|6.0"

# Store app names
API_APP=$(az webapp list --resource-group rg-webapp-3tier --query "[?contains(name,'api')].name" -o tsv)
BUSINESS_APP=$(az webapp list --resource-group rg-webapp-3tier --query "[?contains(name,'business')].name" -o tsv)
```

## Database Tier - Azure SQL
```bash
# SQL Server
az sql server create \
  --resource-group rg-webapp-3tier \
  --name sqlserver-3tier-${RANDOM} \
  --admin-user sqladmin \
  --admin-password 'P@ssw0rd123!'

# SQL Database
az sql db create \
  --resource-group rg-webapp-3tier \
  --server sqlserver-3tier-${RANDOM} \
  --name database-3tier \
  --service-objective S1

# Store server name
SQL_SERVER=$(az sql server list --resource-group rg-webapp-3tier --query "[0].name" -o tsv)
```

## VNet Integration
```bash
# Enable VNet integration for web apps
az webapp vnet-integration add \
  --resource-group rg-webapp-3tier \
  --name $FRONTEND_APP \
  --vnet vnet-3tier \
  --subnet subnet-integration

az webapp vnet-integration add \
  --resource-group rg-webapp-3tier \
  --name $API_APP \
  --vnet vnet-3tier \
  --subnet subnet-integration

az webapp vnet-integration add \
  --resource-group rg-webapp-3tier \
  --name $BUSINESS_APP \
  --vnet vnet-3tier \
  --subnet subnet-integration
```

## Private Endpoints
```bash
# Private endpoint for SQL Server
az network private-endpoint create \
  --resource-group rg-webapp-3tier \
  --name pe-sql \
  --vnet-name vnet-3tier \
  --subnet subnet-db \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-webapp-3tier/providers/Microsoft.Sql/servers/$SQL_SERVER" \
  --group-id sqlServer \
  --connection-name sql-connection

# Private endpoint for API Web App
az network private-endpoint create \
  --resource-group rg-webapp-3tier \
  --name pe-api \
  --vnet-name vnet-3tier \
  --subnet subnet-app \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-webapp-3tier/providers/Microsoft.Web/sites/$API_APP" \
  --group-id sites \
  --connection-name api-connection

# Private endpoint for Business Web App
az network private-endpoint create \
  --resource-group rg-webapp-3tier \
  --name pe-business \
  --vnet-name vnet-3tier \
  --subnet subnet-app \
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/rg-webapp-3tier/providers/Microsoft.Web/sites/$BUSINESS_APP" \
  --group-id sites \
  --connection-name business-connection
```

## Private DNS Zones
```bash
# Private DNS for Web Apps
az network private-dns zone create \
  --resource-group rg-webapp-3tier \
  --name privatelink.azurewebsites.net

az network private-dns link vnet create \
  --resource-group rg-webapp-3tier \
  --zone-name privatelink.azurewebsites.net \
  --name link-webapp \
  --virtual-network vnet-3tier \
  --registration-enabled false

# Private DNS for SQL
az network private-dns zone create \
  --resource-group rg-webapp-3tier \
  --name privatelink.database.windows.net

az network private-dns link vnet create \
  --resource-group rg-webapp-3tier \
  --zone-name privatelink.database.windows.net \
  --name link-sql \
  --virtual-network vnet-3tier \
  --registration-enabled false
```

## Application Gateway
```bash
# Public IP for Application Gateway
az network public-ip create \
  --resource-group rg-webapp-3tier \
  --name pip-appgw \
  --sku Standard \
  --allocation-method Static

# Application Gateway
az network application-gateway create \
  --resource-group rg-webapp-3tier \
  --name appgw-3tier \
  --location eastus \
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
  --resource-group rg-webapp-3tier \
  --name $API_APP \
  --connection-string-type SQLAzure \
  --settings DefaultConnection="Server=tcp:$SQL_SERVER.database.windows.net,1433;Database=database-3tier;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;"

az webapp config connection-string set \
  --resource-group rg-webapp-3tier \
  --name $BUSINESS_APP \
  --connection-string-type SQLAzure \
  --settings DefaultConnection="Server=tcp:$SQL_SERVER.database.windows.net,1433;Database=database-3tier;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;"

# Configure app settings
az webapp config appsettings set \
  --resource-group rg-webapp-3tier \
  --name $FRONTEND_APP \
  --settings API_URL="https://$API_APP.azurewebsites.net"

az webapp config appsettings set \
  --resource-group rg-webapp-3tier \
  --name $API_APP \
  --settings BUSINESS_URL="https://$BUSINESS_APP.azurewebsites.net"
```

## Network Security Groups
```bash
# Web tier NSG
az network nsg create \
  --resource-group rg-webapp-3tier \
  --name nsg-web

az network nsg rule create \
  --resource-group rg-webapp-3tier \
  --nsg-name nsg-web \
  --name allow-http \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 80 443

# App tier NSG
az network nsg create \
  --resource-group rg-webapp-3tier \
  --name nsg-app

az network nsg rule create \
  --resource-group rg-webapp-3tier \
  --nsg-name nsg-app \
  --name allow-webapp \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 443 \
  --source-address-prefixes 10.0.1.0/24

# DB tier NSG
az network nsg create \
  --resource-group rg-webapp-3tier \
  --name nsg-db

az network nsg rule create \
  --resource-group rg-webapp-3tier \
  --nsg-name nsg-db \
  --name allow-sql \
  --priority 100 \
  --protocol Tcp \
  --destination-port-ranges 1433 \
  --source-address-prefixes 10.0.2.0/24

# Associate NSGs
az network vnet subnet update \
  --resource-group rg-webapp-3tier \
  --vnet-name vnet-3tier \
  --name subnet-web \
  --network-security-group nsg-web

az network vnet subnet update \
  --resource-group rg-webapp-3tier \
  --vnet-name vnet-3tier \
  --name subnet-app \
  --network-security-group nsg-app

az network vnet subnet update \
  --resource-group rg-webapp-3tier \
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
  --resource-group rg-webapp-3tier \
  --name $FRONTEND_APP \
  --src frontend.zip

az webapp deployment source config-zip \
  --resource-group rg-webapp-3tier \
  --name $API_APP \
  --src api.zip

az webapp deployment source config-zip \
  --resource-group rg-webapp-3tier \
  --name $BUSINESS_APP \
  --src business.zip
```

## Monitoring and Diagnostics
```bash
# Enable Application Insights
az monitor app-insights component create \
  --resource-group rg-webapp-3tier \
  --app webapp-insights \
  --location eastus \
  --application-type web

# Configure web apps to use Application Insights
INSIGHTS_KEY=$(az monitor app-insights component show \
  --resource-group rg-webapp-3tier \
  --app webapp-insights \
  --query instrumentationKey -o tsv)

az webapp config appsettings set \
  --resource-group rg-webapp-3tier \
  --name $FRONTEND_APP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSIGHTS_KEY

az webapp config appsettings set \
  --resource-group rg-webapp-3tier \
  --name $API_APP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSIGHTS_KEY
```

## Testing
```bash
# Get Application Gateway public IP
APPGW_IP=$(az network public-ip show \
  --resource-group rg-webapp-3tier \
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
# Azure Web App with App Service Plan and Deployment Slots

This guide covers creating and managing Azure Web Apps with App Service Plans and deployment slots for staging and production environments.

## Understanding Azure Web App Components

### Azure Web App
- **Definition**: Platform-as-a-Service (PaaS) offering for hosting web applications
- **Supported Languages**: .NET, Java, Node.js, Python, PHP, Ruby
- **Features**: Auto-scaling, SSL certificates, custom domains, CI/CD integration
- **Benefits**: No infrastructure management, built-in monitoring, high availability

### App Service Plan
- **Definition**: Defines compute resources for web apps (CPU, memory, storage)
- **Pricing Tiers**: Free, Shared, Basic, Standard, Premium, Isolated
- **Scaling**: Manual and automatic scaling options
- **Resource Sharing**: Multiple web apps can share the same plan

### Deployment Slots
- **Definition**: Live apps with their own hostnames running different versions
- **Purpose**: Blue-green deployments, A/B testing, staging environments
- **Features**: Traffic routing, slot swapping, configuration management
- **Availability**: Standard, Premium, and Isolated tiers only

### Pricing Tiers Comparison

| Tier | CPU | Memory | Storage | Custom Domains | SSL | Deployment Slots |
|------|-----|--------|---------|----------------|-----|------------------|
| Free | Shared | 1 GB | 1 GB | No | No | No |
| Basic | Dedicated | 1.75 GB | 10 GB | Yes | Yes | No |
| Standard | Dedicated | 3.5 GB | 50 GB | Yes | Yes | 5 |
| Premium | Dedicated | 7 GB | 250 GB | Yes | Yes | 20 |

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Basic understanding of web development
- Sample web application code (optional)

---

## Creating App Service Plan

### 1. Create Resource Group

```bash
# Create resource group
az group create \
  --name rg-webapp-demo \
  --location eastus
```

### 2. Create App Service Plan

```bash
# Create App Service Plan - Free tier
az appservice plan create \
  --name plan-webapp-free \
  --resource-group rg-webapp-demo \
  --sku F1 \
  --is-linux false

# Create App Service Plan - Standard tier (supports deployment slots)
az appservice plan create \
  --name plan-webapp-standard \
  --resource-group rg-webapp-demo \
  --sku S1 \
  --is-linux false

# Create App Service Plan - Linux
az appservice plan create \
  --name plan-webapp-linux \
  --resource-group rg-webapp-demo \
  --sku S1 \
  --is-linux true
```

### 3. View App Service Plan Details

```bash
# List App Service Plans
az appservice plan list \
  --resource-group rg-webapp-demo \
  --output table

# Get specific plan details
az appservice plan show \
  --name plan-webapp-standard \
  --resource-group rg-webapp-demo \
  --query "{Name:name, Sku:sku.name, Capacity:sku.capacity, OS:kind}"
```

---

## Creating Azure Web Apps

### 1. Create .NET Web App

```bash
# Create .NET web app
az webapp create \
  --name webapp-dotnet-demo-$(date +%s) \
  --resource-group rg-webapp-demo \
  --plan plan-webapp-standard \
  --runtime "DOTNET|6.0"

# Set app settings
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --settings WEBSITE_NODE_DEFAULT_VERSION=6.9.1
```

### 2. Create Node.js Web App

```bash
# Create Node.js web app
az webapp create \
  --name webapp-nodejs-demo-$(date +%s) \
  --resource-group rg-webapp-demo \
  --plan plan-webapp-standard \
  --runtime "NODE|18-lts"
```

### 3. Create Python Web App (Linux)

```bash
# Create Python web app on Linux
az webapp create \
  --name webapp-python-demo-$(date +%s) \
  --resource-group rg-webapp-demo \
  --plan plan-webapp-linux \
  --runtime "PYTHON|3.9"
```

### 4. Create Java Web App

```bash
# Create Java web app
az webapp create \
  --name webapp-java-demo-$(date +%s) \
  --resource-group rg-webapp-demo \
  --plan plan-webapp-standard \
  --runtime "JAVA|11|Java SE|11"
```

---

## Configuring Web Apps

### 1. Application Settings

```bash
# Set application settings
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --settings \
    DATABASE_URL="Server=myserver;Database=mydb;" \
    API_KEY="your-api-key" \
    ENVIRONMENT="production"

# List application settings
az webapp config appsettings list \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --output table
```

### 2. Connection Strings

```bash
# Set connection strings
az webapp config connection-string set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --connection-string-type SQLServer \
  --settings DefaultConnection="Server=myserver;Database=mydb;User Id=myuser;Password=mypass;"
```

### 3. Custom Domains and SSL

```bash
# Add custom domain
az webapp config hostname add \
  --webapp-name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --hostname www.mydomain.com

# Bind SSL certificate
az webapp config ssl bind \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --certificate-thumbprint <thumbprint> \
  --ssl-type SNI
```

---

## Deployment Slots

### 1. Create Deployment Slots

```bash
# Create staging slot
az webapp deployment slot create \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging

# Create development slot
az webapp deployment slot create \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot development

# Create UAT slot
az webapp deployment slot create \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot uat
```

### 2. Configure Slot Settings

```bash
# Set slot-specific settings (staging)
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --settings \
    ENVIRONMENT="staging" \
    DATABASE_URL="Server=staging-server;Database=staging-db;" \
    DEBUG_MODE="true"

# Set slot-specific settings (development)
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot development \
  --settings \
    ENVIRONMENT="development" \
    DATABASE_URL="Server=dev-server;Database=dev-db;" \
    DEBUG_MODE="true" \
    LOG_LEVEL="debug"
```

### 3. Slot Configuration Settings

```bash
# Mark settings as slot-specific (won't swap)
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot-settings \
    DATABASE_URL \
    ENVIRONMENT \
    API_ENDPOINT
```

### 4. Deploy to Slots

```bash
# Deploy to staging slot using ZIP
az webapp deployment source config-zip \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --src app-v2.0.zip

# Deploy to development slot from GitHub
az webapp deployment source config \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot development \
  --repo-url https://github.com/username/webapp-repo \
  --branch develop \
  --manual-integration
```

### 5. Slot Swapping

```bash
# Preview swap (validate before actual swap)
az webapp deployment slot swap \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --target-slot production \
  --action preview

# Complete the swap
az webapp deployment slot swap \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --target-slot production

# Reset swap (rollback)
az webapp deployment slot swap \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --target-slot production \
  --action reset
```

---

## Traffic Routing and A/B Testing

### 1. Configure Traffic Routing

```bash
# Route 20% traffic to staging slot
az webapp traffic-routing set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --distribution staging=20

# Route 50% traffic to staging for A/B testing
az webapp traffic-routing set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --distribution staging=50

# View current traffic routing
az webapp traffic-routing show \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo
```

### 2. Clear Traffic Routing

```bash
# Remove traffic routing (100% to production)
az webapp traffic-routing clear \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo
```

---

## Scaling and Performance

### 1. Manual Scaling

```bash
# Scale up App Service Plan
az appservice plan update \
  --name plan-webapp-standard \
  --resource-group rg-webapp-demo \
  --sku P1V2

# Scale out (increase instance count)
az appservice plan update \
  --name plan-webapp-standard \
  --resource-group rg-webapp-demo \
  --number-of-workers 3
```

### 2. Auto Scaling

```bash
# Create auto scale profile
az monitor autoscale create \
  --resource-group rg-webapp-demo \
  --resource plan-webapp-standard \
  --resource-type Microsoft.Web/serverfarms \
  --name autoscale-webapp \
  --min-count 1 \
  --max-count 5 \
  --count 2

# Create scale-out rule (CPU > 70%)
az monitor autoscale rule create \
  --resource-group rg-webapp-demo \
  --autoscale-name autoscale-webapp \
  --condition "CpuPercentage > 70 avg 5m" \
  --scale out 1

# Create scale-in rule (CPU < 30%)
az monitor autoscale rule create \
  --resource-group rg-webapp-demo \
  --autoscale-name autoscale-webapp \
  --condition "CpuPercentage < 30 avg 10m" \
  --scale in 1
```

---

## Deployment Methods

### 1. ZIP Deployment

```bash
# Create sample application
mkdir sample-app
cd sample-app
echo "<html><body><h1>Hello Azure Web App!</h1></body></html>" > index.html
zip -r app.zip .

# Deploy ZIP file
az webapp deployment source config-zip \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --src app.zip
```

### 2. Git Deployment

```bash
# Configure local Git deployment
az webapp deployment source config-local-git \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo

# Get Git URL
GIT_URL=$(az webapp deployment source show \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --query repositoryUrl -o tsv)

echo "Git URL: $GIT_URL"

# Deploy using Git (from local repository)
# git remote add azure $GIT_URL
# git push azure main
```

### 3. GitHub Actions Deployment

```bash
# Configure GitHub Actions deployment
az webapp deployment github-actions add \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --repo https://github.com/username/webapp-repo \
  --branch main \
  --runtime dotnet \
  --token <github-token>
```

### 4. Container Deployment

```bash
# Create web app from container
az webapp create \
  --name webapp-container-demo-$(date +%s) \
  --resource-group rg-webapp-demo \
  --plan plan-webapp-linux \
  --deployment-container-image-name nginx:latest

# Configure custom container
az webapp config container set \
  --name webapp-container-demo-* \
  --resource-group rg-webapp-demo \
  --docker-custom-image-name myregistry.azurecr.io/myapp:latest \
  --docker-registry-server-url https://myregistry.azurecr.io \
  --docker-registry-server-user myuser \
  --docker-registry-server-password mypassword
```

---

## Monitoring and Diagnostics

### 1. Application Insights

```bash
# Create Application Insights
az monitor app-insights component create \
  --app webapp-insights \
  --location eastus \
  --resource-group rg-webapp-demo \
  --application-type web

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app webapp-insights \
  --resource-group rg-webapp-demo \
  --query instrumentationKey -o tsv)

# Configure Application Insights for web app
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY
```

### 2. Diagnostic Logs

```bash
# Enable application logging
az webapp log config \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --application-logging filesystem \
  --level information

# Enable web server logging
az webapp log config \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --web-server-logging filesystem

# Stream logs
az webapp log tail \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo
```

### 3. Health Checks

```bash
# Configure health check
az webapp config set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --generic-configurations '{"healthCheckPath": "/health"}'
```

---

## Security Configuration

### 1. Authentication and Authorization

```bash
# Enable Azure AD authentication
az webapp auth update \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --enabled true \
  --action LoginWithAzureActiveDirectory \
  --aad-client-id <client-id> \
  --aad-client-secret <client-secret> \
  --aad-tenant-id <tenant-id>
```

### 2. IP Restrictions

```bash
# Add IP restriction
az webapp config access-restriction add \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --rule-name "Office IP" \
  --action Allow \
  --ip-address 203.0.113.0/24 \
  --priority 100
```

### 3. Managed Identity

```bash
# Enable system-assigned managed identity
az webapp identity assign \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo

# Get managed identity details
az webapp identity show \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo
```

---

## Best Practices

### 1. Deployment Slot Strategy

```bash
# Recommended slot configuration
# Production -> Staging -> Development

# Always test in staging before production
az webapp deployment slot create \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --configuration-source webapp-dotnet-demo-*

# Use slot-specific settings for environment differences
az webapp config appsettings set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --slot staging \
  --slot-settings DATABASE_URL ENVIRONMENT API_ENDPOINT
```

### 2. Performance Optimization

```bash
# Enable compression
az webapp config set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --generic-configurations '{"gzipCompressionEnabled": true}'

# Configure connection strings for performance
az webapp config connection-string set \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --connection-string-type SQLServer \
  --settings DefaultConnection="Server=myserver;Database=mydb;Connection Timeout=30;Max Pool Size=100;"
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check web app status
az webapp show \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --query "{Name:name, State:state, DefaultHostName:defaultHostName}"

# Restart web app
az webapp restart \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo

# Check deployment status
az webapp deployment list-publishing-profiles \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo
```

### 2. Diagnostic Commands

```bash
# Get web app metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-webapp-demo/providers/Microsoft.Web/sites/webapp-dotnet-demo-* \
  --metric "CpuTime" \
  --interval PT1M

# Check slot configuration
az webapp deployment slot list \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo \
  --output table
```

---

## Cleanup

```bash
# Delete web apps
az webapp delete \
  --name webapp-dotnet-demo-* \
  --resource-group rg-webapp-demo

# Delete App Service Plans
az appservice plan delete \
  --name plan-webapp-standard \
  --resource-group rg-webapp-demo \
  --yes

# Delete resource group
az group delete \
  --name rg-webapp-demo \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Understanding Azure Web Apps, App Service Plans, and deployment slots
- Creating and configuring web apps for different runtimes
- Implementing deployment slots for staging and production environments
- Traffic routing and A/B testing capabilities
- Various deployment methods (ZIP, Git, GitHub Actions, containers)
- Scaling, monitoring, and security configuration
- Best practices for production deployments

Deployment slots provide powerful capabilities for zero-downtime deployments, A/B testing, and safe production releases with easy rollback options.
# Azure Container Registry (ACR) with Application Containerization

This guide covers creating Azure Container Registry, containerizing applications, and publishing container images to ACR.

## Understanding Azure Container Registry

### Azure Container Registry (ACR)
- **Definition**: Managed Docker registry service for storing and managing container images
- **Features**: Private registry, geo-replication, security scanning, webhook integration
- **Tiers**: Basic, Standard, Premium with different storage and throughput limits
- **Integration**: Works with AKS, Container Instances, App Service, and other Azure services

### Container Benefits
- **Portability**: Run anywhere with consistent environment
- **Scalability**: Easy horizontal scaling and orchestration
- **Isolation**: Application dependencies packaged together
- **Efficiency**: Lightweight compared to virtual machines

### ACR Tiers Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | 500 GB |
| Throughput | 10 MiB/s | 60 MiB/s | 200 MiB/s |
| Webhooks | 2 | 10 | 500 |
| Geo-replication | No | No | Yes |
| Content Trust | No | No | Yes |

---

## Manual ACR Creation via Azure Portal

### Creating Container Registry via Portal

#### 1. Create Azure Container Registry
1. Navigate to **Container registries**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Registry name**: `acrportaldemounique` (must be globally unique)
   - **Location**: `Southeast Asia`
   - **SKU**: Select tier based on needs:
     - **Basic**: Development and testing
     - **Standard**: Production workloads
     - **Premium**: High-scale production, geo-replication
   - **Admin user**: `Enable` (for simple authentication)

4. **Networking tab** (Premium only):
   - **Public access**: `All networks` or `Selected networks`
   - **Private endpoint**: Configure if needed

5. **Encryption tab** (Premium only):
   - **Customer-managed key**: Configure if needed

6. Click **Review + create** > **Create**

#### 2. Configure Registry Settings
1. Navigate to your created ACR
2. **Settings** > **Access keys**:
   - **Admin user**: Enable/disable admin authentication
   - **Username**: Registry name
   - **Password**: Copy primary or secondary password

3. **Settings** > **Repositories**:
   - View pushed repositories and tags
   - Manage repository permissions

4. **Settings** > **Webhooks**:
   - Click **Add**
   - **Webhook name**: `webhook-deploy`
   - **Service URI**: `https://myapp.azurewebsites.net/api/webhook`
   - **Actions**: Select `push`, `delete`, etc.
   - **Scope**: Specify repository filter
   - Click **Create**

### Building Images via Portal (ACR Tasks)

#### 1. Quick Build via Portal
1. Navigate to your ACR
2. Go to **Services** > **Tasks**
3. Click **Quick run**
4. **Quick run** page:
   - **Source location**: `Upload a tar.gz` or `GitHub repository`
   - **Dockerfile**: Path to Dockerfile
   - **Image name**: `myapp:{{.Run.ID}}`
   - **OS**: `Linux` or `Windows`
   - **Architecture**: `amd64`, `arm64`
5. Click **Run**

#### 2. Create ACR Task via Portal
1. Go to **Services** > **Tasks**
2. Click **Add** > **Task**
3. **Create task** page:
   - **Task name**: `nodejs-build-task`
   - **Source location**: `GitHub` or `Azure Repos`
   - **Repository**: Repository URL
   - **Branch**: `main` or `master`
   - **Dockerfile**: `Dockerfile`
   - **Image name**: `nodejs-app:{{.Run.ID}}`
   - **OS**: `Linux`
4. **Triggers** tab:
   - **Source code update**: Enable for automatic builds
   - **Base image update**: Enable for base image updates
5. Click **Create**

### Managing Images via Portal

#### 1. View Repositories and Tags
1. Navigate to ACR
2. Go to **Services** > **Repositories**
3. Click on repository name to view:
   - **Tags**: All image tags
   - **Manifests**: Image manifests and layers
   - **Vulnerabilities**: Security scan results (Premium)

#### 2. Delete Images
1. In **Repositories**, select repository
2. Select tags to delete
3. Click **Delete** > **Yes**

#### 3. Repository Permissions
1. Go to **Settings** > **Repository permissions**
2. **Add** > **Repository permission**:
   - **Repository**: Select repository
   - **Identity**: User or service principal
   - **Permissions**: `pull`, `push`, `delete`
3. Click **Save**

### Deployment via Portal

#### 1. Deploy to Container Instances
1. Navigate to **Container instances**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Container name**: `nodejs-aci-portal`
   - **Region**: `Southeast Asia`
   - **Image source**: `Azure Container Registry`
   - **Registry**: Select your ACR
   - **Image**: Select repository and tag
   - **Authentication**: Use admin credentials or managed identity

4. **Networking tab**:
   - **DNS name label**: `nodejs-acr-demo-portal`
   - **Ports**: Add port `3000`

5. Click **Review + create** > **Create**

#### 2. Deploy to Web App
1. Navigate to **App Services**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `webapp-acr-portal`
   - **Publish**: `Docker Container`
   - **Operating System**: `Linux`
   - **Region**: `Southeast Asia`
   - **App Service Plan**: Create new Linux plan

4. **Docker tab**:
   - **Image Source**: `Azure Container Registry`
   - **Registry**: Select your ACR
   - **Image**: Select repository
   - **Tag**: Select tag
   - **Startup Command**: Optional

5. Click **Review + create** > **Create**

### Monitoring via Portal

#### 1. View Metrics
1. Navigate to ACR
2. Go to **Monitoring** > **Metrics**
3. **Metric**: Select metrics:
   - `Total Pull Count`
   - `Total Push Count`
   - `Storage Used`
   - `Successful Pull Count`
4. **Time range**: Select period
5. **Chart type**: Line, bar, etc.

#### 2. Activity Logs
1. Go to **Monitoring** > **Activity log**
2. **Timespan**: Select time range
3. **Event level**: All, Critical, Error, Warning, Informational
4. **Resource type**: `Container registries`
5. View registry operations and changes

#### 3. Diagnostic Settings
1. Go to **Monitoring** > **Diagnostic settings**
2. Click **Add diagnostic setting**
3. **Diagnostic setting name**: `acr-diagnostics`
4. **Logs**: Select log categories:
   - `ContainerRegistryRepositoryEvents`
   - `ContainerRegistryLoginEvents`
5. **Destination details**: Log Analytics workspace
6. Click **Save**

### Security Configuration via Portal

#### 1. Network Access
1. Navigate to ACR
2. Go to **Settings** > **Networking**
3. **Public access** tab:
   - **Allow public access**: `All networks`, `Selected networks`, or `Disabled`
   - **Firewall**: Add IP address ranges
4. **Private access** tab:
   - **Private endpoint connections**: Add private endpoints

#### 2. Content Trust (Premium)
1. Go to **Settings** > **Content trust**
2. **Content trust**: `Enabled`
3. Configure signing keys and policies

#### 3. Security Scanning
1. Go to **Services** > **Repositories**
2. Select repository and tag
3. **Security** tab shows vulnerability scan results
4. Review and remediate vulnerabilities

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create Container Registry
New-AzContainerRegistry -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "acrportalps" -Sku "Standard" -Location "Southeast Asia" -EnableAdminUser

# Get registry credentials
$registry = Get-AzContainerRegistry -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "acrportalps"
$creds = Get-AzContainerRegistryCredential -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "acrportalps"

# Create webhook
New-AzContainerRegistryWebhook -ResourceGroupName "sa1_test_eic_SudarshanDarade" -RegistryName "acrportalps" -Name "webhook-deploy" -Uri "https://myapp.azurewebsites.net/api/webhook" -Action "push"

# Create ACR task
$taskParams = @{
    ResourceGroupName = "sa1_test_eic_SudarshanDarade"
    RegistryName = "acrportalps"
    TaskName = "nodejs-build-task"
    SourceLocation = "https://github.com/username/nodejs-app.git"
    DockerFilePath = "Dockerfile"
    ImageName = "nodejs-app:{{.Run.ID}}"
    OSType = "Linux"
}
New-AzContainerRegistryTask @taskParams

# Deploy to Container Instance
$containerParams = @{
    ResourceGroupName = "sa1_test_eic_SudarshanDarade"
    Name = "nodejs-aci-ps"
    Image = "$($registry.LoginServer)/nodejs-app:latest"
    RegistryCredential = $creds
    DnsNameLabel = "nodejs-acr-ps"
    Port = 3000
    Location = "Southeast Asia"
}
New-AzContainerGroup @containerParams
```

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Docker installed locally
- Sample application code
- Basic understanding of containerization

---

## Creating Azure Container Registry

### 1. Create Resource Group

```bash
# Create resource group
az group create \
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia
```

### 2. Create Container Registry

```bash
# Create ACR - Basic tier
az acr create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name acrdemounique$(date +%s) \
  --sku Basic \
  --admin-enabled true

# Create ACR - Premium tier (with advanced features)
az acr create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name acrpremiumdemo$(date +%s) \
  --sku Premium \
  --admin-enabled true
```

### 3. Get Registry Information

```bash
# Get ACR details
az acr show \
  --name acrdemounique* \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "{Name:name, LoginServer:loginServer, Sku:sku.name, AdminEnabled:adminUserEnabled}"

# Get login credentials
az acr credential show \
  --name acrdemounique* \
  --resource-group sa1_test_eic_SudarshanDarade
```

---

## Sample Applications for Containerization

### 1. Node.js Application

```bash
# Create Node.js app directory
mkdir nodejs-app
cd nodejs-app

# Create package.json
cat > package.json << 'EOF'
{
  "name": "nodejs-acr-demo",
  "version": "1.0.0",
  "description": "Node.js app for ACR demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create server.js
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Node.js in Azure Container Registry!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF
```

### 2. Python Flask Application

```bash
# Create Python app directory
mkdir python-app
cd python-app

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.2
gunicorn==21.2.0
EOF

# Create app.py
cat > app.py << 'EOF'
from flask import Flask, jsonify
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Python Flask in Azure Container Registry!',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
EOF
```

### 3. .NET Core Application

```bash
# Create .NET app directory
mkdir dotnet-app
cd dotnet-app

# Create new .NET web API project
dotnet new webapi -n DemoApi
cd DemoApi

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["DemoApi.csproj", "."]
RUN dotnet restore "DemoApi.csproj"
COPY . .
RUN dotnet build "DemoApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DemoApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DemoApi.dll"]
EOF
```

---

## Building and Testing Containers Locally

### 1. Build Docker Images

```bash
# Build Node.js image
cd nodejs-app
docker build -t nodejs-acr-demo:v1.0.0 .

# Build Python image
cd ../python-app
docker build -t python-acr-demo:v1.0.0 .

# Build .NET image
cd ../dotnet-app/DemoApi
docker build -t dotnet-acr-demo:v1.0.0 .
```

### 2. Test Images Locally

```bash
# Test Node.js container
docker run -d -p 3000:3000 --name nodejs-test nodejs-acr-demo:v1.0.0
curl http://localhost:3000

# Test Python container
docker run -d -p 5000:5000 --name python-test python-acr-demo:v1.0.0
curl http://localhost:5000

# Test .NET container
docker run -d -p 8080:80 --name dotnet-test dotnet-acr-demo:v1.0.0
curl http://localhost:8080/weatherforecast

# Stop test containers
docker stop nodejs-test python-test dotnet-test
docker rm nodejs-test python-test dotnet-test
```

---

## Publishing Images to ACR

### 1. Login to ACR

```bash
# Login to ACR using Azure CLI
az acr login --name acrdemounique*

# Alternative: Login using Docker
ACR_NAME=$(az acr list --resource-group sa1_test_eic_SudarshanDarade --query "[0].name" -o tsv)
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

docker login $ACR_LOGIN_SERVER -u $ACR_NAME -p $ACR_PASSWORD
```

### 2. Tag Images for ACR

```bash
# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

# Tag images with ACR registry name
docker tag nodejs-acr-demo:v1.0.0 $ACR_LOGIN_SERVER/nodejs-acr-demo:v1.0.0
docker tag python-acr-demo:v1.0.0 $ACR_LOGIN_SERVER/python-acr-demo:v1.0.0
docker tag dotnet-acr-demo:v1.0.0 $ACR_LOGIN_SERVER/dotnet-acr-demo:v1.0.0

# Tag with latest
docker tag nodejs-acr-demo:v1.0.0 $ACR_LOGIN_SERVER/nodejs-acr-demo:latest
docker tag python-acr-demo:v1.0.0 $ACR_LOGIN_SERVER/python-acr-demo:latest
docker tag dotnet-acr-demo:v1.0.0 $ACR_LOGIN_SERVER/dotnet-acr-demo:latest
```

### 3. Push Images to ACR

```bash
# Push Node.js image
docker push $ACR_LOGIN_SERVER/nodejs-acr-demo:v1.0.0
docker push $ACR_LOGIN_SERVER/nodejs-acr-demo:latest

# Push Python image
docker push $ACR_LOGIN_SERVER/python-acr-demo:v1.0.0
docker push $ACR_LOGIN_SERVER/python-acr-demo:latest

# Push .NET image
docker push $ACR_LOGIN_SERVER/dotnet-acr-demo:v1.0.0
docker push $ACR_LOGIN_SERVER/dotnet-acr-demo:latest
```

---

## ACR Build Tasks (Cloud Build)

### 1. Build in ACR (without local Docker)

```bash
# Build Node.js app in ACR
az acr build \
  --registry $ACR_NAME \
  --image nodejs-acr-demo:v1.1.0 \
  --file Dockerfile \
  ./nodejs-app

# Build Python app in ACR
az acr build \
  --registry $ACR_NAME \
  --image python-acr-demo:v1.1.0 \
  --file Dockerfile \
  ./python-app

# Build from Git repository
az acr build \
  --registry $ACR_NAME \
  --image myapp:{{.Run.ID}} \
  https://github.com/username/myapp.git
```

### 2. Create ACR Tasks for CI/CD

```bash
# Create task for automatic builds on Git commit
az acr task create \
  --registry $ACR_NAME \
  --name nodejs-build-task \
  --image nodejs-acr-demo:{{.Run.ID}} \
  --context https://github.com/username/nodejs-app.git \
  --file Dockerfile \
  --git-access-token <github-token>

# Run task manually
az acr task run \
  --registry $ACR_NAME \
  --name nodejs-build-task

# List tasks
az acr task list \
  --registry $ACR_NAME \
  --output table
```

---

## Managing ACR Images

### 1. List and View Images

```bash
# List repositories
az acr repository list \
  --name $ACR_NAME \
  --output table

# List tags for a repository
az acr repository show-tags \
  --name $ACR_NAME \
  --repository nodejs-acr-demo \
  --output table

# Get image manifest
az acr repository show \
  --name $ACR_NAME \
  --image nodejs-acr-demo:v1.0.0
```

### 2. Image Security Scanning

```bash
# Enable vulnerability scanning (Premium tier)
az acr config content-trust update \
  --registry $ACR_NAME \
  --status enabled

# Scan image for vulnerabilities
az acr check-health \
  --name $ACR_NAME \
  --yes
```

### 3. Image Cleanup

```bash
# Delete specific tag
az acr repository delete \
  --name $ACR_NAME \
  --image nodejs-acr-demo:v1.0.0 \
  --yes

# Delete repository
az acr repository delete \
  --name $ACR_NAME \
  --repository nodejs-acr-demo \
  --yes

# Purge old images (keep last 5 versions)
az acr run \
  --registry $ACR_NAME \
  --cmd "acr purge --filter 'nodejs-acr-demo:.*' --keep 5 --untagged" \
  /dev/null
```

---

## Deploying from ACR

### 1. Deploy to Azure Container Instances

```bash
# Deploy Node.js app to ACI
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nodejs-aci \
  --image $ACR_LOGIN_SERVER/nodejs-acr-demo:latest \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label nodejs-acr-demo-$(date +%s) \
  --ports 3000

# Get container URL
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nodejs-aci \
  --query ipAddress.fqdn \
  --output tsv
```

### 2. Deploy to Azure Web App

```bash
# Create App Service Plan for containers
az appservice plan create \
  --name plan-container-demo \
  --resource-group sa1_test_eic_SudarshanDarade \
  --sku B1 \
  --is-linux

# Create Web App with container
az webapp create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --plan plan-container-demo \
  --name webapp-nodejs-$(date +%s) \
  --deployment-container-image-name $ACR_LOGIN_SERVER/nodejs-acr-demo:latest

# Configure container settings
az webapp config container set \
  --name webapp-nodejs-* \
  --resource-group sa1_test_eic_SudarshanDarade \
  --docker-custom-image-name $ACR_LOGIN_SERVER/nodejs-acr-demo:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-user $ACR_NAME \
  --docker-registry-server-password $ACR_PASSWORD
```

---

## ACR Webhooks and Automation

### 1. Create Webhooks

```bash
# Create webhook for image push events
az acr webhook create \
  --registry $ACR_NAME \
  --name webhook-deploy \
  --uri https://myapp.azurewebsites.net/api/webhook \
  --actions push \
  --scope nodejs-acr-demo:*

# List webhooks
az acr webhook list \
  --registry $ACR_NAME \
  --output table

# Test webhook
az acr webhook ping \
  --registry $ACR_NAME \
  --name webhook-deploy
```

### 2. Continuous Deployment Setup

```bash
# Enable continuous deployment for Web App
az webapp deployment container config \
  --name webapp-nodejs-* \
  --resource-group sa1_test_eic_SudarshanDarade \
  --enable-cd true

# Get webhook URL for external CI/CD
az webapp deployment container show-cd-url \
  --name webapp-nodejs-* \
  --resource-group sa1_test_eic_SudarshanDarade
```

---

## Multi-Architecture Images

### 1. Build Multi-Platform Images

```bash
# Create buildx builder
docker buildx create --name multiarch-builder --use

# Build multi-architecture image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag $ACR_LOGIN_SERVER/nodejs-acr-demo:multiarch \
  --push \
  ./nodejs-app
```

---

## Monitoring and Logging

### 1. ACR Metrics and Logs

```bash
# Enable diagnostic logs
az monitor diagnostic-settings create \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME \
  --name acr-diagnostics \
  --logs '[{"category":"ContainerRegistryRepositoryEvents","enabled":true},{"category":"ContainerRegistryLoginEvents","enabled":true}]' \
  --workspace /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/acr-workspace

# View recent activities
az acr task list-runs \
  --registry $ACR_NAME \
  --output table
```

### 2. Image Usage Analytics

```bash
# Get repository statistics
az acr repository show \
  --name $ACR_NAME \
  --repository nodejs-acr-demo \
  --query "{Name:name, TagCount:tagCount, ManifestCount:manifestCount}"

# List recent pulls
az acr repository show-manifests \
  --name $ACR_NAME \
  --repository nodejs-acr-demo \
  --query "[].{Digest:digest, Tags:tags, LastUpdateTime:lastUpdateTime}" \
  --output table
```

---

## Best Practices

### 1. Image Optimization

```dockerfile
# Multi-stage Dockerfile example for Node.js
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
USER node
CMD ["npm", "start"]
```

### 2. Security Best Practices

```bash
# Use managed identity for ACR access
az acr update \
  --name $ACR_NAME \
  --admin-enabled false

# Create service principal for ACR access
az ad sp create-for-rbac \
  --name acr-service-principal \
  --scopes /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME \
  --role acrpull
```

### 3. Image Tagging Strategy

```bash
# Semantic versioning
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:1.2.3
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:1.2
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:1
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:latest

# Environment-based tagging
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:dev
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:staging
docker tag myapp:latest $ACR_LOGIN_SERVER/myapp:prod
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check ACR health
az acr check-health --name $ACR_NAME --yes

# Verify connectivity
az acr check-name --name $ACR_NAME

# Check quota usage
az acr show-usage --name $ACR_NAME

# Debug build issues
az acr task logs --registry $ACR_NAME --run-id <run-id>
```

### 2. Authentication Issues

```bash
# Refresh ACR login
az acr login --name $ACR_NAME

# Check credentials
az acr credential show --name $ACR_NAME

# Test Docker login
echo $ACR_PASSWORD | docker login $ACR_LOGIN_SERVER -u $ACR_NAME --password-stdin
```

---

## Cleanup

```bash
# Delete container instances
az container delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nodejs-aci \
  --yes

# Delete web apps
az webapp delete \
  --name webapp-nodejs-* \
  --resource-group sa1_test_eic_SudarshanDarade

# Delete ACR
az acr delete \
  --name $ACR_NAME \
  --resource-group sa1_test_eic_SudarshanDarade \
  --yes

# Delete resource group
az group delete \
  --name sa1_test_eic_SudarshanDarade \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Creating and configuring Azure Container Registry
- Containerizing applications (Node.js, Python, .NET)
- Building and testing containers locally
- Publishing images to ACR using Docker and ACR Build
- Deploying containers to Azure services (ACI, Web Apps)
- Setting up webhooks and continuous deployment
- Image management, security, and best practices
- Monitoring and troubleshooting ACR operations

ACR provides a secure, scalable platform for managing container images with seamless integration across Azure services and robust CI/CD capabilities.
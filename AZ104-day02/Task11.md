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
  --name rg-acr-demo \
  --location eastus
```

### 2. Create Container Registry

```bash
# Create ACR - Basic tier
az acr create \
  --resource-group rg-acr-demo \
  --name acrdemounique$(date +%s) \
  --sku Basic \
  --admin-enabled true

# Create ACR - Premium tier (with advanced features)
az acr create \
  --resource-group rg-acr-demo \
  --name acrpremiumdemo$(date +%s) \
  --sku Premium \
  --admin-enabled true
```

### 3. Get Registry Information

```bash
# Get ACR details
az acr show \
  --name acrdemounique* \
  --resource-group rg-acr-demo \
  --query "{Name:name, LoginServer:loginServer, Sku:sku.name, AdminEnabled:adminUserEnabled}"

# Get login credentials
az acr credential show \
  --name acrdemounique* \
  --resource-group rg-acr-demo
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
ACR_NAME=$(az acr list --resource-group rg-acr-demo --query "[0].name" -o tsv)
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
  --resource-group rg-acr-demo \
  --name nodejs-aci \
  --image $ACR_LOGIN_SERVER/nodejs-acr-demo:latest \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label nodejs-acr-demo-$(date +%s) \
  --ports 3000

# Get container URL
az container show \
  --resource-group rg-acr-demo \
  --name nodejs-aci \
  --query ipAddress.fqdn \
  --output tsv
```

### 2. Deploy to Azure Web App

```bash
# Create App Service Plan for containers
az appservice plan create \
  --name plan-container-demo \
  --resource-group rg-acr-demo \
  --sku B1 \
  --is-linux

# Create Web App with container
az webapp create \
  --resource-group rg-acr-demo \
  --plan plan-container-demo \
  --name webapp-nodejs-$(date +%s) \
  --deployment-container-image-name $ACR_LOGIN_SERVER/nodejs-acr-demo:latest

# Configure container settings
az webapp config container set \
  --name webapp-nodejs-* \
  --resource-group rg-acr-demo \
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
  --resource-group rg-acr-demo \
  --enable-cd true

# Get webhook URL for external CI/CD
az webapp deployment container show-cd-url \
  --name webapp-nodejs-* \
  --resource-group rg-acr-demo
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
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-acr-demo/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME \
  --name acr-diagnostics \
  --logs '[{"category":"ContainerRegistryRepositoryEvents","enabled":true},{"category":"ContainerRegistryLoginEvents","enabled":true}]' \
  --workspace /subscriptions/{subscription-id}/resourceGroups/rg-acr-demo/providers/Microsoft.OperationalInsights/workspaces/acr-workspace

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
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-acr-demo/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME \
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
  --resource-group rg-acr-demo \
  --name nodejs-aci \
  --yes

# Delete web apps
az webapp delete \
  --name webapp-nodejs-* \
  --resource-group rg-acr-demo

# Delete ACR
az acr delete \
  --name $ACR_NAME \
  --resource-group rg-acr-demo \
  --yes

# Delete resource group
az group delete \
  --name rg-acr-demo \
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
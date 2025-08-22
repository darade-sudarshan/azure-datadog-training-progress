# Azure Container Groups (Azure Container Instances)

This guide covers setting up and using Azure Container Groups for running containerized applications without managing infrastructure.

## Understanding Azure Container Groups

### Azure Container Instances (ACI)
- **Definition**: Serverless container platform for running containers without managing VMs
- **Container Groups**: Collection of containers scheduled on the same host machine
- **Benefits**: Fast startup, per-second billing, no infrastructure management
- **Use Cases**: Batch jobs, microservices, CI/CD agents, development environments

### Container Group Features
- **Shared Resources**: Containers share CPU, memory, storage, and network
- **Co-location**: Containers in same group run on same host
- **Shared Lifecycle**: All containers start and stop together
- **Networking**: Shared IP address and port space
- **Storage**: Shared volumes between containers

### Pricing Model
- **CPU**: Per vCPU per second
- **Memory**: Per GB per second
- **No minimum charges**: Pay only for actual usage
- **Regional pricing**: Varies by Azure region

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Container images (from ACR or public registries)
- Basic understanding of containerization

---

## Creating Single Container Groups

### 1. Create Resource Group

```bash
# Create resource group
az group create \
  --name rg-container-groups \
  --location eastus
```

### 2. Simple Container Group

```bash
# Create basic container group with nginx
az container create \
  --resource-group rg-container-groups \
  --name nginx-container \
  --image nginx:latest \
  --dns-name-label nginx-demo-$(date +%s) \
  --ports 80 \
  --cpu 1 \
  --memory 1.5

# Get container details
az container show \
  --resource-group rg-container-groups \
  --name nginx-container \
  --query "{FQDN:ipAddress.fqdn, ProvisioningState:provisioningState}"
```

### 3. Container with Environment Variables

```bash
# Create container with environment variables
az container create \
  --resource-group rg-container-groups \
  --name webapp-container \
  --image mcr.microsoft.com/azuredocs/aci-helloworld:latest \
  --dns-name-label webapp-demo-$(date +%s) \
  --ports 80 \
  --environment-variables \
    NODE_ENV=production \
    PORT=80 \
    API_URL=https://api.example.com
```

### 4. Container from Private Registry (ACR)

```bash
# Create container from ACR
ACR_NAME="myacr"
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

az container create \
  --resource-group rg-container-groups \
  --name acr-webapp \
  --image $ACR_LOGIN_SERVER/nodejs-app:latest \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label acr-webapp-$(date +%s) \
  --ports 3000 \
  --cpu 1 \
  --memory 2
```

---

## Multi-Container Groups

### 1. Web App with Sidecar Pattern

```bash
# Create YAML file for multi-container group
cat > multi-container-group.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: webapp-with-sidecar
properties:
  containers:
  - name: webapp
    properties:
      image: nginx:latest
      ports:
      - port: 80
        protocol: TCP
      resources:
        requests:
          cpu: 1.0
          memoryInGB: 1.5
      volumeMounts:
      - name: shared-logs
        mountPath: /var/log/nginx
  - name: log-processor
    properties:
      image: busybox:latest
      command:
      - /bin/sh
      - -c
      - "while true; do echo 'Processing logs...' >> /shared/app.log; sleep 30; done"
      resources:
        requests:
          cpu: 0.5
          memoryInGB: 0.5
      volumeMounts:
      - name: shared-logs
        mountPath: /shared
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
    dnsNameLabel: webapp-sidecar-demo
  osType: Linux
  volumes:
  - name: shared-logs
    emptyDir: {}
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

# Deploy multi-container group
az container create \
  --resource-group rg-container-groups \
  --file multi-container-group.yaml
```

### 2. Application with Database

```bash
# Create app with database container group
cat > app-with-db.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: app-with-database
properties:
  containers:
  - name: web-app
    properties:
      image: mcr.microsoft.com/azuredocs/aci-helloworld:latest
      ports:
      - port: 80
        protocol: TCP
      environmentVariables:
      - name: DATABASE_HOST
        value: localhost
      - name: DATABASE_PORT
        value: "5432"
      - name: DATABASE_NAME
        value: appdb
      resources:
        requests:
          cpu: 1.0
          memoryInGB: 1.5
  - name: postgres-db
    properties:
      image: postgres:13
      environmentVariables:
      - name: POSTGRES_DB
        value: appdb
      - name: POSTGRES_USER
        value: appuser
      - name: POSTGRES_PASSWORD
        secureValue: mypassword123
      resources:
        requests:
          cpu: 1.0
          memoryInGB: 2.0
      volumeMounts:
      - name: postgres-data
        mountPath: /var/lib/postgresql/data
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
    dnsNameLabel: app-db-demo
  osType: Linux
  volumes:
  - name: postgres-data
    emptyDir: {}
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

# Deploy app with database
az container create \
  --resource-group rg-container-groups \
  --file app-with-db.yaml
```

---

## Storage and Volumes

### 1. Azure File Share Volume

```bash
# Create storage account
az storage account create \
  --resource-group rg-container-groups \
  --name stcontainerdata$(date +%s) \
  --sku Standard_LRS

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group rg-container-groups \
  --account-name stcontainerdata* \
  --query "[0].value" -o tsv)

# Create file share
az storage share create \
  --name container-share \
  --account-name stcontainerdata* \
  --account-key $STORAGE_KEY

# Create container with Azure File share
az container create \
  --resource-group rg-container-groups \
  --name container-with-files \
  --image nginx:latest \
  --dns-name-label nginx-files-$(date +%s) \
  --ports 80 \
  --azure-file-volume-account-name stcontainerdata* \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-share-name container-share \
  --azure-file-volume-mount-path /usr/share/nginx/html
```

### 2. Git Repository Volume

```bash
# Create container with Git repo volume
az container create \
  --resource-group rg-container-groups \
  --name git-volume-container \
  --image nginx:latest \
  --dns-name-label git-nginx-$(date +%s) \
  --ports 80 \
  --gitrepo-url https://github.com/Azure-Samples/aci-helloworld.git \
  --gitrepo-mount-path /usr/share/nginx/html
```

### 3. Secret Volume

```bash
# Create container with secret volume
az container create \
  --resource-group rg-container-groups \
  --name secret-volume-container \
  --image nginx:latest \
  --dns-name-label secret-nginx-$(date +%s) \
  --ports 80 \
  --secrets mysecret1="secret-value-1" mysecret2="secret-value-2" \
  --secrets-mount-path /mnt/secrets
```

---

## Networking Configuration

### 1. Virtual Network Integration

```bash
# Create virtual network
az network vnet create \
  --resource-group rg-container-groups \
  --name vnet-containers \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-containers \
  --subnet-prefix 10.0.1.0/24

# Create container group in VNet
az container create \
  --resource-group rg-container-groups \
  --name vnet-container \
  --image nginx:latest \
  --vnet vnet-containers \
  --subnet subnet-containers \
  --cpu 1 \
  --memory 1.5
```

### 2. Multiple Port Exposure

```bash
# Create container with multiple ports
cat > multi-port-container.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: multi-port-app
properties:
  containers:
  - name: web-server
    properties:
      image: nginx:latest
      ports:
      - port: 80
        protocol: TCP
      - port: 443
        protocol: TCP
      - port: 8080
        protocol: TCP
      resources:
        requests:
          cpu: 1.0
          memoryInGB: 1.5
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 8080
    dnsNameLabel: multi-port-demo
  osType: Linux
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

az container create \
  --resource-group rg-container-groups \
  --file multi-port-container.yaml
```

---

## Container Group Management

### 1. Monitoring and Logs

```bash
# Get container logs
az container logs \
  --resource-group rg-container-groups \
  --name nginx-container

# Stream logs in real-time
az container logs \
  --resource-group rg-container-groups \
  --name nginx-container \
  --follow

# Get logs from specific container in group
az container logs \
  --resource-group rg-container-groups \
  --name webapp-with-sidecar \
  --container-name webapp
```

### 2. Execute Commands

```bash
# Execute command in running container
az container exec \
  --resource-group rg-container-groups \
  --name nginx-container \
  --exec-command "/bin/bash"

# Execute specific command
az container exec \
  --resource-group rg-container-groups \
  --name nginx-container \
  --exec-command "ls -la /usr/share/nginx/html"
```

### 3. Container Group Operations

```bash
# Start container group
az container start \
  --resource-group rg-container-groups \
  --name nginx-container

# Stop container group
az container stop \
  --resource-group rg-container-groups \
  --name nginx-container

# Restart container group
az container restart \
  --resource-group rg-container-groups \
  --name nginx-container

# Get container group status
az container show \
  --resource-group rg-container-groups \
  --name nginx-container \
  --query "{Name:name, State:containers[0].instanceView.currentState.state, IP:ipAddress.ip}"
```

---

## Advanced Scenarios

### 1. Batch Processing Container

```bash
# Create batch processing container
az container create \
  --resource-group rg-container-groups \
  --name batch-processor \
  --image mcr.microsoft.com/azure-cli:latest \
  --restart-policy Never \
  --command-line "az --version && echo 'Batch job completed'" \
  --cpu 2 \
  --memory 4
```

### 2. Scheduled Container Jobs

```bash
# Create container for scheduled tasks
cat > scheduled-job.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: scheduled-backup
properties:
  containers:
  - name: backup-job
    properties:
      image: alpine:latest
      command:
      - /bin/sh
      - -c
      - |
        echo "Starting backup job at $(date)"
        # Simulate backup process
        sleep 60
        echo "Backup completed at $(date)"
      resources:
        requests:
          cpu: 0.5
          memoryInGB: 0.5
      environmentVariables:
      - name: BACKUP_TARGET
        value: "/backup"
      - name: SCHEDULE
        value: "daily"
  restartPolicy: Never
  osType: Linux
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

az container create \
  --resource-group rg-container-groups \
  --file scheduled-job.yaml
```

### 3. Development Environment

```bash
# Create development environment container
az container create \
  --resource-group rg-container-groups \
  --name dev-environment \
  --image mcr.microsoft.com/vscode/devcontainers/base:ubuntu \
  --dns-name-label dev-env-$(date +%s) \
  --ports 8080 \
  --cpu 2 \
  --memory 4 \
  --environment-variables \
    WORKSPACE=/workspace \
    USER=developer \
  --command-line "sleep infinity"
```

---

## Security and Best Practices

### 1. Managed Identity Integration

```bash
# Create container group with managed identity
az container create \
  --resource-group rg-container-groups \
  --name managed-identity-container \
  --image mcr.microsoft.com/azure-cli:latest \
  --assign-identity \
  --command-line "az account show && sleep infinity" \
  --cpu 1 \
  --memory 1.5

# Get managed identity details
az container show \
  --resource-group rg-container-groups \
  --name managed-identity-container \
  --query identity
```

### 2. Secure Environment Variables

```bash
# Create container with secure environment variables
az container create \
  --resource-group rg-container-groups \
  --name secure-app \
  --image nginx:latest \
  --dns-name-label secure-app-$(date +%s) \
  --ports 80 \
  --secure-environment-variables \
    DATABASE_PASSWORD=mysecretpassword \
    API_KEY=secretapikey123 \
  --environment-variables \
    APP_NAME=MySecureApp \
    LOG_LEVEL=info
```

### 3. Resource Limits

```bash
# Create container with resource limits
cat > resource-limited-container.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: resource-limited-app
properties:
  containers:
  - name: limited-app
    properties:
      image: nginx:latest
      ports:
      - port: 80
        protocol: TCP
      resources:
        requests:
          cpu: 0.5
          memoryInGB: 1.0
        limits:
          cpu: 1.0
          memoryInGB: 2.0
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
    dnsNameLabel: limited-app-demo
  osType: Linux
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

az container create \
  --resource-group rg-container-groups \
  --file resource-limited-container.yaml
```

---

## Monitoring and Diagnostics

### 1. Container Insights

```bash
# Enable Container Insights (requires Log Analytics workspace)
az monitor log-analytics workspace create \
  --resource-group rg-container-groups \
  --workspace-name container-insights-workspace

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group rg-container-groups \
  --workspace-name container-insights-workspace \
  --query customerId -o tsv)

# Create container with monitoring
az container create \
  --resource-group rg-container-groups \
  --name monitored-container \
  --image nginx:latest \
  --dns-name-label monitored-nginx-$(date +%s) \
  --ports 80 \
  --log-analytics-workspace $WORKSPACE_ID \
  --log-analytics-workspace-key $(az monitor log-analytics workspace get-shared-keys \
    --resource-group rg-container-groups \
    --workspace-name container-insights-workspace \
    --query primarySharedKey -o tsv)
```

### 2. Health Probes

```bash
# Create container with health probes
cat > health-probe-container.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: health-probe-app
properties:
  containers:
  - name: web-app
    properties:
      image: nginx:latest
      ports:
      - port: 80
        protocol: TCP
      resources:
        requests:
          cpu: 1.0
          memoryInGB: 1.5
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 30
        periodSeconds: 10
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
    dnsNameLabel: health-probe-demo
  osType: Linux
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

az container create \
  --resource-group rg-container-groups \
  --file health-probe-container.yaml
```

---

## Cost Optimization

### 1. Right-sizing Resources

```bash
# Create cost-optimized container
az container create \
  --resource-group rg-container-groups \
  --name cost-optimized \
  --image nginx:latest \
  --dns-name-label cost-opt-$(date +%s) \
  --ports 80 \
  --cpu 0.5 \
  --memory 0.5 \
  --restart-policy OnFailure
```

### 2. Spot Instances (Preview)

```bash
# Create spot container instance
cat > spot-container.yaml << 'EOF'
apiVersion: 2019-12-01
location: eastus
name: spot-container-group
properties:
  containers:
  - name: spot-app
    properties:
      image: nginx:latest
      ports:
      - port: 80
        protocol: TCP
      resources:
        requests:
          cpu: 1.0
          memoryInGB: 1.5
  priority: Spot
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
    dnsNameLabel: spot-demo
  osType: Linux
tags: {}
type: Microsoft.ContainerInstance/containerGroups
EOF

az container create \
  --resource-group rg-container-groups \
  --file spot-container.yaml
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check container group events
az container show \
  --resource-group rg-container-groups \
  --name nginx-container \
  --query "containers[0].instanceView.events"

# Get detailed container state
az container show \
  --resource-group rg-container-groups \
  --name nginx-container \
  --query "containers[0].instanceView.currentState"

# Check resource usage
az container show \
  --resource-group rg-container-groups \
  --name nginx-container \
  --query "containers[0].resources"
```

### 2. Diagnostic Commands

```bash
# List all container groups
az container list \
  --resource-group rg-container-groups \
  --output table

# Get container group metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/rg-container-groups/providers/Microsoft.ContainerInstance/containerGroups/nginx-container \
  --metric "CpuUsage" \
  --interval PT1M
```

---

## Cleanup

```bash
# Delete specific container group
az container delete \
  --resource-group rg-container-groups \
  --name nginx-container \
  --yes

# Delete all container groups in resource group
az container list \
  --resource-group rg-container-groups \
  --query "[].name" -o tsv | \
  xargs -I {} az container delete \
    --resource-group rg-container-groups \
    --name {} \
    --yes

# Delete resource group
az group delete \
  --name rg-container-groups \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Understanding Azure Container Groups and their benefits
- Creating single and multi-container groups
- Storage integration (Azure Files, Git repos, secrets)
- Networking configuration and VNet integration
- Container management operations (logs, exec, start/stop)
- Advanced scenarios (batch processing, scheduled jobs)
- Security best practices and managed identity
- Monitoring, health probes, and diagnostics
- Cost optimization strategies

Azure Container Groups provide a serverless container platform ideal for microservices, batch jobs, and development environments without infrastructure management overhead.
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

## Manual Container Groups Creation via Azure Portal

### Creating Container Groups via Portal

#### 1. Create Single Container Group
1. Navigate to **Container instances**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Container name**: `nginx-portal-demo`
   - **Region**: `Southeast Asia`
   - **Image source**: `Quickstart images`, `Azure Container Registry`, or `Other registry`
   - **Image**: `nginx` (for quickstart) or specify custom image
   - **OS type**: `Linux` or `Windows`
   - **Size**: Configure CPU and memory:
     - **CPU**: `1` cores
     - **Memory**: `1.5` GB

4. **Networking tab**:
   - **Networking type**: `Public` or `Private`
   - **DNS name label**: `nginx-portal-demo` (creates FQDN)
   - **Ports**: Add ports (e.g., `80` for HTTP, `443` for HTTPS)
   - **Protocol**: `TCP` or `UDP`

5. **Advanced tab**:
   - **Restart policy**: `Always`, `Never`, or `OnFailure`
   - **Environment variables**: Add key-value pairs
     - **Name**: `NODE_ENV`, **Value**: `production`
     - **Name**: `PORT`, **Value**: `80`
   - **Command override**: Override container startup command

6. Click **Review + create** > **Create**

#### 2. Create Container from ACR
1. Navigate to **Container instances** > **Create**
2. **Basics tab**:
   - **Image source**: `Azure Container Registry`
   - **Registry**: Select your ACR
   - **Image**: Select repository
   - **Image tag**: Select tag
   - **Registry username**: ACR name
   - **Registry password**: ACR password
3. Configure other settings as above
4. Click **Review + create** > **Create**

### Multi-Container Groups via Portal

#### 1. Create Multi-Container Group
1. Navigate to **Container instances**
2. Click **Create**
3. **Basics tab**:
   - **Container name**: `multi-container-portal`
   - **Image**: Primary container image
4. **Advanced tab**:
   - **Additional containers**: Click **Add**
   - **Container name**: `sidecar-container`
   - **Image**: `busybox:latest`
   - **CPU**: `0.5`, **Memory**: `0.5`
   - **Command**: `/bin/sh -c "while true; do echo 'Sidecar running'; sleep 30; done"`
5. **Networking**: Configure shared networking
6. Click **Review + create** > **Create**

### Storage Configuration via Portal

#### 1. Azure File Share Volume
1. **Prerequisites**: Create Storage Account and File Share
   - Navigate to **Storage accounts** > **Create**
   - Create file share in **File shares** section

2. **Container Creation**:
   - In **Advanced tab** of container creation
   - **Volumes**: Click **Add volume**
   - **Volume type**: `Azure file share`
   - **Volume name**: `shared-storage`
   - **Storage account name**: Your storage account
   - **Storage account key**: Storage account key
   - **File share name**: Your file share name
   - **Mount path**: `/mnt/shared`

#### 2. Git Repository Volume
1. In **Advanced tab**:
   - **Volumes**: Click **Add volume**
   - **Volume type**: `Git repo`
   - **Volume name**: `git-content`
   - **Repository URL**: `https://github.com/Azure-Samples/aci-helloworld.git`
   - **Directory**: `.` (root)
   - **Revision**: `HEAD` or specific commit
   - **Mount path**: `/usr/share/nginx/html`

#### 3. Secret Volume
1. In **Advanced tab**:
   - **Volumes**: Click **Add volume**
   - **Volume type**: `Secret`
   - **Volume name**: `app-secrets`
   - **Secrets**: Add key-value pairs
     - **Key**: `api-key`, **Value**: `secret-api-key-123`
     - **Key**: `db-password`, **Value**: `secure-password`
   - **Mount path**: `/mnt/secrets`

### Networking Configuration via Portal

#### 1. Virtual Network Integration
1. **Prerequisites**: Create Virtual Network
   - Navigate to **Virtual networks** > **Create**
   - Create subnet for containers

2. **Container Creation**:
   - **Networking tab**:
   - **Networking type**: `Private`
   - **Virtual network**: Select your VNet
   - **Subnet**: Select container subnet
   - **Private IP**: `Dynamic` or `Static`

#### 2. Multiple Ports Configuration
1. **Networking tab**:
   - **Ports**: Click **Add port**
   - Add multiple ports:
     - Port `80`, Protocol `TCP`
     - Port `443`, Protocol `TCP`
     - Port `8080`, Protocol `TCP`

### Container Management via Portal

#### 1. View Container Logs
1. Navigate to your Container Instance
2. Go to **Settings** > **Logs**
3. **Container**: Select container (for multi-container groups)
4. **Time range**: Select log time range
5. **Refresh**: Auto-refresh logs
6. **Download**: Download logs as file

#### 2. Execute Commands
1. Go to **Settings** > **Connect**
2. **Container**: Select container
3. **Shell**: `/bin/bash` or `/bin/sh`
4. Click **Connect** to open web-based terminal
5. Execute commands in the container

#### 3. Container Operations
1. **Overview** page:
   - **Start**: Start stopped container
   - **Stop**: Stop running container
   - **Restart**: Restart container
   - **Delete**: Delete container group

#### 4. Update Container
1. Go to **Settings** > **Containers**
2. Select container to update
3. **Update container**:
   - **Image**: Change container image
   - **CPU/Memory**: Adjust resources
   - **Environment variables**: Update variables
   - **Command**: Change startup command
4. Click **Update**

### Monitoring via Portal

#### 1. Metrics and Monitoring
1. Navigate to Container Instance
2. Go to **Monitoring** > **Metrics**
3. **Metric**: Select metrics:
   - `CPU Usage`
   - `Memory Usage`
   - `Network Bytes In/Out`
4. **Time range**: Select monitoring period
5. **Chart type**: Line, area, bar charts

#### 2. Activity Logs
1. Go to **Monitoring** > **Activity log**
2. **Timespan**: Select time range
3. **Event level**: Filter by severity
4. **Resource type**: `Container groups`
5. View container operations and changes

#### 3. Diagnostic Settings
1. Go to **Monitoring** > **Diagnostic settings**
2. Click **Add diagnostic setting**
3. **Diagnostic setting name**: `container-diagnostics`
4. **Logs**: Select log categories:
   - `ContainerInstanceLog`
   - `ContainerEvent`
5. **Destination**: Log Analytics workspace
6. Click **Save**

### Security Configuration via Portal

#### 1. Managed Identity
1. Navigate to Container Instance
2. Go to **Settings** > **Identity**
3. **System assigned**: `On`
4. **Status**: `On`
5. **Permissions**: Assign roles to the identity
6. Click **Save**

#### 2. Environment Variables Security
1. In container creation/update:
   - **Environment variables**: Add variables
   - **Secure**: Check for sensitive values
   - Secure variables are encrypted and not visible in portal

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create simple container group
New-AzContainerGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "nginx-ps-portal" -Image "nginx:latest" -Location "Southeast Asia" -DnsNameLabel "nginx-ps-demo" -Port 80 -Cpu 1 -MemoryInGB 1.5

# Create container with environment variables
$envVars = @{
    "NODE_ENV" = "production"
    "PORT" = "80"
    "API_URL" = "https://api.example.com"
}
New-AzContainerGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "webapp-ps-portal" -Image "mcr.microsoft.com/azuredocs/aci-helloworld:latest" -Location "Southeast Asia" -DnsNameLabel "webapp-ps-demo" -Port 80 -EnvironmentVariable $envVars

# Create container from ACR
$acrCreds = Get-AzContainerRegistryCredential -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "myacr"
$securePassword = ConvertTo-SecureString $acrCreds.Password -AsPlainText -Force
$registryCredential = New-Object System.Management.Automation.PSCredential("myacr", $securePassword)

New-AzContainerGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "acr-ps-portal" -Image "myacr.azurecr.io/myapp:latest" -Location "Southeast Asia" -DnsNameLabel "acr-ps-demo" -Port 3000 -RegistryCredential $registryCredential

# Create container with Azure File share
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "mystorageaccount")[0].Value
$azureFileVolume = New-AzContainerGroupVolumeObject -Name "shared-volume" -AzureFileShareName "container-share" -AzureFileStorageAccountName "mystorageaccount" -AzureFileStorageAccountKey $storageAccountKey

New-AzContainerGroup -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "file-share-ps" -Image "nginx:latest" -Location "Southeast Asia" -Volume $azureFileVolume -ContainerGroupProfile @{containers=@(@{name="nginx";image="nginx:latest";volumeMount=@(@{name="shared-volume";mountPath="/usr/share/nginx/html"})})}

# Get container logs
Get-AzContainerInstanceLog -ResourceGroupName "sa1_test_eic_SudarshanDarade" -ContainerGroupName "nginx-ps-portal"

# Execute command in container
Invoke-AzContainerInstanceCommand -ResourceGroupName "sa1_test_eic_SudarshanDarade" -ContainerGroupName "nginx-ps-portal" -ContainerName "nginx-ps-portal" -Command "ls -la /usr/share/nginx/html"
```

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
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia
```

### 2. Simple Container Group

```bash
# Create basic container group with nginx
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --image nginx:latest \
  --dns-name-label nginx-demo-$(date +%s) \
  --ports 80 \
  --cpu 1 \
  --memory 1.5

# Get container details
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --query "{FQDN:ipAddress.fqdn, ProvisioningState:provisioningState}"
```

### 3. Container with Environment Variables

```bash
# Create container with environment variables
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file multi-container-group.yaml
```

### 2. Application with Database

```bash
# Create app with database container group
cat > app-with-db.yaml << 'EOF'
apiVersion: 2019-12-01
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file app-with-db.yaml
```

---

## Storage and Volumes

### 1. Azure File Share Volume

```bash
# Create storage account
az storage account create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name stcontainerdata$(date +%s) \
  --sku Standard_LRS

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --account-name stcontainerdata* \
  --query "[0].value" -o tsv)

# Create file share
az storage share create \
  --name container-share \
  --account-name stcontainerdata* \
  --account-key $STORAGE_KEY

# Create container with Azure File share
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-containers \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-containers \
  --subnet-prefix 10.0.1.0/24

# Create container group in VNet
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file multi-port-container.yaml
```

---

## Container Group Management

### 1. Monitoring and Logs

```bash
# Get container logs
az container logs \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container

# Stream logs in real-time
az container logs \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --follow

# Get logs from specific container in group
az container logs \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name webapp-with-sidecar \
  --container-name webapp
```

### 2. Execute Commands

```bash
# Execute command in running container
az container exec \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --exec-command "/bin/bash"

# Execute specific command
az container exec \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --exec-command "ls -la /usr/share/nginx/html"
```

### 3. Container Group Operations

```bash
# Start container group
az container start \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container

# Stop container group
az container stop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container

# Restart container group
az container restart \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container

# Get container group status
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --query "{Name:name, State:containers[0].instanceView.currentState.state, IP:ipAddress.ip}"
```

---

## Advanced Scenarios

### 1. Batch Processing Container

```bash
# Create batch processing container
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file scheduled-job.yaml
```

### 3. Development Environment

```bash
# Create development environment container
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --name managed-identity-container \
  --image mcr.microsoft.com/azure-cli:latest \
  --assign-identity \
  --command-line "az account show && sleep infinity" \
  --cpu 1 \
  --memory 1.5

# Get managed identity details
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name managed-identity-container \
  --query identity
```

### 2. Secure Environment Variables

```bash
# Create container with secure environment variables
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file resource-limited-container.yaml
```

---

## Monitoring and Diagnostics

### 1. Container Insights

```bash
# Enable Container Insights (requires Log Analytics workspace)
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name container-insights-workspace

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name container-insights-workspace \
  --query customerId -o tsv)

# Create container with monitoring
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name monitored-container \
  --image nginx:latest \
  --dns-name-label monitored-nginx-$(date +%s) \
  --ports 80 \
  --log-analytics-workspace $WORKSPACE_ID \
  --log-analytics-workspace-key $(az monitor log-analytics workspace get-shared-keys \
    --resource-group sa1_test_eic_SudarshanDarade \
    --workspace-name container-insights-workspace \
    --query primarySharedKey -o tsv)
```

### 2. Health Probes

```bash
# Create container with health probes
cat > health-probe-container.yaml << 'EOF'
apiVersion: 2019-12-01
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file health-probe-container.yaml
```

---

## Cost Optimization

### 1. Right-sizing Resources

```bash
# Create cost-optimized container
az container create \
  --resource-group sa1_test_eic_SudarshanDarade \
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
location: southeastasia
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
  --resource-group sa1_test_eic_SudarshanDarade \
  --file spot-container.yaml
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check container group events
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --query "containers[0].instanceView.events"

# Get detailed container state
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --query "containers[0].instanceView.currentState"

# Check resource usage
az container show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --query "containers[0].resources"
```

### 2. Diagnostic Commands

```bash
# List all container groups
az container list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Get container group metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.ContainerInstance/containerGroups/nginx-container \
  --metric "CpuUsage" \
  --interval PT1M
```

---

## Cleanup

```bash
# Delete specific container group
az container delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nginx-container \
  --yes

# Delete all container groups in resource group
az container list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "[].name" -o tsv | \
  xargs -I {} az container delete \
    --resource-group sa1_test_eic_SudarshanDarade \
    --name {} \
    --yes

# Delete resource group
az group delete \
  --name sa1_test_eic_SudarshanDarade \
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
# Azure Container Apps

This guide covers Azure Container Apps, a serverless container platform for running microservices and containerized applications with built-in scaling, traffic management, and service discovery.

## Understanding Azure Container Apps

### Azure Container Apps
- **Definition**: Serverless container platform built on Kubernetes with simplified management
- **Features**: Auto-scaling, traffic splitting, service discovery, Dapr integration
- **Benefits**: No cluster management, pay-per-use, built-in ingress and load balancing
- **Use Cases**: Microservices, APIs, background processing, event-driven applications

### Key Components
- **Container App**: Individual containerized application
- **Environment**: Secure boundary around container apps with shared networking and logging
- **Revisions**: Immutable snapshots of container app versions
- **Traffic Splitting**: Route traffic between different revisions
- **Scaling Rules**: Auto-scale based on HTTP, CPU, memory, or custom metrics

### Comparison with Other Services

| Feature | Container Apps | Container Instances | App Service |
|---------|----------------|-------------------|-------------|
| Orchestration | Kubernetes-based | Single containers | Platform-managed |
| Scaling | Auto-scale to zero | Manual scaling | Auto-scale (min 1) |
| Networking | Built-in ingress | Public/VNet | Built-in load balancer |
| Pricing | Pay-per-use | Pay-per-second | Always-on pricing |
| Use Case | Microservices | Batch jobs | Web applications |

---

## Manual Container Apps Creation via Azure Portal

### Creating Container Apps Environment via Portal

#### 1. Create Log Analytics Workspace
1. Navigate to **Log Analytics workspaces**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `container-apps-logs-portal`
   - **Region**: `Southeast Asia`
4. Click **Review + create** > **Create**

#### 2. Create Container Apps Environment
1. Navigate to **Container Apps**
2. Click **Create**
3. **Create Container App Environment** page:
   - **Environment name**: `container-apps-env-portal`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Region**: `Southeast Asia`
   - **Zone redundancy**: `Disabled` or `Enabled`
   - **Log Analytics workspace**: Select created workspace
4. **Networking** (optional):
   - **Use your own virtual network**: Configure if needed
   - **Virtual network**: Select existing VNet
   - **Infrastructure subnet**: Select subnet
5. Click **Create**

### Creating Container Apps via Portal

#### 1. Create Simple Container App
1. Navigate to **Container Apps**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Container app name**: `webapp-portal-demo`
   - **Region**: `Southeast Asia`
   - **Container Apps Environment**: Select existing environment

4. **Container tab**:
   - **Use quickstart image**: `Yes` (for demo)
   - **Quickstart image**: `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`
   - **Name**: `webapp-container`
   - **CPU and Memory**: `0.25 CPU cores, 0.5Gi memory`

5. **Ingress tab**:
   - **Ingress**: `Enabled`
   - **Ingress traffic**: `Accepting traffic from anywhere`
   - **Ingress type**: `HTTP`
   - **Target port**: `80`

6. Click **Review + create** > **Create**

#### 2. Create Container App from ACR
1. **Container tab**:
   - **Use quickstart image**: `No`
   - **Image source**: `Azure Container Registry`
   - **Registry**: Select your ACR
   - **Image**: Select repository
   - **Tag**: Select image tag
   - **Registry authentication**: Use admin credentials or managed identity

#### 3. Create Container App with Custom Configuration
1. **Container tab**:
   - **Image source**: `Docker Hub or other registries`
   - **Image and tag**: `nginx:latest`
   - **CPU and Memory**: `0.5 CPU cores, 1Gi memory`
   - **Environment variables**: Add variables
     - **Name**: `NODE_ENV`, **Value**: `production`
     - **Name**: `API_URL`, **Value**: `https://api.example.com`

### Scaling Configuration via Portal

#### 1. Configure Auto Scaling
1. Navigate to your Container App
2. Go to **Application** > **Scale**
3. **Scale rule**:
   - **Rule name**: `http-scaling`
   - **Type**: `HTTP scaling`
   - **Concurrent requests**: `50`
4. **Replica count**:
   - **Minimum replicas**: `0`
   - **Maximum replicas**: `10`
5. Click **Save**

#### 2. Add Custom Scaling Rules
1. **Scale** page > **Add scale rule**
2. **CPU Scaling**:
   - **Rule name**: `cpu-rule`
   - **Type**: `CPU`
   - **CPU utilization**: `70%`
3. **Memory Scaling**:
   - **Rule name**: `memory-rule`
   - **Type**: `Memory`
   - **Memory utilization**: `80%`
4. Click **Add**

### Revision Management via Portal

#### 1. Create New Revision
1. Navigate to Container App
2. Go to **Application** > **Revision management**
3. Click **Create new revision**
4. **Container** tab:
   - **Image and tag**: Update to new version
   - **Environment variables**: Add `VERSION=2.0`
5. **Revision details**:
   - **Revision suffix**: `v2`
6. Click **Create**

#### 2. Traffic Splitting
1. **Revision management** page
2. **Active revisions** section:
   - **Revision 1**: Set traffic percentage (e.g., `80%`)
   - **Revision 2**: Set traffic percentage (e.g., `20%`)
3. Click **Save**

#### 3. Blue-Green Deployment
1. Create new revision with `0%` traffic
2. Test the new revision using direct URL
3. Switch traffic to `100%` for new revision
4. Deactivate old revision if needed

### Jobs Configuration via Portal

#### 1. Create Scheduled Job
1. Navigate to **Container Apps**
2. Click **Create** > **Container Apps Job**
3. **Basics tab**:
   - **Job name**: `scheduled-job-portal`
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Container Apps Environment**: Select environment

4. **Container tab**:
   - **Image and tag**: `mcr.microsoft.com/azure-cli:latest`
   - **CPU and Memory**: `0.25 CPU cores, 0.5Gi memory`
   - **Command**: `/bin/sh`
   - **Args**: `-c,echo 'Scheduled job executed at $(date)'`

5. **Trigger tab**:
   - **Trigger type**: `Schedule`
   - **Cron expression**: `0 */6 * * *` (every 6 hours)
   - **Replica timeout**: `300` seconds
   - **Replica retry limit**: `1`

6. Click **Review + create** > **Create**

#### 2. Create Event-Driven Job
1. **Trigger tab**:
   - **Trigger type**: `Event`
   - **Scale rule type**: `Azure Service Bus`
   - **Queue name**: `workqueue`
   - **Message count**: `1`
   - **Connection**: Configure Service Bus connection

### Security Configuration via Portal

#### 1. Managed Identity
1. Navigate to Container App
2. Go to **Settings** > **Identity**
3. **System assigned** tab:
   - **Status**: `On`
4. **User assigned** tab:
   - **Add**: Select existing user-assigned identity
5. Click **Save**

#### 2. Secrets Management
1. Go to **Settings** > **Secrets**
2. Click **Add**
3. **Add secret**:
   - **Key**: `database-password`
   - **Value**: `mypassword123`
4. **Use in environment variables**:
   - Go to **Application** > **Containers**
   - **Environment variables**: Add variable
   - **Name**: `DATABASE_PASSWORD`
   - **Source**: `Reference a secret`
   - **Value**: Select `database-password`

#### 3. Authentication
1. Go to **Settings** > **Authentication**
2. **Add identity provider**:
   - **Identity provider**: `Microsoft`
   - **App registration type**: `Create new app registration`
   - **Name**: `webapp-auth`
   - **Supported account types**: `Current tenant - Single tenant`
3. **Authentication settings**:
   - **Unauthenticated requests**: `HTTP 302 Found redirect: recommended for websites`
   - **Token store**: `Enabled`
4. Click **Add**

### Monitoring via Portal

#### 1. View Metrics
1. Navigate to Container App
2. Go to **Monitoring** > **Metrics**
3. **Metric**: Select metrics:
   - `Replicas`
   - `CPU Usage`
   - `Memory Usage`
   - `HTTP Requests`
4. **Time range**: Select monitoring period
5. **Chart type**: Configure visualization

#### 2. Application Logs
1. Go to **Monitoring** > **Log stream**
2. **Container**: Select container (for multi-container apps)
3. **Log type**: `System logs` or `Console logs`
4. View real-time logs

#### 3. Diagnostic Settings
1. Go to **Monitoring** > **Diagnostic settings**
2. Click **Add diagnostic setting**
3. **Diagnostic setting name**: `container-app-diagnostics`
4. **Logs**: Select categories:
   - `ContainerAppConsoleLogs`
   - `ContainerAppSystemLogs`
5. **Destination details**: Log Analytics workspace
6. Click **Save**

### Networking via Portal

#### 1. Custom Domain
1. Navigate to Container App
2. Go to **Settings** > **Custom domains**
3. Click **Add custom domain**
4. **Domain**: `www.mydomain.com`
5. **Certificate**: Upload or use managed certificate
6. **Validation**: Complete domain validation
7. Click **Add**

#### 2. Ingress Configuration
1. Go to **Settings** > **Ingress**
2. **Ingress**: `Enabled`
3. **Ingress traffic**: 
   - `Accepting traffic from anywhere` (External)
   - `Limited to Container Apps Environment` (Internal)
4. **Target port**: Configure application port
5. **Transport**: `HTTP` or `HTTP/2`
6. Click **Save**

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create Log Analytics workspace
New-AzOperationalInsightsWorkspace -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "container-apps-logs-ps" -Location "Southeast Asia" -Sku "PerGB2018"

# Get workspace details
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "container-apps-logs-ps"
$workspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "container-apps-logs-ps").PrimarySharedKey

# Create Container Apps environment
New-AzContainerAppManagedEnv -Name "container-apps-env-ps" -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Location "Southeast Asia" -AppLogConfigurationDestination "log-analytics" -LogAnalyticConfigurationCustomerId $workspace.CustomerId -LogAnalyticConfigurationSharedKey $workspaceKey

# Create simple container app
$containerAppArgs = @{
    Name = "webapp-ps-portal"
    ResourceGroupName = "sa1_test_eic_SudarshanDarade"
    ManagedEnvironmentName = "container-apps-env-ps"
    Location = "Southeast Asia"
    ConfigurationIngressExternal = $true
    ConfigurationIngressTargetPort = 80
    TemplateContainer = @(
        @{
            Name = "webapp"
            Image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            ResourceCpu = 0.25
            ResourceMemory = "0.5Gi"
        }
    )
    TemplateScaleMinReplica = 0
    TemplateScaleMaxReplica = 10
}
New-AzContainerApp @containerAppArgs

# Create container app with scaling rules
$scalingRule = @{
    Name = "http-rule"
    Type = "http"
    HttpConcurrentRequest = 50
}

# Update container app with scaling
Update-AzContainerApp -Name "webapp-ps-portal" -ResourceGroupName "sa1_test_eic_SudarshanDarade" -TemplateScaleRule $scalingRule

# Create scheduled job
$jobArgs = @{
    Name = "scheduled-job-ps"
    ResourceGroupName = "sa1_test_eic_SudarshanDarade"
    Location = "Southeast Asia"
    ManagedEnvironmentName = "container-apps-env-ps"
    ConfigurationTriggerType = "Schedule"
    ConfigurationScheduleTriggerCronExpression = "0 */6 * * *"
    ConfigurationReplicaTimeout = 300
    ConfigurationReplicaRetryLimit = 1
    TemplateContainer = @(
        @{
            Name = "job-container"
            Image = "mcr.microsoft.com/azure-cli:latest"
            ResourceCpu = 0.25
            ResourceMemory = "0.5Gi"
            Command = @("/bin/sh")
            Arg = @("-c", "echo 'Job executed at $(date)'")
        }
    )
}
New-AzContainerAppJob @jobArgs
```

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI with Container Apps extension
- Container images (from ACR or public registries)
- Basic understanding of containerization

---

## Setup and Installation

### 1. Install Container Apps Extension

```bash
# Install Azure Container Apps extension
az extension add --name containerapp --upgrade

# Register required providers
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
```

### 2. Create Resource Group

```bash
# Create resource group
az group create \
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia
```

---

## Creating Container Apps Environment

### 1. Create Log Analytics Workspace

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name container-apps-logs \
  --location southeastasia

# Get workspace details
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name container-apps-logs \
  --query customerId -o tsv)

WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name container-apps-logs \
  --query primarySharedKey -o tsv)
```

### 2. Create Container Apps Environment

```bash
# Create Container Apps environment
az containerapp env create \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --logs-workspace-id $WORKSPACE_ID \
  --logs-workspace-key $WORKSPACE_KEY
```

---

## Creating Container Apps

### 1. Simple Web Application

```bash
# Create simple container app
az containerapp create \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external \
  --query properties.configuration.ingress.fqdn
```

### 2. Container App from ACR

```bash
# Create container app from ACR
ACR_NAME="myacr"
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

az containerapp create \
  --name webapp-acr \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image $ACR_LOGIN_SERVER/nodejs-app:latest \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_NAME \
  --registry-password $(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv) \
  --target-port 3000 \
  --ingress external \
  --cpu 0.5 \
  --memory 1Gi
```

### 3. Container App with Environment Variables

```bash
# Create container app with environment variables
az containerapp create \
  --name webapp-config \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image nginx:latest \
  --target-port 80 \
  --ingress external \
  --env-vars \
    NODE_ENV=production \
    API_URL=https://api.example.com \
    LOG_LEVEL=info \
  --cpu 0.25 \
  --memory 0.5Gi
```

---

## Scaling Configuration

### 1. HTTP-based Scaling

```bash
# Create container app with HTTP scaling
az containerapp create \
  --name webapp-http-scale \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 10 \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50
```

### 2. CPU-based Scaling

```bash
# Update container app with CPU scaling
az containerapp update \
  --name webapp-http-scale \
  --resource-group sa1_test_eic_SudarshanDarade \
  --scale-rule-name cpu-rule \
  --scale-rule-type cpu \
  --scale-rule-metadata targetCPUUtilization=70
```

### 3. Memory-based Scaling

```bash
# Add memory-based scaling rule
az containerapp update \
  --name webapp-http-scale \
  --resource-group sa1_test_eic_SudarshanDarade \
  --scale-rule-name memory-rule \
  --scale-rule-type memory \
  --scale-rule-metadata targetMemoryUtilization=80
```

### 4. Custom Metrics Scaling

```bash
# Create container app with custom scaling
cat > custom-scale-app.yaml << 'EOF'
properties:
  configuration:
    ingress:
      external: true
      targetPort: 80
    registries: []
  template:
    containers:
    - image: nginx:latest
      name: webapp
      resources:
        cpu: 0.25
        memory: 0.5Gi
    scale:
      minReplicas: 1
      maxReplicas: 20
      rules:
      - name: queue-rule
        custom:
          type: azure-servicebus
          metadata:
            queueName: workqueue
            messageCount: "5"
          auth:
          - secretRef: servicebus-connection
            triggerParameter: connection
EOF

# Apply custom scaling configuration
az containerapp create \
  --name webapp-custom-scale \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --yaml custom-scale-app.yaml
```

---

## Traffic Management and Revisions

### 1. Create New Revision

```bash
# Update container app to create new revision
az containerapp update \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --set-env-vars VERSION=2.0 \
  --revision-suffix v2

# List revisions
az containerapp revision list \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table
```

### 2. Traffic Splitting

```bash
# Split traffic between revisions (80% to latest, 20% to previous)
az containerapp ingress traffic set \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --revision-weight latest=80 webapp-simple--v2=20

# Route 100% traffic to specific revision
az containerapp ingress traffic set \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --revision-weight webapp-simple--v2=100
```

### 3. Blue-Green Deployment

```bash
# Create blue-green deployment
# Deploy green version
az containerapp update \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --set-env-vars VERSION=3.0 COLOR=green \
  --revision-suffix green

# Test green version (0% traffic initially)
az containerapp ingress traffic set \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --revision-weight webapp-simple--v2=100 webapp-simple--green=0

# Switch to green version
az containerapp ingress traffic set \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --revision-weight webapp-simple--green=100
```

---

## Microservices Architecture

### 1. Frontend Service

```bash
# Create frontend service
az containerapp create \
  --name frontend \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image nginx:latest \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 5 \
  --env-vars \
    BACKEND_URL=https://backend.internal.container-apps-env.southeastasia.azurecontainerapps.io
```

### 2. Backend API Service

```bash
# Create backend API service
az containerapp create \
  --name backend \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress internal \
  --min-replicas 1 \
  --max-replicas 10 \
  --env-vars \
    DATABASE_URL=https://database.internal.container-apps-env.southeastasia.azurecontainerapps.io
```

### 3. Database Service

```bash
# Create database service
az containerapp create \
  --name database \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image postgres:13 \
  --target-port 5432 \
  --ingress internal \
  --min-replicas 1 \
  --max-replicas 1 \
  --env-vars \
    POSTGRES_DB=appdb \
    POSTGRES_USER=appuser \
  --secrets \
    postgres-password=mypassword123
```

---

## Dapr Integration

### 1. Enable Dapr

```bash
# Create container app with Dapr enabled
az containerapp create \
  --name dapr-app \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external \
  --enable-dapr \
  --dapr-app-id dapr-app \
  --dapr-app-port 80 \
  --dapr-app-protocol http
```

### 2. Dapr State Store

```bash
# Create Dapr component for state store
cat > dapr-statestore.yaml << 'EOF'
componentType: state.azure.cosmosdb
version: v1
metadata:
- name: url
  value: https://mycosmosdb.documents.azure.com:443/
- name: masterkey
  secretRef: cosmos-key
- name: database
  value: statestore
- name: collection
  value: state
scopes:
- dapr-app
EOF

# Create Dapr component
az containerapp env dapr-component set \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade \
  --dapr-component-name statestore \
  --yaml dapr-statestore.yaml
```

### 3. Dapr Pub/Sub

```bash
# Create Dapr pub/sub component
cat > dapr-pubsub.yaml << 'EOF'
componentType: pubsub.azure.servicebus
version: v1
metadata:
- name: connectionString
  secretRef: servicebus-connection
scopes:
- publisher-app
- subscriber-app
EOF

# Create pub/sub component
az containerapp env dapr-component set \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade \
  --dapr-component-name pubsub \
  --yaml dapr-pubsub.yaml
```

---

## Jobs and Background Processing

### 1. Scheduled Job

```bash
# Create scheduled job
az containerapp job create \
  --name scheduled-job \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --trigger-type Schedule \
  --replica-timeout 300 \
  --replica-retry-limit 1 \
  --replica-completion-count 1 \
  --parallelism 1 \
  --image mcr.microsoft.com/azure-cli:latest \
  --cpu 0.25 \
  --memory 0.5Gi \
  --cron-expression "0 */6 * * *" \
  --command "/bin/sh" \
  --args "-c,echo 'Scheduled job executed at $(date)'"
```

### 2. Event-Driven Job

```bash
# Create event-driven job
az containerapp job create \
  --name event-job \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --trigger-type Event \
  --replica-timeout 600 \
  --replica-retry-limit 3 \
  --replica-completion-count 1 \
  --parallelism 5 \
  --image mcr.microsoft.com/azure-cli:latest \
  --cpu 0.5 \
  --memory 1Gi \
  --scale-rule-name queue-rule \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata queueName=workqueue messageCount=1 \
  --scale-rule-auth connection=servicebus-connection
```

### 3. Manual Job

```bash
# Create manual job
az containerapp job create \
  --name manual-job \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --trigger-type Manual \
  --replica-timeout 1800 \
  --replica-retry-limit 0 \
  --replica-completion-count 1 \
  --parallelism 1 \
  --image mcr.microsoft.com/azure-cli:latest \
  --cpu 1 \
  --memory 2Gi

# Start manual job
az containerapp job start \
  --name manual-job \
  --resource-group sa1_test_eic_SudarshanDarade
```

---

## Security and Authentication

### 1. Managed Identity

```bash
# Create container app with managed identity
az containerapp create \
  --name secure-app \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image mcr.microsoft.com/azure-cli:latest \
  --target-port 80 \
  --ingress external \
  --assign-identity [system] \
  --command "/bin/sh" \
  --args "-c,while true; do az account show; sleep 3600; done"

# Get managed identity details
az containerapp identity show \
  --name secure-app \
  --resource-group sa1_test_eic_SudarshanDarade
```

### 2. Authentication with Azure AD

```bash
# Enable Azure AD authentication
az containerapp auth update \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --set identityProviders.azureActiveDirectory.registration.clientId=<client-id> \
  --set identityProviders.azureActiveDirectory.registration.clientSecretSettingName=aad-secret \
  --set globalValidation.unauthenticatedClientAction=RedirectToLoginPage
```

### 3. Secrets Management

```bash
# Create secrets
az containerapp secret set \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --secrets \
    database-password=mypassword123 \
    api-key=secretapikey456

# Use secrets in environment variables
az containerapp update \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --set-env-vars \
    DATABASE_PASSWORD=secretref:database-password \
    API_KEY=secretref:api-key
```

---

## Monitoring and Observability

### 1. Application Insights Integration

```bash
# Create Application Insights
az monitor app-insights component create \
  --app container-apps-insights \
  --location southeastasia \
  --resource-group sa1_test_eic_SudarshanDarade \
  --application-type web

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app container-apps-insights \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query instrumentationKey -o tsv)

# Update container app with Application Insights
az containerapp update \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --set-env-vars APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY
```

### 2. Custom Metrics

```bash
# Create container app with custom metrics endpoint
az containerapp create \
  --name metrics-app \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image prom/node-exporter:latest \
  --target-port 9100 \
  --ingress internal \
  --min-replicas 1 \
  --max-replicas 1
```

### 3. Health Probes

```bash
# Create container app with health probes
cat > health-probe-app.yaml << 'EOF'
properties:
  configuration:
    ingress:
      external: true
      targetPort: 80
  template:
    containers:
    - image: nginx:latest
      name: webapp
      probes:
      - type: Liveness
        httpGet:
          path: /health
          port: 80
        initialDelaySeconds: 30
        periodSeconds: 10
      - type: Readiness
        httpGet:
          path: /ready
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5
      - type: Startup
        httpGet:
          path: /startup
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 10
        failureThreshold: 3
      resources:
        cpu: 0.25
        memory: 0.5Gi
EOF

az containerapp create \
  --name health-probe-app \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --yaml health-probe-app.yaml
```

---

## Networking and Connectivity

### 1. Virtual Network Integration

```bash
# Create virtual network
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-container-apps \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-container-apps \
  --subnet-prefix 10.0.1.0/23

# Create Container Apps environment with VNet
az containerapp env create \
  --name container-apps-env-vnet \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --logs-workspace-id $WORKSPACE_ID \
  --logs-workspace-key $WORKSPACE_KEY \
  --infrastructure-subnet-resource-id /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/virtualNetworks/vnet-container-apps/subnets/subnet-container-apps
```

### 2. Custom Domains

```bash
# Add custom domain
az containerapp hostname add \
  --hostname www.mydomain.com \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade

# Bind SSL certificate
az containerapp ssl upload \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --hostname www.mydomain.com \
  --certificate-file ./certificate.pfx \
  --password certificatepassword
```

---

## Management and Operations

### 1. Container App Operations

```bash
# List container apps
az containerapp list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Get container app details
az containerapp show \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "{Name:name, FQDN:properties.configuration.ingress.fqdn, Replicas:properties.template.scale}"

# View logs
az containerapp logs show \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --follow

# Execute command in container
az containerapp exec \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --command /bin/bash
```

### 2. Environment Management

```bash
# List environments
az containerapp env list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Show environment details
az containerapp env show \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade

# Update environment
az containerapp env update \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade \
  --tags environment=production
```

---

## Best Practices

### 1. Resource Optimization

```bash
# Create resource-optimized container app
az containerapp create \
  --name optimized-app \
  --resource-group sa1_test_eic_SudarshanDarade \
  --environment container-apps-env \
  --image nginx:alpine \
  --target-port 80 \
  --ingress external \
  --cpu 0.25 \
  --memory 0.5Gi \
  --min-replicas 0 \
  --max-replicas 5 \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 10
```

### 2. Multi-Environment Setup

```bash
# Create development environment
az containerapp env create \
  --name container-apps-env-dev \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --logs-workspace-id $WORKSPACE_ID \
  --logs-workspace-key $WORKSPACE_KEY

# Create production environment
az containerapp env create \
  --name container-apps-env-prod \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --logs-workspace-id $WORKSPACE_ID \
  --logs-workspace-key $WORKSPACE_KEY
```

---

## Troubleshooting

### 1. Common Issues

```bash
# Check container app status
az containerapp show \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "properties.runningStatus"

# View revision history
az containerapp revision list \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "[].{Name:name, Active:properties.active, CreatedTime:properties.createdTime}"

# Check scaling metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.App/containerApps/webapp-simple \
  --metric "Replicas" \
  --interval PT1M
```

### 2. Diagnostic Commands

```bash
# Get environment diagnostics
az containerapp env show \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "properties.provisioningState"

# Check Dapr components
az containerapp env dapr-component list \
  --name container-apps-env \
  --resource-group sa1_test_eic_SudarshanDarade
```

---

## Cleanup

```bash
# Delete container apps
az containerapp delete \
  --name webapp-simple \
  --resource-group sa1_test_eic_SudarshanDarade \
  --yes

# Delete jobs
az containerapp job delete \
  --name scheduled-job \
  --resource-group sa1_test_eic_SudarshanDarade \
  --yes

# Delete environment
az containerapp env delete \
  --name container-apps-env \
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
- Understanding Azure Container Apps and its benefits
- Creating container apps environments and applications
- Auto-scaling configuration with various triggers
- Traffic management and blue-green deployments
- Microservices architecture implementation
- Dapr integration for distributed applications
- Jobs for scheduled and event-driven processing
- Security, authentication, and secrets management
- Monitoring, observability, and health probes
- Networking, custom domains, and VNet integration
- Best practices and troubleshooting

Azure Container Apps provides a powerful serverless container platform ideal for microservices, APIs, and event-driven applications with built-in scaling, traffic management, and observability.
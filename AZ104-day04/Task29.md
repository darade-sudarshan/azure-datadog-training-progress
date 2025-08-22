# Task 29: Azure Storage Account - Data Transfer and Network Security

## Copying Data to Storage Account

### Methods for Data Transfer

#### 1. Azure Portal Upload
- **Use case**: Small files, occasional uploads
- **Limitations**: File size limits, browser-dependent
- **Process**: Drag and drop or browse files

#### 2. Azure Storage Explorer
- **Use case**: GUI-based management
- **Features**: Cross-platform, bulk operations
- **Download**: https://azure.microsoft.com/features/storage-explorer/

#### 3. Azure CLI
```bash
# Upload single file
az storage blob upload \
    --file ./localfile.txt \
    --name remotefile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount

# Upload directory
az storage blob upload-batch \
    --source ./local-folder \
    --destination mycontainer \
    --account-name mystorageaccount
```

#### 4. PowerShell
```powershell
# Upload file
Set-AzStorageBlobContent \
    -File ".\localfile.txt" \
    -Container "mycontainer" \
    -Blob "remotefile.txt" \
    -Context $ctx

# Upload multiple files
Get-ChildItem ".\local-folder" -Recurse | Set-AzStorageBlobContent -Container "mycontainer" -Context $ctx
```

## AzCopy Tool

### What is AzCopy?

AzCopy is a command-line utility for copying data to and from Azure Storage. It's optimized for high-performance data transfer with features like parallel uploads, resume capability, and cross-platform support.

### Installation

#### Windows:
```cmd
# Download and install AzCopy
# Available at: https://aka.ms/downloadazcopy-v10-windows
```

#### Linux:
```bash
# Download AzCopy
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
```

#### macOS:
```bash
# Download AzCopy
wget https://aka.ms/downloadazcopy-v10-mac
tar -xvf downloadazcopy-v10-mac
sudo cp ./azcopy_darwin_amd64_*/azcopy /usr/local/bin/
```

### Authentication Methods

#### 1. Azure AD Authentication:
```bash
# Login with Azure AD
azcopy login

# Login with service principal
azcopy login --service-principal --application-id <app-id> --tenant-id <tenant-id>
```

#### 2. SAS Token:
```bash
# Use SAS token in URL
azcopy copy "source" "https://mystorageaccount.blob.core.windows.net/container?<sas-token>"
```

#### 3. Storage Account Key:
```bash
# Set environment variable
export AZCOPY_AUTO_LOGIN_TYPE=SPN
export AZURE_STORAGE_ACCOUNT=mystorageaccount
export AZURE_STORAGE_KEY=<storage-key>
```

### AzCopy Use Cases and Examples

#### 1. Upload Files to Blob Storage

##### Single File Upload:
```bash
# Upload single file
azcopy copy "./localfile.txt" "https://mystorageaccount.blob.core.windows.net/mycontainer/remotefile.txt"
```

##### Directory Upload:
```bash
# Upload entire directory
azcopy copy "./local-folder" "https://mystorageaccount.blob.core.windows.net/mycontainer/" --recursive

# Upload with pattern matching
azcopy copy "./local-folder/*.txt" "https://mystorageaccount.blob.core.windows.net/mycontainer/"
```

##### Large File Upload with Options:
```bash
# Upload with advanced options
azcopy copy "./largefile.zip" "https://mystorageaccount.blob.core.windows.net/mycontainer/" \
    --block-size-mb 100 \
    --blob-type BlockBlob \
    --metadata "project=demo;environment=prod"
```

#### 2. Download from Blob Storage

##### Single File Download:
```bash
# Download single file
azcopy copy "https://mystorageaccount.blob.core.windows.net/mycontainer/remotefile.txt" "./localfile.txt"
```

##### Directory Download:
```bash
# Download entire container
azcopy copy "https://mystorageaccount.blob.core.windows.net/mycontainer/" "./local-folder" --recursive

# Download with filters
azcopy copy "https://mystorageaccount.blob.core.windows.net/mycontainer/" "./local-folder" \
    --include-pattern "*.pdf;*.docx" \
    --recursive
```

#### 3. Copy Between Storage Accounts

##### Account to Account Copy:
```bash
# Copy between storage accounts
azcopy copy "https://sourcestorageaccount.blob.core.windows.net/sourcecontainer/" \
           "https://deststorageaccount.blob.core.windows.net/destcontainer/" \
           --recursive
```

##### Cross-Region Copy:
```bash
# Copy with server-side copy (faster for large files)
azcopy copy "https://sourcestorageaccount.blob.core.windows.net/sourcecontainer/" \
           "https://deststorageaccount.blob.core.windows.net/destcontainer/" \
           --recursive \
           --s2s-preserve-access-tier=false
```

#### 4. Sync Operations

##### One-way Sync:
```bash
# Sync local folder to blob storage
azcopy sync "./local-folder" "https://mystorageaccount.blob.core.windows.net/mycontainer/" \
    --recursive \
    --delete-destination=true
```

##### Incremental Sync:
```bash
# Sync only changed files
azcopy sync "./local-folder" "https://mystorageaccount.blob.core.windows.net/mycontainer/" \
    --recursive \
    --compare-hash=MD5
```

#### 5. File Share Operations

##### Upload to File Share:
```bash
# Upload to Azure File Share
azcopy copy "./local-folder" "https://mystorageaccount.file.core.windows.net/myfileshare/" \
    --recursive
```

##### Download from File Share:
```bash
# Download from Azure File Share
azcopy copy "https://mystorageaccount.file.core.windows.net/myfileshare/" "./local-folder" \
    --recursive
```

#### 6. Advanced Use Cases

##### Resume Failed Transfer:
```bash
# Resume interrupted transfer
azcopy jobs resume <job-id>

# List active jobs
azcopy jobs list
```

##### Parallel Transfer Optimization:
```bash
# Configure concurrency
azcopy copy "./large-dataset/" "https://mystorageaccount.blob.core.windows.net/mycontainer/" \
    --recursive \
    --cap-mbps 1000 \
    --concurrency-value 16
```

##### Dry Run:
```bash
# Test copy operation without actual transfer
azcopy copy "./local-folder" "https://mystorageaccount.blob.core.windows.net/mycontainer/" \
    --recursive \
    --dry-run
```

## Storage Account Firewall and Network Settings

### Network Access Control

#### Default Network Access:
- **Allow all networks**: Default setting
- **Allow selected networks**: Restrict access
- **Disable public access**: Private endpoints only

### Configuring Firewall Rules

#### Azure CLI:
```bash
# Set default action to deny
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --default-action Deny

# Add IP address rule
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group myRG \
    --ip-address 203.0.113.0

# Add IP range rule
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group myRG \
    --ip-address 203.0.113.0/24

# Add virtual network rule
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group myRG \
    --vnet-name myvnet \
    --subnet mysubnet
```

#### PowerShell:
```powershell
# Set network access rules
Set-AzStorageAccount \
    -ResourceGroupName "myRG" \
    -Name "mystorageaccount" \
    -NetworkRuleSet (@{
        defaultAction="Deny";
        ipRules=(@{IPAddressOrRange="203.0.113.0/24";Action="allow"});
        virtualNetworkRules=(@{VirtualNetworkResourceId="/subscriptions/.../subnets/mysubnet";Action="allow"})
    })
```

#### ARM Template:
```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "properties": {
    "networkAcls": {
      "defaultAction": "Deny",
      "ipRules": [
        {
          "value": "203.0.113.0/24",
          "action": "Allow"
        }
      ],
      "virtualNetworkRules": [
        {
          "id": "/subscriptions/.../subnets/mysubnet",
          "action": "Allow"
        }
      ]
    }
  }
}
```

### Trusted Microsoft Services

#### Allow Trusted Services:
```bash
# Allow trusted Microsoft services
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --bypass AzureServices
```

#### Trusted Services Include:
- **Azure Backup**
- **Azure Site Recovery**
- **Azure DevTest Labs**
- **Azure Event Grid**
- **Azure Log Analytics**
- **Azure Monitor**

## Service Endpoints

### What are Service Endpoints?

Service endpoints provide secure and direct connectivity to Azure services over the Azure backbone network, eliminating the need for internet routing.

### Configuring Service Endpoints

#### Create VNet with Service Endpoint:
```bash
# Create virtual network
az network vnet create \
    --name myvnet \
    --resource-group myRG \
    --address-prefix 10.0.0.0/16

# Create subnet with service endpoint
az network vnet subnet create \
    --name mysubnet \
    --vnet-name myvnet \
    --resource-group myRG \
    --address-prefix 10.0.1.0/24 \
    --service-endpoints Microsoft.Storage
```

#### Add Service Endpoint to Existing Subnet:
```bash
# Add service endpoint to existing subnet
az network vnet subnet update \
    --name mysubnet \
    --vnet-name myvnet \
    --resource-group myRG \
    --service-endpoints Microsoft.Storage
```

#### Configure Storage Account for Service Endpoint:
```bash
# Add VNet rule to storage account
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group myRG \
    --vnet-name myvnet \
    --subnet mysubnet
```

### Service Endpoint Policies

#### Create Service Endpoint Policy:
```bash
# Create service endpoint policy
az network service-endpoint policy create \
    --name mystorageendpointpolicy \
    --resource-group myRG

# Add policy definition
az network service-endpoint policy-definition create \
    --policy-name mystorageendpointpolicy \
    --resource-group myRG \
    --name allowspecificstorage \
    --service Microsoft.Storage \
    --service-resources /subscriptions/.../storageAccounts/mystorageaccount
```

## Private Endpoints

### What are Private Endpoints?

Private endpoints provide private connectivity to Azure Storage using a private IP address from your VNet, effectively bringing the service into your VNet.

### Creating Private Endpoints

#### Azure CLI:
```bash
# Create private endpoint
az network private-endpoint create \
    --name mystoragepe \
    --resource-group myRG \
    --vnet-name myvnet \
    --subnet mysubnet \
    --private-connection-resource-id /subscriptions/.../storageAccounts/mystorageaccount \
    --group-id blob \
    --connection-name mystorageconnection

# Create private DNS zone
az network private-dns zone create \
    --name privatelink.blob.core.windows.net \
    --resource-group myRG

# Link DNS zone to VNet
az network private-dns link vnet create \
    --name mystoragelink \
    --resource-group myRG \
    --zone-name privatelink.blob.core.windows.net \
    --virtual-network myvnet \
    --registration-enabled false
```

#### PowerShell:
```powershell
# Create private endpoint
$pe = New-AzPrivateEndpoint \
    -Name "mystoragepe" \
    -ResourceGroupName "myRG" \
    -Location "East US" \
    -Subnet $subnet \
    -PrivateLinkServiceConnection $plsConnection

# Create private DNS zone
New-AzPrivateDnsZone -Name "privatelink.blob.core.windows.net" -ResourceGroupName "myRG"
```

### Private Endpoint Sub-resources

#### Available Sub-resources:
- **blob**: Blob service
- **file**: File service
- **queue**: Queue service
- **table**: Table service
- **web**: Static website
- **dfs**: Data Lake Storage Gen2

#### Multiple Private Endpoints:
```bash
# Create private endpoint for blob service
az network private-endpoint create \
    --name mystoragepe-blob \
    --resource-group myRG \
    --vnet-name myvnet \
    --subnet mysubnet \
    --private-connection-resource-id /subscriptions/.../storageAccounts/mystorageaccount \
    --group-id blob \
    --connection-name blobconnection

# Create private endpoint for file service
az network private-endpoint create \
    --name mystoragepe-file \
    --resource-group myRG \
    --vnet-name myvnet \
    --subnet mysubnet \
    --private-connection-resource-id /subscriptions/.../storageAccounts/mystorageaccount \
    --group-id file \
    --connection-name fileconnection
```

## Network Routing

### Routing Preference Options

#### 1. Microsoft Network Routing (Default)
- **Path**: Traffic routed through Microsoft's global network
- **Benefits**: Lower latency, higher reliability
- **Cost**: Standard pricing

#### 2. Internet Routing
- **Path**: Traffic routed through public internet
- **Benefits**: Lower cost
- **Trade-offs**: Potentially higher latency

### Configuring Network Routing

#### Set Routing Preference:
```bash
# Set routing preference to Internet
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --routing-choice InternetRouting

# Set routing preference to Microsoft Network
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --routing-choice MicrosoftRouting
```

#### PowerShell:
```powershell
# Set routing preference
Set-AzStorageAccount \
    -ResourceGroupName "myRG" \
    -Name "mystorageaccount" \
    -RoutingChoice "InternetRouting"
```

### Publishing Route-specific Endpoints

#### Enable Route-specific Endpoints:
```bash
# Enable internet routing endpoint
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --publish-internet-endpoints true

# Enable Microsoft routing endpoint
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --publish-microsoft-endpoints true
```

#### Endpoint URLs:
- **Internet routing**: `mystorageaccount-internetrouting.blob.core.windows.net`
- **Microsoft routing**: `mystorageaccount-microsoftrouting.blob.core.windows.net`

## Best Practices

### Data Transfer:
1. **Use AzCopy** for large-scale data transfers
2. **Implement retry logic** for resilience
3. **Optimize concurrency** based on network capacity
4. **Use server-side copy** for cross-account transfers
5. **Monitor transfer progress** and performance

### Network Security:
1. **Implement least privilege** access
2. **Use private endpoints** for sensitive workloads
3. **Configure firewall rules** appropriately
4. **Enable trusted services** only when needed
5. **Regular security audits** of network configurations

### Performance Optimization:
1. **Choose appropriate routing** based on requirements
2. **Use service endpoints** for VNet-based access
3. **Optimize network topology** for data flows
4. **Monitor network metrics** and latency
5. **Consider regional placement** for performance

### Cost Management:
1. **Evaluate routing costs** vs performance benefits
2. **Monitor data transfer charges**
3. **Optimize transfer patterns** to reduce costs
4. **Use appropriate storage tiers** for access patterns

## Monitoring and Troubleshooting

### Network Monitoring:
```bash
# Check network rules
az storage account show \
    --name mystorageaccount \
    --resource-group myRG \
    --query networkRuleSet

# Test connectivity
az storage blob list \
    --container-name mycontainer \
    --account-name mystorageaccount
```

### Common Issues:
- **Access denied**: Check firewall rules and network ACLs
- **Slow transfers**: Verify routing preference and network capacity
- **DNS resolution**: Ensure private DNS zones are configured correctly
- **Authentication**: Verify credentials and permissions
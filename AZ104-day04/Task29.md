# Task 29: Azure Storage Account - Data Transfer and Network Security

---

## Method 1: Using Azure Portal (GUI)

### Step 1: Access Storage Account

1. **Navigate to Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with your Azure credentials

2. **Find Your Storage Account**
   - Click "Storage accounts" in the left menu
   - Select your existing storage account
   - Or create a new one if needed

### Step 2: Upload Data via Azure Portal

#### Basic File Upload

1. **Navigate to Blob Container**
   - Click "Containers" under "Data storage"
   - Select existing container or create new one
   - Click "+ Container" if creating new:
     - **Name**: `data-uploads`
     - **Public access level**: `Private`
     - Click "Create"

2. **Upload Files**
   - Click on container name
   - Click "Upload" in the toolbar
   - **Upload blob** dialog opens

3. **Select Files for Upload**
   - Click "Browse for files" or drag and drop
   - Select single or multiple files
   - **Advanced options**:
     - **Blob type**: `Block blob` (default)
     - **Block size**: `4 MB` (default)
     - **Access tier**: `Hot`, `Cool`, or `Archive`
     - **Upload to folder**: Specify virtual folder path
   - Click "Upload"

4. **Monitor Upload Progress**
   - View progress bar for each file
   - Cancel uploads if needed
   - Retry failed uploads

#### Bulk Upload via Portal

1. **Upload Multiple Files**
   - Select multiple files using Ctrl+Click
   - Or drag entire folders to maintain structure
   - Portal preserves folder hierarchy

2. **Large File Upload**
   - Portal supports files up to 4.75 TB
   - Automatic chunking for large files
   - Resume capability for interrupted uploads

### Step 3: Configure Storage Account Firewall

#### Access Network Settings

1. **Navigate to Networking**
   - In storage account, click "Networking" under "Security + networking"
   - View current network access configuration

2. **Configure Public Network Access**
   - **Public network access**: Choose option:
     - `Enabled from all networks` - Default, allows all internet access
     - `Enabled from selected virtual networks and IP addresses` - Restricted access
     - `Disabled` - Private endpoints only

#### Configure Firewall Rules

1. **Set Up IP Address Rules**
   - Select "Enabled from selected virtual networks and IP addresses"
   - **Firewall** section appears
   - **Add your client IP address**: ☑ Check to add current IP
   - **Address range**: Add custom IP ranges:
     - **Name**: `Office Network`
     - **Address range**: `203.0.113.0/24`
     - Click "Add"

2. **Configure Virtual Network Rules**
   - **Virtual networks** section
   - Click "+ Add existing virtual network"
   - **Subscription**: Select subscription
   - **Virtual networks**: Select VNet
   - **Subnets**: Select subnet(s)
   - **Note**: Subnet must have Microsoft.Storage service endpoint
   - Click "Add"

3. **Configure Exceptions**
   - **Exceptions** section:
     - ☑ Allow Azure services on the trusted services list to access this storage account
     - ☑ Allow read access to storage logging from any network
     - ☑ Allow read access to storage metrics from any network

4. **Save Configuration**
   - Click "Save" to apply firewall rules
   - **Warning**: May take up to 5 minutes to take effect

### Step 4: Configure Service Endpoints

#### Create Virtual Network with Service Endpoint

1. **Navigate to Virtual Networks**
   - Search "Virtual networks" in portal
   - Click "+ Create" or select existing VNet

2. **Configure Service Endpoints**
   - Go to existing VNet → "Subnets"
   - Click on subnet name
   - **Service endpoints**: Click "+ Add"
   - **Services**: Select `Microsoft.Storage`
   - Click "Add"
   - Click "Save"

#### Add VNet to Storage Account

1. **Return to Storage Account Networking**
   - Go back to storage account → "Networking"
   - **Virtual networks** section
   - Click "+ Add existing virtual network"
   - Select VNet and subnet with service endpoint
   - Click "Add"

### Step 5: Configure Private Endpoints

#### Create Private Endpoint

1. **Navigate to Private Endpoint Connections**
   - In storage account, click "Private endpoint connections" under "Security + networking"
   - Click "+ Private endpoint"

2. **Configure Private Endpoint Basics**
   - **Subscription**: Select subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `storage-private-endpoint`
   - **Region**: `Southeast Asia`
   - Click "Next: Resource >"

3. **Configure Resource Settings**
   - **Connection method**: `Connect to an Azure resource in my directory`
   - **Subscription**: Select subscription
   - **Resource type**: `Microsoft.Storage/storageAccounts`
   - **Resource**: Select your storage account
   - **Target sub-resource**: Select service:
     - `blob` - Blob service
     - `file` - File service
     - `queue` - Queue service
     - `table` - Table service
   - Click "Next: Virtual Network >"

4. **Configure Virtual Network**
   - **Virtual network**: Select VNet
   - **Subnet**: Select subnet for private endpoint
   - **Private IP configuration**: `Dynamically allocate IP address`
   - **Application security group**: None (optional)
   - Click "Next: DNS >"

5. **Configure DNS**
   - **Integrate with private DNS zone**: `Yes`
   - **Private DNS zone**: `privatelink.blob.core.windows.net` (auto-created)
   - **Resource group**: Select resource group for DNS zone
   - Click "Next: Tags >"

6. **Add Tags and Create**
   - Add tags if needed
   - Click "Review + create"
   - Click "Create"

#### Verify Private Endpoint

1. **Check Connection Status**
   - Go to "Private endpoint connections"
   - Verify connection state is "Approved"
   - Note private IP address assigned

2. **Test Private Connectivity**
   - From VM in same VNet, test DNS resolution:
   - `nslookup [storageaccount].blob.core.windows.net`
   - Should resolve to private IP address

### Step 6: Configure Network Routing

#### Set Routing Preference

1. **Navigate to Networking**
   - Go to storage account → "Networking"
   - Scroll to "Network routing" section

2. **Configure Routing Options**
   - **Routing preference**: Choose option:
     - `Microsoft network routing` - Default, uses Microsoft's global network
     - `Internet routing` - Uses public internet, lower cost
   - **Publish route-specific endpoints**: 
     - ☑ Publish Microsoft network routing endpoint
     - ☑ Publish Internet routing endpoint
   - Click "Save"

3. **View Route-Specific Endpoints**
   - **Microsoft routing endpoint**: `[account]-microsoftrouting.blob.core.windows.net`
   - **Internet routing endpoint**: `[account]-internetrouting.blob.core.windows.net`
   - Use specific endpoints for targeted routing

### Step 7: Use Azure Storage Explorer

#### Download and Install

1. **Download Storage Explorer**
   - Go to https://azure.microsoft.com/features/storage-explorer/
   - Download for your platform (Windows, macOS, Linux)
   - Install the application

2. **Connect to Storage Account**
   - Open Azure Storage Explorer
   - Click "Add an account" or connection icon
   - **Select Resource**: `Storage account or service`
   - **Select Connection Method**: `Account name and key`
   - **Account name**: Enter storage account name
   - **Account key**: Copy from portal (Access keys)
   - Click "Next" and "Connect"

#### Manage Data with Storage Explorer

1. **Navigate Storage Account**
   - Expand storage account in left panel
   - View Blob Containers, File Shares, Queues, Tables
   - Browse folder structure

2. **Upload Files**
   - Right-click container or folder
   - Select "Upload" → "Upload Files" or "Upload Folder"
   - Select files/folders to upload
   - Configure upload options:
     - **Blob type**: Block blob, Page blob, Append blob
     - **Access tier**: Hot, Cool, Archive
     - **Metadata**: Add custom metadata
   - Click "Upload"

3. **Download Files**
   - Right-click blob or folder
   - Select "Download" or "Download As"
   - Choose destination folder
   - Monitor download progress

4. **Copy Between Accounts**
   - Connect multiple storage accounts
   - Drag and drop between accounts
   - Or right-click → "Copy" → paste in destination

### Step 8: Monitor Data Transfer

#### View Transfer Metrics

1. **Navigate to Insights**
   - Go to storage account → "Insights" under "Monitoring"
   - **Transactions** tab shows:
     - Request count by operation
     - Success/failure rates
     - Response times

2. **Monitor Network Traffic**
   - **Capacity** tab shows:
     - Ingress (data uploaded)
     - Egress (data downloaded)
     - Total storage used
   - Filter by time range and service

#### Set Up Transfer Alerts

1. **Create Alert Rules**
   - Go to "Alerts" under "Monitoring"
   - Click "+ New alert rule"
   - **Condition**: Select metrics:
     - Ingress > threshold
     - Egress > threshold
     - Transactions > threshold
   - **Action group**: Configure notifications
   - **Alert rule name**: `High Data Transfer Alert`

### Step 9: Secure Data Transfer

#### Configure HTTPS Requirements

1. **Enable Secure Transfer**
   - Go to storage account → "Configuration"
   - **Secure transfer required**: `Enabled`
   - Forces all connections to use HTTPS/SMB 3.0+
   - Click "Save"

2. **Set Minimum TLS Version**
   - **Minimum TLS version**: `Version 1.2`
   - Ensures strong encryption for all connections
   - Click "Save"

#### Configure Access Keys Security

1. **Manage Access Keys**
   - Go to "Access keys" under "Security + networking"
   - **Allow storage account key access**: Control key-based access
   - **Regenerate keys**: Rotate keys regularly
   - **Copy keys**: Use for application configuration

2. **Configure Shared Access Signatures**
   - Go to "Shared access signature"
   - **Allowed services**: Select services (Blob, File, Queue, Table)
   - **Allowed resource types**: Service, Container, Object
   - **Allowed permissions**: Minimum required permissions
   - **Start and expiry date/time**: Set validity period
   - **Allowed IP addresses**: Restrict by IP (optional)
   - **Allowed protocols**: `HTTPS only`
   - Click "Generate SAS and connection string"

### Step 10: Troubleshoot Network Issues

#### Test Connectivity

1. **Check Network Rules**
   - Go to "Networking" → review firewall rules
   - Verify IP addresses and VNet rules
   - Check service endpoint configuration

2. **Test from Different Locations**
   - Test access from allowed IP ranges
   - Test from VNet with service endpoints
   - Test via private endpoints

#### Common Issues and Solutions

1. **Access Denied Errors**
   - **Check firewall rules**: Ensure client IP is allowed
   - **Verify VNet rules**: Confirm subnet has service endpoint
   - **Review private endpoint**: Check DNS resolution

2. **Slow Transfer Speeds**
   - **Check routing preference**: Consider Microsoft vs Internet routing
   - **Monitor network metrics**: Look for bottlenecks
   - **Optimize client location**: Use regional storage accounts

3. **DNS Resolution Issues**
   - **Private endpoints**: Verify private DNS zone configuration
   - **Service endpoints**: Check VNet DNS settings
   - **Public access**: Confirm public DNS resolution

### Step 11: Advanced Data Transfer Options

#### Configure Cross-Region Replication

1. **Set Up Geo-Replication**
   - Go to storage account → "Geo-replication"
   - View primary and secondary regions
   - **Redundancy**: Ensure GRS or RA-GRS is selected
   - Monitor replication status

2. **Test Secondary Access** (RA-GRS only)
   - **Secondary endpoint**: `[account]-secondary.blob.core.windows.net`
   - Test read access to secondary region
   - Use for disaster recovery scenarios

#### Configure Object Replication

1. **Set Up Object Replication**
   - Go to "Object replication" under "Data management"
   - Click "Create replication rules"
   - **Source account**: Current account
   - **Destination account**: Select target account
   - **Container mapping**: Configure source and destination containers
   - **Filters**: Set blob prefix filters if needed
   - Click "Create"

2. **Monitor Replication**
   - View replication policies and status
   - Check replication lag and errors
   - Monitor bandwidth usage

---

## Method 2: Using Azure CLI and Tools

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
    --resource-group sa1_test_eic_SudarshanDarade \
    --default-action Deny

# Add IP address rule
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --ip-address 203.0.113.0

# Add IP range rule
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --ip-address 203.0.113.0/24

# Add virtual network rule
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --vnet-name myvnet \
    --subnet mysubnet
```

#### PowerShell:
```powershell
# Set network access rules
Set-AzStorageAccount \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
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
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
    --address-prefix 10.0.0.0/16

# Create subnet with service endpoint
az network vnet subnet create \
    --name mysubnet \
    --vnet-name myvnet \
    --resource-group sa1_test_eic_SudarshanDarade \
    --address-prefix 10.0.1.0/24 \
    --service-endpoints Microsoft.Storage
```

#### Add Service Endpoint to Existing Subnet:
```bash
# Add service endpoint to existing subnet
az network vnet subnet update \
    --name mysubnet \
    --vnet-name myvnet \
    --resource-group sa1_test_eic_SudarshanDarade \
    --service-endpoints Microsoft.Storage
```

#### Configure Storage Account for Service Endpoint:
```bash
# Add VNet rule to storage account
az storage account network-rule add \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --vnet-name myvnet \
    --subnet mysubnet
```

### Service Endpoint Policies

#### Create Service Endpoint Policy:
```bash
# Create service endpoint policy
az network service-endpoint policy create \
    --name mystorageendpointpolicy \
    --resource-group sa1_test_eic_SudarshanDarade

# Add policy definition
az network service-endpoint policy-definition create \
    --policy-name mystorageendpointpolicy \
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
    --vnet-name myvnet \
    --subnet mysubnet \
    --private-connection-resource-id /subscriptions/.../storageAccounts/mystorageaccount \
    --group-id blob \
    --connection-name mystorageconnection

# Create private DNS zone
az network private-dns zone create \
    --name privatelink.blob.core.windows.net \
    --resource-group sa1_test_eic_SudarshanDarade

# Link DNS zone to VNet
az network private-dns link vnet create \
    --name mystoragelink \
    --resource-group sa1_test_eic_SudarshanDarade \
    --zone-name privatelink.blob.core.windows.net \
    --virtual-network myvnet \
    --registration-enabled false
```

#### PowerShell:
```powershell
# Create private endpoint
$pe = New-AzPrivateEndpoint \
    -Name "mystoragepe" \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -Location "East US" \
    -Subnet $subnet \
    -PrivateLinkServiceConnection $plsConnection

# Create private DNS zone
New-AzPrivateDnsZone -Name "privatelink.blob.core.windows.net" -ResourceGroupName "sa1_test_eic_SudarshanDarade"
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
    --resource-group sa1_test_eic_SudarshanDarade \
    --vnet-name myvnet \
    --subnet mysubnet \
    --private-connection-resource-id /subscriptions/.../storageAccounts/mystorageaccount \
    --group-id blob \
    --connection-name blobconnection

# Create private endpoint for file service
az network private-endpoint create \
    --name mystoragepe-file \
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
    --routing-choice InternetRouting

# Set routing preference to Microsoft Network
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --routing-choice MicrosoftRouting
```

#### PowerShell:
```powershell
# Set routing preference
Set-AzStorageAccount \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -Name "mystorageaccount" \
    -RoutingChoice "InternetRouting"
```

### Publishing Route-specific Endpoints

#### Enable Route-specific Endpoints:
```bash
# Enable internet routing endpoint
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --publish-internet-endpoints true

# Enable Microsoft routing endpoint
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
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
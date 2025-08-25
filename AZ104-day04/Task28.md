# Task 28: Azure File Share

## What is Azure File Share?

Azure File Share provides fully managed file shares in the cloud accessible via Server Message Block (SMB) and Network File System (NFS) protocols. It offers shared storage that can be mounted on Windows, Linux, and macOS systems.

## Key Features:
- **SMB 2.1, 3.0, and 3.1.1** protocol support
- **NFS 4.1** protocol support (preview)
- **Cross-platform** compatibility
- **Concurrent access** from multiple clients
- **Integration** with on-premises Active Directory
- **Backup and restore** capabilities

## File Share Types

### Standard File Shares
- **Storage**: HDD-based
- **Performance**: Up to 1,000 IOPS
- **Size**: Up to 100 TiB
- **Protocols**: SMB, NFS
- **Redundancy**: LRS, ZRS, GRS, GZRS

### Premium File Shares
- **Storage**: SSD-based
- **Performance**: Up to 100,000 IOPS
- **Size**: Up to 100 TiB
- **Protocols**: SMB, NFS
- **Redundancy**: LRS, ZRS only

## Steps to Create Azure File Share

---

## Method 1: Using Azure Portal (GUI)

### Step 1: Access Azure Portal

1. **Navigate to Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with your Azure credentials

2. **Find Storage Account**
   - Click "Storage accounts" in the left menu
   - Select existing storage account or create new one

### Step 2: Create Storage Account (if needed)

1. **Create New Storage Account**
   - Click "+ Create" if no suitable storage account exists
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Storage account name**: `fileshareaccount[unique-suffix]`
   - **Region**: `Southeast Asia`
   - **Performance**: Choose based on needs:
     - `Standard` - HDD-based, up to 1,000 IOPS
     - `Premium` - SSD-based, up to 100,000 IOPS
   - **Redundancy**: Select appropriate option:
     - `LRS` - Locally redundant (lowest cost)
     - `ZRS` - Zone redundant (higher availability)
     - `GRS` - Geo-redundant (regional protection)
   - Click "Review + create" → "Create"

### Step 3: Create File Share

#### Navigate to File Shares

1. **Access Storage Account**
   - Go to your storage account
   - Click "File shares" under "Data storage" in the left menu

2. **Create New File Share**
   - Click "+ File share"
   - **File share creation** dialog opens

#### Configure File Share Settings

1. **Basic Configuration**
   - **Name**: `company-documents` (3-63 characters, lowercase)
   - **Tier**: Select based on access pattern:
     - `Transaction optimized` - High transaction workloads
     - `Hot` - Frequently accessed data
     - `Cool` - Infrequently accessed data (30+ days)
   - **Quota**: Set maximum size (e.g., `100 GB`)
     - Standard: Up to 100 TiB
     - Premium: Up to 100 TiB with provisioned IOPS

2. **Advanced Options** (Click "Advanced")
   - **Protocol**: 
     - `SMB` - Windows/Linux/macOS compatibility
     - `NFS` - Linux/Unix systems (Premium only)
   - **Root squash**: For NFS shares
     - `No root squash` - Root access preserved
     - `Root squash` - Root mapped to anonymous user
     - `All squash` - All users mapped to anonymous

3. **Create File Share**
   - Click "Create"
   - File share appears in the list

### Step 4: Configure File Share Properties

#### Access File Share Settings

1. **Navigate to File Share**
   - Click on the created file share name
   - View file share overview and properties

2. **Modify Properties**
   - Click "Properties" in the left menu
   - **Quota**: Modify maximum size if needed
   - **Tier**: Change access tier
   - **Last modified**: View last modification time
   - **URL**: Copy file share URL

#### Configure Access Policy

1. **Set Access Policy**
   - Click "Access policy" in the left menu
   - Click "+ Add policy"
   - **Identifier**: `read-write-policy`
   - **Permissions**: Select required permissions:
     - ☑ Read - Read files and directories
     - ☑ Create - Create files and directories
     - ☑ Write - Write to files
     - ☑ Delete - Delete files and directories
     - ☑ List - List files and directories
   - **Start time**: Set when policy becomes active
   - **Expiry time**: Set when policy expires
   - Click "OK" and "Save"

### Step 5: Upload Files and Create Directories

#### Upload Files via Portal

1. **Navigate to File Share Content**
   - Click on file share name
   - View current contents (empty initially)

2. **Upload Files**
   - Click "Upload" in the toolbar
   - **Upload files** dialog opens
   - Click "Browse for files" or drag and drop
   - Select single or multiple files
   - **Overwrite if files already exist**: Check if needed
   - Click "Upload"

3. **Monitor Upload Progress**
   - View upload progress for each file
   - Files appear in the file share when complete

#### Create Directory Structure

1. **Create New Directory**
   - Click "Add Directory" in the toolbar
   - **Directory name**: `departments`
   - Click "OK"

2. **Navigate Directory Structure**
   - Click on directory name to enter
   - Use breadcrumb navigation to go back
   - Create subdirectories as needed:
     ```
     company-documents/
     ├── departments/
     │   ├── hr/
     │   ├── finance/
     │   └── it/
     ├── projects/
     └── shared/
     ```

3. **Upload Files to Directories**
   - Navigate to specific directory
   - Upload files directly to that location

### Step 6: Connect and Mount File Share

#### Get Connection Information

1. **Access Connect Dialog**
   - Click "Connect" in the file share toolbar
   - **Connect** dialog shows platform-specific instructions

2. **Choose Platform**
   - **Windows**: PowerShell and Command Prompt scripts
   - **Linux**: Bash mounting commands
   - **macOS**: Terminal mounting commands

#### Windows Connection

1. **PowerShell Method**
   - Copy the provided PowerShell script:
   ```powershell
   # Connect using PowerShell
   $connectTestResult = Test-NetConnection -ComputerName "fileshareaccount.file.core.windows.net" -Port 445
   if ($connectTestResult.TcpTestSucceeded) {
       cmd.exe /C "cmdkey /add:`"fileshareaccount.file.core.windows.net`" /user:`"Azure\fileshareaccount`" /pass:`"[storage-key]""
       New-PSDrive -Name Z -PSProvider FileSystem -Root "\\fileshareaccount.file.core.windows.net\company-documents" -Persist
   }
   ```
   - Run in PowerShell as Administrator
   - File share mounts as Z: drive

2. **Command Prompt Method**
   ```cmd
   net use Z: \\fileshareaccount.file.core.windows.net\company-documents /persistent:yes
   ```

3. **File Explorer Method**
   - Open File Explorer
   - Right-click "This PC" → "Map network drive"
   - **Drive**: `Z:`
   - **Folder**: `\\fileshareaccount.file.core.windows.net\company-documents`
   - **Connect using different credentials**: Check
   - **User name**: `Azure\fileshareaccount`
   - **Password**: Storage account key

#### Linux Connection

1. **Install Required Packages**
   ```bash
   sudo apt-get update
   sudo apt-get install cifs-utils
   ```

2. **Create Mount Point**
   ```bash
   sudo mkdir /mnt/company-documents
   ```

3. **Mount File Share**
   ```bash
   sudo mount -t cifs //fileshareaccount.file.core.windows.net/company-documents /mnt/company-documents -o vers=3.0,username=fileshareaccount,password=[storage-key],dir_mode=0777,file_mode=0777,serverino
   ```

4. **Persistent Mount** (add to /etc/fstab)
   ```bash
   echo "//fileshareaccount.file.core.windows.net/company-documents /mnt/company-documents cifs vers=3.0,username=fileshareaccount,password=[storage-key],dir_mode=0777,file_mode=0777,serverino" | sudo tee -a /etc/fstab
   ```

#### macOS Connection

1. **Finder Method**
   - Open Finder
   - Press `Cmd+K` (Connect to Server)
   - **Server Address**: `smb://fileshareaccount.file.core.windows.net/company-documents`
   - **Username**: `fileshareaccount`
   - **Password**: Storage account key

2. **Terminal Method**
   ```bash
   mkdir ~/company-documents
   mount -t smbfs //fileshareaccount:[storage-key]@fileshareaccount.file.core.windows.net/company-documents ~/company-documents
   ```

### Step 7: Configure Soft Delete Protection

#### Enable Soft Delete

1. **Navigate to Data Protection**
   - Go to storage account level
   - Click "Data protection" under "Data management"

2. **Configure File Share Soft Delete**
   - **Soft delete for file shares**: ☑ Enable
   - **Retention period**: `7 days` (1-365 days available)
   - Click "Save"

3. **Understand Soft Delete Behavior**
   - Deleted file shares retained for specified period
   - Can be restored during retention period
   - Billing continues for soft deleted data

#### Manage Soft Deleted Shares

1. **View Deleted Shares**
   - In "File shares" section
   - Click "Show deleted shares" toggle
   - Deleted shares appear with deletion timestamp

2. **Restore Deleted Share**
   - Click on deleted file share
   - Click "Restore" in the toolbar
   - **New name**: Keep original or specify new name
   - Click "Restore"
   - Share restored with all content

### Step 8: Configure Encryption and Security

#### Encryption Settings

1. **View Encryption Status**
   - Go to storage account → "Encryption"
   - **Encryption type**: View current setting
     - `Microsoft-managed keys` (default)
     - `Customer-managed keys`
   - **Infrastructure encryption**: Additional layer

2. **Configure Customer-Managed Keys** (if needed)
   - **Key management**: `Azure Key Vault`
   - **Key vault**: Select or create Key Vault
   - **Key**: Select encryption key
   - **Version**: Select key version
   - Click "Save"

#### Network Security

1. **Configure Firewall**
   - Go to "Networking" under "Security + networking"
   - **Public network access**: Choose option:
     - `Enabled from all networks`
     - `Enabled from selected virtual networks and IP addresses`
     - `Disabled`
   - **Virtual networks**: Add allowed VNets
   - **IP addresses**: Add allowed IP ranges

2. **Require Secure Transfer**
   - **Secure transfer required**: ☑ Enable
   - Forces HTTPS and SMB 3.0+ with encryption
   - Click "Save"

### Step 9: Create and Manage Snapshots

#### Create File Share Snapshot

1. **Navigate to Snapshots**
   - Go to file share → "Snapshots" in left menu
   - View existing snapshots (if any)

2. **Create New Snapshot**
   - Click "+ Add snapshot"
   - **Comment**: `Daily backup - $(date)`
   - Click "OK"
   - Snapshot created with timestamp

3. **Schedule Regular Snapshots**
   - Use Azure Backup for automated snapshots
   - Go to "Backup" in file share menu
   - Configure backup policy and schedule

#### Restore from Snapshot

1. **Browse Snapshot Content**
   - Click on snapshot timestamp
   - Browse files and directories in snapshot
   - View point-in-time state of file share

2. **Restore Individual Files**
   - Navigate to desired file in snapshot
   - Click "Restore" in toolbar
   - **Restore location**: 
     - `Original location` (overwrites current)
     - `Alternate location` (specify new path)
   - Click "Restore"

3. **Restore Entire Share**
   - Select snapshot
   - Click "Restore share"
   - **Warning**: Overwrites current share content
   - Confirm restoration

### Step 10: Monitor and Manage Performance

#### View File Share Metrics

1. **Access Metrics**
   - Go to file share → "Metrics" under "Monitoring"
   - View performance and usage metrics:
     - **Transactions**: Request count
     - **Ingress**: Data uploaded
     - **Egress**: Data downloaded
     - **Files**: Number of files
     - **File capacity**: Storage used

2. **Create Custom Dashboard**
   - Pin important metrics to dashboard
   - Set up custom time ranges
   - Compare multiple file shares

#### Configure Alerts

1. **Create Alert Rules**
   - Go to "Alerts" under "Monitoring"
   - Click "+ New alert rule"
   - **Condition**: Select metrics:
     - File capacity > 80% of quota
     - Transaction count > threshold
     - Availability < 99%
   - **Action group**: Configure notifications
   - **Alert rule name**: `File Share Capacity Alert`

### Step 11: Advanced Configuration

#### Configure Access Tiers

1. **Change File Share Tier**
   - Go to file share → "Configuration"
   - **Access tier**: Select new tier:
     - `Transaction optimized` - High transaction workloads
     - `Hot` - Frequently accessed ($0.0255/GB/month)
     - `Cool` - Infrequently accessed ($0.0152/GB/month)
   - Click "Save"
   - **Note**: Tier changes may take time to complete

#### Premium File Share Features

1. **Provisioned IOPS** (Premium only)
   - **Baseline IOPS**: 1 IOPS per GiB provisioned
   - **Burst IOPS**: Up to 4,000 IOPS for shares < 1 TiB
   - **Maximum IOPS**: Up to 100,000 IOPS

2. **Performance Monitoring**
   - Monitor IOPS utilization
   - Track burst credit consumption
   - Optimize share size for performance needs

### Step 12: Integration and Automation

#### Azure Backup Integration

1. **Enable Azure Backup**
   - Go to file share → "Backup"
   - Click "Configure Backup"
   - **Recovery Services vault**: Create or select vault
   - **Backup policy**: Choose or create policy
   - **Schedule**: Daily, weekly, monthly options
   - **Retention**: Configure retention periods
   - Click "Enable Backup"

2. **Monitor Backup Jobs**
   - View backup job status
   - Check backup success/failure
   - Restore from backup when needed

#### Active Directory Integration

1. **Enable AD Authentication**
   - Go to storage account → "Configuration"
   - **Azure Active Directory Domain Services**: Enable
   - **Identity-based access**: Configure
   - **NTFS permissions**: Set up on mounted shares

2. **Configure Share Permissions**
   - Mount share on domain-joined machine
   - Set NTFS permissions using Windows tools
   - Configure user and group access

---

## Method 2: Using Azure CLI

### Method 2: Azure CLI

#### Create Storage Account:
```bash
# Create storage account for file shares
az storage account create \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --location southeastasia \
    --sku Standard_LRS \
    --kind StorageV2
```

#### Create File Share:
```bash
# Create file share
az storage share create \
    --name myfileshare \
    --quota 1024 \
    --account-name mystorageaccount
```

#### Create Premium File Share:
```bash
# Create premium storage account
az storage account create \
    --name premiumstorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --location southeastasia \
    --sku Premium_LRS \
    --kind FileStorage

# Create premium file share
az storage share create \
    --name premiumfileshare \
    --quota 100 \
    --account-name premiumstorageaccount
```

### Method 3: PowerShell

#### Create File Share:
```powershell
# Get storage context
$ctx = (Get-AzStorageAccount -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "mystorageaccount").Context

# Create file share
New-AzStorageShare -Name "myfileshare" -Context $ctx -Quota 1024
```

### Method 4: ARM Template

```json
{
  "type": "Microsoft.Storage/storageAccounts/fileServices/shares",
  "apiVersion": "2021-04-01",
  "name": "[concat(parameters('storageAccountName'), '/default/', parameters('fileShareName'))]",
  "properties": {
    "shareQuota": 1024,
    "enabledProtocols": "SMB"
  }
}
```

## Working with File Shares

### Mounting File Shares

#### Windows (SMB):
```cmd
# Map network drive
net use Z: \\mystorageaccount.file.core.windows.net\myfileshare /persistent:yes
```

#### Linux (SMB):
```bash
# Install cifs-utils
sudo apt-get update
sudo apt-get install cifs-utils

# Create mount point
sudo mkdir /mnt/myfileshare

# Mount file share
sudo mount -t cifs //mystorageaccount.file.core.windows.net/myfileshare /mnt/myfileshare \
    -o vers=3.0,username=mystorageaccount,password=<storage-key>,dir_mode=0777,file_mode=0777
```

#### macOS (SMB):
```bash
# Mount via Finder or command line
mount -t smbfs //mystorageaccount:<storage-key>@mystorageaccount.file.core.windows.net/myfileshare /Volumes/myfileshare
```

### File Operations

#### Upload Files:
```bash
# Upload file via CLI
az storage file upload \
    --share-name myfileshare \
    --source ./localfile.txt \
    --path remotefile.txt \
    --account-name mystorageaccount
```

#### Download Files:
```bash
# Download file via CLI
az storage file download \
    --share-name myfileshare \
    --path remotefile.txt \
    --dest ./downloadedfile.txt \
    --account-name mystorageaccount
```

#### Create Directories:
```bash
# Create directory
az storage directory create \
    --share-name myfileshare \
    --name mydirectory \
    --account-name mystorageaccount
```

#### List Files:
```bash
# List files and directories
az storage file list \
    --share-name myfileshare \
    --account-name mystorageaccount
```

### PowerShell File Operations:
```powershell
# Upload file
Set-AzStorageFileContent -ShareName "myfileshare" -Source ".\localfile.txt" -Path "remotefile.txt" -Context $ctx

# Download file
Get-AzStorageFileContent -ShareName "myfileshare" -Path "remotefile.txt" -Destination ".\downloadedfile.txt" -Context $ctx

# Create directory
New-AzStorageDirectory -ShareName "myfileshare" -Path "mydirectory" -Context $ctx
```

## Soft Delete

### What is Soft Delete?

Soft delete protects file share data from accidental deletion by retaining deleted shares for a specified retention period.

### Enabling Soft Delete:

#### Azure CLI:
```bash
# Enable soft delete for file shares
az storage account file-service-properties update \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --enable-delete-retention true \
    --delete-retention-days 7
```

#### PowerShell:
```powershell
# Enable soft delete
Enable-AzStorageFileDeleteRetentionPolicy \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -StorageAccountName "mystorageaccount" \
    -RetentionDays 7
```

#### ARM Template:
```json
{
  "type": "Microsoft.Storage/storageAccounts/fileServices",
  "apiVersion": "2021-04-01",
  "properties": {
    "shareDeleteRetentionPolicy": {
      "enabled": true,
      "days": 7
    }
  }
}
```

### Working with Soft Deleted Shares:

#### List Deleted Shares:
```bash
# List soft deleted shares
az storage share list \
    --account-name mystorageaccount \
    --include-deleted
```

#### Restore Deleted Share:
```bash
# Restore soft deleted share
az storage share restore \
    --name myfileshare \
    --deleted-version "01D64EB9886F00C4" \
    --account-name mystorageaccount
```

#### PowerShell Restore:
```powershell
# Restore deleted share
Restore-AzStorageShare -Name "myfileshare" -DeletedShareVersion "01D64EB9886F00C4" -Context $ctx
```

### Soft Delete Configuration:
- **Retention period**: 1-365 days
- **Default**: Disabled
- **Scope**: Applies to entire storage account
- **Billing**: Charged for soft deleted data

## Encryption

### Encryption at Rest

#### Microsoft-Managed Keys (Default):
- **Automatic**: Enabled by default
- **Algorithm**: AES-256
- **Key management**: Handled by Microsoft
- **No configuration** required

#### Customer-Managed Keys:
```bash
# Create Key Vault and key
az keyvault create \
    --name mykeyvault \
    --resource-group sa1_test_eic_SudarshanDarade \
    --location southeastasia

az keyvault key create \
    --vault-name mykeyvault \
    --name mykey \
    --protection software

# Configure storage account with customer key
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --encryption-key-source Microsoft.Keyvault \
    --encryption-key-vault https://mykeyvault.vault.azure.net \
    --encryption-key-name mykey
```

#### PowerShell Customer-Managed Keys:
```powershell
# Set customer-managed key
Set-AzStorageAccount \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -Name "mystorageaccount" \
    -KeyvaultEncryption \
    -KeyName "mykey" \
    -KeyVersion "keyversion" \
    -KeyVaultUri "https://mykeyvault.vault.azure.net"
```

### Encryption in Transit

#### SMB Encryption:
- **SMB 3.0+**: Supports encryption in transit
- **Automatic**: Enabled for SMB 3.0+ connections
- **Force encryption**: Can be enforced

#### Enable Secure Transfer:
```bash
# Require secure transfer (HTTPS/SMB 3.0+)
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --https-only true
```

### Infrastructure Encryption:
```bash
# Enable infrastructure encryption (double encryption)
az storage account create \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --location southeastasia \
    --sku Standard_LRS \
    --encryption-services file \
    --require-infrastructure-encryption
```

## Advanced Features

### File Share Snapshots

#### Create Snapshot:
```bash
# Create file share snapshot
az storage share snapshot \
    --name myfileshare \
    --account-name mystorageaccount
```

#### List Snapshots:
```bash
# List share snapshots
az storage share list \
    --account-name mystorageaccount \
    --include-snapshots
```

#### Restore from Snapshot:
```bash
# Restore file from snapshot
az storage file copy start \
    --source-share myfileshare \
    --source-path "file.txt" \
    --source-snapshot "2024-01-15T10:30:00.0000000Z" \
    --destination-share myfileshare \
    --destination-path "restored-file.txt" \
    --account-name mystorageaccount
```

### Access Control

#### Share-level Permissions:
```bash
# Set share permissions
az storage share policy create \
    --share-name myfileshare \
    --name readonlypolicy \
    --permissions r \
    --start 2024-01-01T00:00:00Z \
    --expiry 2024-12-31T23:59:59Z \
    --account-name mystorageaccount
```

#### Active Directory Integration:
```bash
# Enable AD authentication
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --enable-files-aadds true
```

### Performance Optimization

#### Premium File Shares:
- **Provisioned IOPS**: Based on share size
- **Bursting**: Temporary performance boost
- **Baseline performance**: 1 IOPS per GiB

#### Standard File Shares:
- **Transaction optimized**: Best for high transaction workloads
- **Hot**: Frequently accessed data
- **Cool**: Infrequently accessed data

### Monitoring and Metrics

#### Enable Metrics:
```bash
# Enable file share metrics
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --set properties.metrics.enabled=true
```

#### Key Metrics:
- **Transactions**: Number of requests
- **Ingress/Egress**: Data transfer
- **Availability**: Service uptime
- **Success rate**: Successful operations percentage

## Best Practices

### Security:
1. **Enable secure transfer** for all connections
2. **Use customer-managed keys** for sensitive data
3. **Implement proper access controls** and permissions
4. **Enable soft delete** for data protection
5. **Regular key rotation** for customer-managed keys

### Performance:
1. **Choose appropriate tier** based on access patterns
2. **Use premium shares** for high-performance workloads
3. **Optimize client connections** and protocols
4. **Monitor performance metrics** regularly

### Cost Optimization:
1. **Right-size file shares** based on actual usage
2. **Use appropriate access tiers** for different data
3. **Implement lifecycle policies** for data management
4. **Monitor and optimize** transaction costs

### Backup and Recovery:
1. **Enable file share snapshots** for point-in-time recovery
2. **Implement regular backup** schedules
3. **Test restore procedures** regularly
4. **Use soft delete** as additional protection layer

## Common Use Cases

### Enterprise File Sharing:
- **Shared documents** and collaboration
- **Application data** sharing
- **Configuration files** distribution

### Application Integration:
- **Legacy application** migration
- **Container persistent storage**
- **Microservices** shared storage

### Backup and Archive:
- **File system backups**
- **Long-term data retention**
- **Disaster recovery** scenarios
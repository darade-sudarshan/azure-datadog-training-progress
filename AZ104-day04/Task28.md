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

### Method 1: Azure Portal

#### Create Storage Account:
1. **Navigate** to Azure Portal
2. **Create** new Storage Account or use existing
3. **Select** Standard or Premium performance
4. **Choose** appropriate redundancy option

#### Create File Share:
1. **Go to** Storage Account
2. **Select** "File shares" from left menu
3. **Click** "+ File share"
4. **Configure**:
   - Name: Enter file share name
   - Tier: Hot, Cool, or Transaction optimized
   - Size: Set quota (optional)
5. **Click** "Create"

### Method 2: Azure CLI

#### Create Storage Account:
```bash
# Create storage account for file shares
az storage account create \
    --name mystorageaccount \
    --resource-group myRG \
    --location eastus \
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
    --resource-group myRG \
    --location eastus \
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
$ctx = (Get-AzStorageAccount -ResourceGroupName "myRG" -Name "mystorageaccount").Context

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
    --resource-group myRG \
    --enable-delete-retention true \
    --delete-retention-days 7
```

#### PowerShell:
```powershell
# Enable soft delete
Enable-AzStorageFileDeleteRetentionPolicy \
    -ResourceGroupName "myRG" \
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
    --resource-group myRG \
    --location eastus

az keyvault key create \
    --vault-name mykeyvault \
    --name mykey \
    --protection software

# Configure storage account with customer key
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --encryption-key-source Microsoft.Keyvault \
    --encryption-key-vault https://mykeyvault.vault.azure.net \
    --encryption-key-name mykey
```

#### PowerShell Customer-Managed Keys:
```powershell
# Set customer-managed key
Set-AzStorageAccount \
    -ResourceGroupName "myRG" \
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
    --resource-group myRG \
    --https-only true
```

### Infrastructure Encryption:
```bash
# Enable infrastructure encryption (double encryption)
az storage account create \
    --name mystorageaccount \
    --resource-group myRG \
    --location eastus \
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
    --resource-group myRG \
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
    --resource-group myRG \
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
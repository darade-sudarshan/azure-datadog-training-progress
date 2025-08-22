# Task 24: Azure Storage Account

## What is Azure Storage Account?

Azure Storage Account is a cloud-based storage service that provides scalable, secure, and highly available storage for various data types. It serves as a container for all Azure Storage data objects including blobs, files, queues, tables, and disks.

## Types of Azure Storage Accounts

### 1. General-purpose v2 (GPv2)
- **Recommended for most scenarios**
- Supports all storage services (Blob, File, Queue, Table)
- Supports all redundancy options
- Lowest per-gigabyte pricing
- Supports hot, cool, and archive access tiers

### 2. General-purpose v1 (GPv1)
- Legacy account type
- Supports all storage services
- Limited features compared to GPv2
- Higher transaction costs

### 3. BlockBlobStorage
- Premium performance for block blobs and append blobs
- Recommended for high transaction rates
- Uses SSD storage for low latency
- Does not support access tiers

### 4. FileStorage
- Premium performance for file shares only
- Uses SSD storage
- Supports SMB and NFS protocols

### 5. BlobStorage
- Legacy blob-only storage account
- Being replaced by GPv2 with blob access tiers

## Storage Services

### Blob Storage
- Object storage for unstructured data
- Three types: Block blobs, Append blobs, Page blobs
- Access tiers: Hot, Cool, Archive

### File Storage
- Managed file shares using SMB protocol
- Can be mounted on Windows, Linux, and macOS

### Queue Storage
- Message storage for communication between application components
- Supports up to 64 KB message size

### Table Storage
- NoSQL key-value store for structured data
- Schemaless design for flexible data models

## Steps to Create Azure Storage Account

### Method 1: Azure Portal

1. **Sign in to Azure Portal**
   - Navigate to https://portal.azure.com
   - Sign in with your Azure credentials

2. **Create Storage Account**
   - Click "Create a resource"
   - Search for "Storage account"
   - Click "Create"

3. **Configure Basic Settings**
   - **Subscription**: Select your subscription
   - **Resource Group**: Create new or select existing
   - **Storage Account Name**: Enter unique name (3-24 characters, lowercase letters and numbers)
   - **Region**: Choose your preferred location
   - **Performance**: Standard or Premium
   - **Redundancy**: Choose redundancy option (LRS, ZRS, GRS, RA-GRS)

4. **Advanced Settings**
   - **Security**: Configure encryption and secure transfer
   - **Data Lake Storage Gen2**: Enable if needed
   - **Blob access**: Configure public access level

5. **Networking**
   - **Connectivity method**: Public endpoint or Private endpoint
   - **Network routing**: Microsoft or Internet routing

6. **Data Protection**
   - **Recovery**: Configure backup and restore options
   - **Tracking**: Enable versioning and change feed
   - **Access control**: Configure access policies

7. **Encryption**
   - **Encryption type**: Microsoft-managed or Customer-managed keys
   - **Infrastructure encryption**: Enable for additional security

8. **Tags** (Optional)
   - Add metadata tags for organization

9. **Review and Create**
   - Review all settings
   - Click "Create" to deploy

### Method 2: Azure CLI

```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create storage account
az storage account create \
    --name mystorageaccount \
    --resource-group myResourceGroup \
    --location eastus \
    --sku Standard_LRS \
    --kind StorageV2
```

### Method 3: PowerShell

```powershell
# Create resource group
New-AzResourceGroup -Name "myResourceGroup" -Location "East US"

# Create storage account
New-AzStorageAccount `
    -ResourceGroupName "myResourceGroup" `
    -Name "mystorageaccount" `
    -Location "East US" `
    -SkuName "Standard_LRS" `
    -Kind "StorageV2"
```

## Redundancy Options

### Locally Redundant Storage (LRS)
- 3 copies within single data center
- Lowest cost option
- 99.999999999% (11 9's) durability

### Zone Redundant Storage (ZRS)
- 3 copies across availability zones
- Higher availability than LRS
- 99.9999999999% (12 9's) durability

### Geo-Redundant Storage (GRS)
- 6 copies across two regions
- Protection against regional disasters
- 99.99999999999999% (16 9's) durability

### Read-Access Geo-Redundant Storage (RA-GRS)
- Same as GRS with read access to secondary region
- Highest availability option

## Access Tiers (Blob Storage)

### Hot Tier
- Frequently accessed data
- Higher storage cost, lower access cost
- Default tier for new blobs

### Cool Tier
- Infrequently accessed data (30+ days)
- Lower storage cost, higher access cost
- Minimum 30-day storage period

### Archive Tier
- Rarely accessed data (180+ days)
- Lowest storage cost, highest access cost
- Minimum 180-day storage period
- Requires rehydration before access

## Best Practices

1. **Choose appropriate account type** based on performance needs
2. **Select proper redundancy** based on availability requirements
3. **Use access tiers** to optimize costs for blob storage
4. **Enable encryption** for data security
5. **Configure network access** to restrict unauthorized access
6. **Monitor usage** and costs regularly
7. **Implement lifecycle policies** for automated tier management
8. **Use managed identities** for secure access from Azure services
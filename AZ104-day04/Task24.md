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

---

## Method 1: Using Azure Portal (GUI)

### Step 1: Access Azure Portal

1. **Navigate to Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with your Azure credentials

2. **Start Storage Account Creation**
   - Click "+ Create a resource" in the left menu
   - Search for "Storage account" in the marketplace
   - Click "Storage account" from the results
   - Click "Create"

### Step 2: Configure Basics Tab

1. **Project Details**
   - **Subscription**: Select your Azure subscription
   - **Resource group**: 
     - Click "Create new" if needed
     - Enter name: `sa1_test_eic_SudarshanDarade`
     - Click "OK"

2. **Instance Details**
   - **Storage account name**: `storageaccount[unique-suffix]`
     - Must be 3-24 characters
     - Only lowercase letters and numbers
     - Must be globally unique
   - **Region**: `Southeast Asia`
   - **Performance**: 
     - `Standard` (for general use)
     - `Premium` (for high-performance scenarios)
   - **Redundancy**: Select based on needs:
     - `Locally-redundant storage (LRS)` - Lowest cost
     - `Zone-redundant storage (ZRS)` - Higher availability
     - `Geo-redundant storage (GRS)` - Regional protection
     - `Read-access geo-redundant storage (RA-GRS)` - Highest availability

3. **Click "Next: Advanced >"**

### Step 3: Configure Advanced Tab

1. **Security Settings**
   - **Require secure transfer for REST API operations**: `Enabled` (recommended)
   - **Allow enabling public access on containers**: Choose based on security needs
   - **Enable storage account key access**: `Enabled` (default)
   - **Default to Azure Active Directory authorization**: `Enabled` (recommended)
   - **Minimum TLS version**: `Version 1.2` (recommended)

2. **Data Lake Storage Gen2**
   - **Enable hierarchical namespace**: 
     - `Enabled` if you need Data Lake features
     - `Disabled` for standard storage

3. **Blob Storage**
   - **Enable SFTP**: `Disabled` (unless specifically needed)
   - **Enable network file system v3**: `Disabled` (unless needed)
   - **Allow cross-tenant replication**: Choose based on requirements
   - **Access tier (default)**: 
     - `Hot` - for frequently accessed data
     - `Cool` - for infrequently accessed data

4. **Azure Files**
   - **Enable large file shares**: `Disabled` (unless needed)

5. **Tables and Queues**
   - **Enable support for customer-managed keys**: Choose based on encryption needs

6. **Click "Next: Networking >"**

### Step 4: Configure Networking Tab

1. **Network Connectivity**
   - **Connectivity method**:
     - `Public endpoint (all networks)` - Accessible from internet
     - `Public endpoint (selected networks)` - Restricted access
     - `Private endpoint` - VNet access only

2. **If Public endpoint (selected networks) chosen:**
   - **Virtual networks**: Add allowed VNets
   - **IP addresses**: Add allowed IP ranges
   - **Exceptions**:
     - ☑ Allow Azure services on the trusted services list
     - ☑ Allow read access to storage logging
     - ☑ Allow read access to storage metrics

3. **Network Routing**
   - **Routing preference**: 
     - `Microsoft network routing` (default, recommended)
     - `Internet routing` (lower cost, potentially higher latency)

4. **Click "Next: Data protection >"**

### Step 5: Configure Data Protection Tab

1. **Recovery**
   - **Enable point-in-time restore for containers**: 
     - ☑ Enable (recommended for important data)
     - Set restore period (1-365 days)
   - **Enable soft delete for blobs**: 
     - ☑ Enable (recommended)
     - Retention period: `7 days` (or as needed)
   - **Enable soft delete for containers**: 
     - ☑ Enable (recommended)
     - Retention period: `7 days`
   - **Enable soft delete for file shares**: 
     - ☑ Enable if using Azure Files
     - Retention period: `7 days`

2. **Tracking**
   - **Enable versioning for blobs**: ☑ Enable (recommended for version control)
   - **Enable blob change feed**: ☑ Enable (for audit and compliance)

3. **Access Control**
   - **Enable version-level immutability support**: Enable if needed for compliance

4. **Click "Next: Encryption >"**

### Step 6: Configure Encryption Tab

1. **Encryption Type**
   - **Microsoft-managed keys (MMK)**: Default, managed by Microsoft
   - **Customer-managed keys (CMK)**: Your own keys from Key Vault

2. **If Customer-managed keys selected:**
   - **Key management**: 
     - `Azure Key Vault`
     - `Azure Key Vault Managed HSM`
   - **Key vault**: Select existing or create new
   - **Key**: Select encryption key
   - **Version**: Select key version

3. **Infrastructure Encryption**
   - **Enable infrastructure encryption**: ☑ Enable for additional security layer

4. **Click "Next: Tags >"**

### Step 7: Configure Tags Tab (Optional)

1. **Add Resource Tags**
   - **Name**: `Environment`, **Value**: `Development`
   - **Name**: `Project`, **Value**: `AZ104Training`
   - **Name**: `Owner`, **Value**: `YourName`
   - **Name**: `CostCenter`, **Value**: `IT`

2. **Click "Next: Review + create >"**

### Step 8: Review and Create

1. **Review Configuration**
   - Verify all settings are correct
   - Check estimated monthly cost
   - Review validation results

2. **Create Storage Account**
   - Click "Create"
   - Wait for deployment to complete (usually 1-2 minutes)
   - Click "Go to resource" when deployment succeeds

### Step 9: Explore Storage Account Features

#### Access Storage Account

1. **Navigate to Storage Account**
   - Go to "Storage accounts" in the left menu
   - Click on your created storage account

2. **Overview Dashboard**
   - View account details and status
   - Monitor usage and performance metrics
   - Access quick actions

#### Create Blob Container

1. **Navigate to Containers**
   - Click "Containers" in the left menu under "Data storage"
   - Click "+ Container"

2. **Configure Container**
   - **Name**: `documents`
   - **Public access level**: 
     - `Private` (no anonymous access)
     - `Blob` (anonymous read access for blobs)
     - `Container` (anonymous read access for containers and blobs)
   - Click "Create"

3. **Upload Files**
   - Click on the created container
   - Click "Upload"
   - Select files to upload
   - Configure upload options:
     - **Access tier**: Hot, Cool, or Archive
     - **Blob type**: Block blob (default)
   - Click "Upload"

#### Create File Share

1. **Navigate to File Shares**
   - Click "File shares" in the left menu
   - Click "+ File share"

2. **Configure File Share**
   - **Name**: `shared-files`
   - **Tier**: 
     - `Transaction optimized` (default)
     - `Hot` (frequently accessed)
     - `Cool` (infrequently accessed)
   - **Quota**: Set maximum size (e.g., `100 GB`)
   - Click "Create"

3. **Access File Share**
   - Click on the created file share
   - Click "Connect" to get connection instructions
   - Choose platform (Windows, Linux, macOS)
   - Copy and run the provided commands

#### Configure Access Keys

1. **Navigate to Access Keys**
   - Click "Access keys" in the left menu under "Security + networking"
   - View primary and secondary access keys
   - Click "Show keys" to reveal key values
   - Click "Rotate key" to regenerate keys if needed

2. **Connection Strings**
   - Copy connection strings for applications
   - Use in application configuration

#### Set Up Shared Access Signatures (SAS)

1. **Navigate to Shared Access Signature**
   - Click "Shared access signature" in the left menu

2. **Configure SAS**
   - **Allowed services**: Blob, File, Queue, Table
   - **Allowed resource types**: Service, Container, Object
   - **Allowed permissions**: Read, Write, Delete, List, etc.
   - **Start and expiry date/time**: Set validity period
   - **Allowed IP addresses**: Restrict access by IP (optional)
   - **Allowed protocols**: HTTPS only (recommended)

3. **Generate SAS**
   - Click "Generate SAS and connection string"
   - Copy the generated SAS token and connection string

### Step 10: Configure Advanced Features

#### Set Up Lifecycle Management

1. **Navigate to Lifecycle Management**
   - Click "Lifecycle management" in the left menu
   - Click "Add a rule"

2. **Configure Rule**
   - **Rule name**: `auto-tier-policy`
   - **Rule scope**: Apply to all blobs or filtered subset
   - **Blob type**: Block blobs

3. **Set Conditions**
   - **If blobs were last modified**: `More than 30 days ago`
   - **Then**: `Move to cool storage`
   - **If blobs were last modified**: `More than 90 days ago`
   - **Then**: `Move to archive storage`
   - **If blobs were last modified**: `More than 2555 days ago`
   - **Then**: `Delete the blob`

4. **Save Rule**
   - Click "Add" to create the lifecycle rule

#### Configure Static Website (if needed)

1. **Navigate to Static Website**
   - Click "Static website" in the left menu
   - Click "Enabled"

2. **Configure Website**
   - **Index document name**: `index.html`
   - **Error document path**: `404.html`
   - Click "Save"

3. **Upload Website Files**
   - Note the `$web` container created automatically
   - Upload HTML, CSS, JS files to this container
   - Access via the provided primary endpoint URL

### Step 11: Monitor and Manage

#### Set Up Monitoring

1. **Navigate to Insights**
   - Click "Insights" in the left menu
   - View performance metrics and analytics
   - Monitor capacity, transactions, and availability

2. **Configure Alerts**
   - Click "Alerts" in the left menu
   - Click "+ New alert rule"
   - Configure conditions and actions
   - Set up notifications for storage issues

#### Manage Costs

1. **View Cost Analysis**
   - Click "Cost Management + Billing" in the portal
   - Analyze storage costs by service and access tier
   - Set up budgets and cost alerts

2. **Optimize Storage**
   - Review access patterns
   - Move infrequently accessed data to cooler tiers
   - Implement lifecycle policies
   - Delete unnecessary data

### Step 12: Security and Compliance

#### Configure Network Security

1. **Firewall and Virtual Networks**
   - Click "Networking" in the left menu
   - Configure allowed networks and IP ranges
   - Set up private endpoints if needed

2. **Enable Advanced Threat Protection**
   - Click "Security + networking" → "Microsoft Defender for Cloud"
   - Enable threat protection for storage
   - Configure security alerts

#### Backup and Disaster Recovery

1. **Configure Geo-Replication**
   - Ensure appropriate redundancy option is selected
   - Monitor replication status
   - Test failover procedures if using RA-GRS

2. **Backup Important Data**
   - Use Azure Backup for file shares
   - Implement cross-region replication for critical data
   - Test restore procedures regularly

---

## Method 2: Using Azure CLI

### Method 2: Azure CLI

```bash
# Create resource group
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia

# Create storage account
az storage account create \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --location southeastasia \
    --sku Standard_LRS \
    --kind StorageV2
```

### Method 3: PowerShell

```powershell
# Create resource group
New-AzResourceGroup -Name "sa1_test_eic_SudarshanDarade" -Location "East US"

# Create storage account
New-AzStorageAccount `
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
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
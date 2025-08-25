# Task 25: Azure Blob Service

## What is Azure Blob Service?

Azure Blob Service is a cloud-based object storage solution for storing massive amounts of unstructured data such as text, binary data, documents, media files, and application data. It's optimized for storing data that doesn't adhere to a particular data model or definition.

## Types of Blobs

### 1. Block Blobs
- **Use case**: Text and binary files, documents, media files
- **Size**: Up to 190.7 TB
- **Structure**: Made up of blocks of data
- **Optimization**: Efficient for upload and download of large files

### 2. Append Blobs
- **Use case**: Logging scenarios, audit trails
- **Size**: Up to 195 GB
- **Structure**: Optimized for append operations
- **Limitation**: Cannot update or delete existing blocks

### 3. Page Blobs
- **Use case**: Virtual hard disk (VHD) files for Azure VMs
- **Size**: Up to 8 TB
- **Structure**: Collection of 512-byte pages
- **Optimization**: Random read/write operations

## Blob Storage Hierarchy

```
Storage Account
└── Container
    └── Blob
        └── Blob data
```

## Steps to Upload and Access Blobs

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

### Step 2: Create Blob Container

1. **Navigate to Containers**
   - In the storage account, click "Containers" under "Data storage" in the left menu
   - Click "+ Container" to create a new container

2. **Configure Container Settings**
   - **Name**: `documents` (3-63 characters, lowercase letters, numbers, hyphens)
   - **Public access level**: Choose based on security needs:
     - `Private (no anonymous access)` - Most secure, requires authentication
     - `Blob (anonymous read access for blobs only)` - Blobs accessible via URL
     - `Container (anonymous read access for containers and blobs)` - Full public access
   - Click "Create"

3. **Create Additional Containers** (Optional)
   - Repeat for different data types:
     - `images` - for image files
     - `videos` - for video content
     - `backups` - for backup files
     - `logs` - for application logs

### Step 3: Upload Blobs to Container

#### Basic Upload

1. **Access Container**
   - Click on the container name (e.g., `documents`)
   - You'll see the container's blob list (empty initially)

2. **Upload Files**
   - Click "Upload" button at the top
   - **Upload blob** dialog opens

3. **Select Files**
   - Click "Browse for files" or drag and drop files
   - Select single or multiple files
   - Supported file types: Any file type (text, images, videos, documents, etc.)

4. **Configure Upload Options**
   - **Blob type**: 
     - `Block blob` (default, for most files)
     - `Page blob` (for VHD files)
     - `Append blob` (for log files)
   - **Block size**: Keep default (4 MB) unless specific needs
   - **Access tier**: 
     - `Hot` - frequently accessed data
     - `Cool` - infrequently accessed data (30+ days)
     - `Archive` - rarely accessed data (180+ days)

5. **Advanced Options** (Click "Advanced")
   - **Folder**: Specify virtual folder path (e.g., `2024/documents/`)
   - **Encryption scope**: Use default or specify custom scope
   - **Upload to folder**: Create folder structure

6. **Complete Upload**
   - Click "Upload"
   - Monitor upload progress
   - Files appear in the container list when complete

#### Bulk Upload

1. **Upload Multiple Files**
   - Select multiple files using Ctrl+Click or Shift+Click
   - Or drag and drop entire folders
   - Azure Portal will maintain folder structure

2. **Monitor Progress**
   - View upload progress for each file
   - Cancel individual uploads if needed
   - Retry failed uploads

### Step 4: Manage Blob Properties

1. **View Blob Details**
   - Click on any uploaded blob name
   - View blob properties:
     - Size, creation date, last modified
     - Content type, encoding
     - Access tier, lease status
     - ETag, MD5 hash

2. **Edit Blob Properties**
   - Click "Edit" to modify:
     - **Content-Type**: Set MIME type (e.g., `image/jpeg`, `application/pdf`)
     - **Content-Encoding**: Set encoding (e.g., `gzip`)
     - **Content-Language**: Set language code
     - **Cache-Control**: Set caching behavior

3. **Add Metadata**
   - Click "Metadata" tab
   - Click "+ Add metadata"
   - **Name**: `author`, **Value**: `John Doe`
   - **Name**: `department`, **Value**: `IT`
   - **Name**: `project`, **Value**: `AZ104Training`
   - Click "Save"

### Step 5: Configure Access and Security

#### Generate Shared Access Signature (SAS)

1. **Navigate to Blob**
   - Click on the blob you want to share
   - Click "Generate SAS" in the toolbar

2. **Configure SAS Parameters**
   - **Permissions**: Select required permissions:
     - ☑ Read - Download blob
     - ☑ Write - Upload/modify blob
     - ☑ Delete - Delete blob
     - ☑ List - List blobs in container
   - **Start date/time**: Set when SAS becomes valid
   - **Expiry date/time**: Set when SAS expires (e.g., 1 week from now)
   - **Allowed IP addresses**: Restrict access to specific IPs (optional)
   - **Allowed protocols**: `HTTPS only` (recommended)

3. **Generate and Use SAS**
   - Click "Generate SAS token and URL"
   - Copy the **Blob SAS URL** for sharing
   - Copy the **SAS token** for programmatic access
   - Test the URL in a browser (for read access)

#### Configure Container-Level SAS

1. **Navigate to Container**
   - Go back to the container level
   - Click "Shared access tokens" in the left menu

2. **Configure Container SAS**
   - **Permissions**: Select container-level permissions
   - **Start and expiry time**: Set validity period
   - **Allowed services**: Blob service
   - **Allowed resource types**: Container and Object
   - Click "Generate SAS token and URL"

### Step 6: Access and Download Blobs

#### Direct Access (Public Containers)

1. **Get Blob URL**
   - Click on blob name
   - Copy the **URL** from properties
   - Format: `https://[account].blob.core.windows.net/[container]/[blob]`

2. **Access via Browser**
   - Paste URL in browser address bar
   - File downloads or displays (depending on type)

#### Download via Portal

1. **Download Single Blob**
   - Click on blob name
   - Click "Download" button
   - File downloads to your local machine

2. **Download Multiple Blobs**
   - Select multiple blobs using checkboxes
   - Click "Download" in the toolbar
   - Files download as a ZIP archive

### Step 7: Organize Blobs with Virtual Directories

1. **Create Folder Structure**
   - When uploading, specify folder path in "Advanced" options
   - Example structure:
     ```
     documents/
     ├── 2024/
     │   ├── january/
     │   ├── february/
     │   └── march/
     ├── contracts/
     └── reports/
     ```

2. **Navigate Folders**
   - Click on folder names to navigate
   - Use breadcrumb navigation to go back
   - Upload files directly to specific folders

### Step 8: Configure Access Tiers for Cost Optimization

1. **Change Individual Blob Tier**
   - Click on blob name
   - Click "Change tier" in the toolbar
   - Select new tier:
     - **Hot**: $0.0184/GB/month, $0.0004/10K transactions
     - **Cool**: $0.01/GB/month, $0.01/10K transactions
     - **Archive**: $0.00099/GB/month, $0.02/10K transactions
   - Click "Save"

2. **Bulk Tier Changes**
   - Select multiple blobs
   - Click "Change tier" in toolbar
   - Apply tier change to all selected blobs

3. **Rehydrate Archived Blobs**
   - For archived blobs, select rehydration priority:
     - **Standard**: Up to 15 hours
     - **High**: Up to 1 hour
   - Blob becomes accessible after rehydration

### Step 9: Set Up Lifecycle Management

1. **Navigate to Lifecycle Management**
   - Go to storage account level
   - Click "Lifecycle management" under "Data management"
   - Click "Add a rule"

2. **Configure Lifecycle Rule**
   - **Rule name**: `auto-tier-documents`
   - **Rule scope**: 
     - `Apply rule to all blobs in the storage account`
     - Or `Limit blobs with filters` for specific containers

3. **Set Conditions and Actions**
   - **Base blobs**:
     - If last modified > 30 days ago → Move to Cool storage
     - If last modified > 90 days ago → Move to Archive storage
     - If last modified > 2555 days ago → Delete blob
   - **Snapshots** (if enabled):
     - Configure similar rules for blob snapshots

4. **Save Rule**
   - Click "Add" to create the lifecycle rule
   - Rules apply automatically based on conditions

### Step 10: Monitor and Analyze Blob Usage

#### View Storage Metrics

1. **Navigate to Insights**
   - In storage account, click "Insights" under "Monitoring"
   - View capacity, transactions, and availability metrics
   - Filter by time range and blob service

2. **Analyze Usage Patterns**
   - **Capacity**: Total storage used by tier
   - **Transactions**: Read/write operations count
   - **Availability**: Service uptime percentage
   - **Latency**: Average response times

#### Set Up Alerts

1. **Create Storage Alert**
   - Click "Alerts" under "Monitoring"
   - Click "+ New alert rule"
   - **Resource**: Select your storage account
   - **Condition**: Choose metric (e.g., "Used capacity")
   - **Threshold**: Set limit (e.g., > 80% capacity)
   - **Action**: Configure email/SMS notifications

### Step 11: Advanced Blob Features

#### Enable Blob Versioning

1. **Configure Versioning**
   - Go to storage account → "Data protection"
   - Enable "Versioning for blobs"
   - Previous versions preserved when blob is modified

2. **Manage Versions**
   - Click on blob → "Versions" tab
   - View all versions with timestamps
   - Download or restore previous versions
   - Delete old versions to save costs

#### Configure Soft Delete

1. **Enable Soft Delete**
   - Go to storage account → "Data protection"
   - Enable "Soft delete for blobs"
   - Set retention period (1-365 days)

2. **Recover Deleted Blobs**
   - In container, click "Show deleted blobs"
   - Select deleted blob
   - Click "Undelete" to restore

#### Set Up Change Feed

1. **Enable Change Feed**
   - Go to storage account → "Data protection"
   - Enable "Blob change feed"
   - Tracks all changes to blobs

2. **Access Change Logs**
   - Changes stored in `$blobchangefeed` container
   - Use for audit trails and compliance

### Step 12: Integration and Automation

#### Connect to Applications

1. **Get Connection String**
   - Go to storage account → "Access keys"
   - Copy connection string for application use
   - Use in application configuration

2. **Configure CORS** (for web applications)
   - Go to storage account → "Resource sharing (CORS)"
   - Add allowed origins, methods, and headers
   - Enable cross-origin requests from web apps

#### Set Up Event Notifications

1. **Configure Event Grid**
   - Go to storage account → "Events"
   - Click "+ Event Subscription"
   - **Event types**: Blob created, deleted, etc.
   - **Endpoint**: Azure Function, Logic App, or webhook
   - Use for automated processing of blob changes

---

## Method 2: Using Azure CLI

### Method 2: Azure CLI

#### Upload Blob:
```bash
# Create container
az storage container create \
    --name mycontainer \
    --account-name mystorageaccount

# Upload blob
az storage blob upload \
    --file ./myfile.txt \
    --name myfile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount
```

#### Access Blob:
```bash
# Download blob
az storage blob download \
    --name myfile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount \
    --file ./downloaded-file.txt

# Get blob URL
az storage blob url \
    --name myfile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount
```

### Method 3: PowerShell

#### Upload Blob:
```powershell
# Get storage context
$ctx = (Get-AzStorageAccount -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "mystorageaccount").Context

# Create container
New-AzStorageContainer -Name "mycontainer" -Context $ctx -Permission Blob

# Upload blob
Set-AzStorageBlobContent -File ".\myfile.txt" -Container "mycontainer" -Blob "myfile.txt" -Context $ctx
```

#### Access Blob:
```powershell
# Download blob
Get-AzStorageBlobContent -Container "mycontainer" -Blob "myfile.txt" -Destination ".\downloaded-file.txt" -Context $ctx

# Get blob URL
$blob = Get-AzStorageBlob -Container "mycontainer" -Blob "myfile.txt" -Context $ctx
$blob.ICloudBlob.StorageUri.PrimaryUri
```

### Method 4: REST API

#### Upload Blob:
```bash
curl -X PUT \
  "https://mystorageaccount.blob.core.windows.net/mycontainer/myfile.txt" \
  -H "Authorization: Bearer <access-token>" \
  -H "x-ms-blob-type: BlockBlob" \
  -H "Content-Type: text/plain" \
  --data-binary @myfile.txt
```

#### Access Blob:
```bash
curl -X GET \
  "https://mystorageaccount.blob.core.windows.net/mycontainer/myfile.txt" \
  -H "Authorization: Bearer <access-token>"
```

## Authorization Techniques

### 1. Shared Key Authorization

**Description**: Uses storage account access keys for authentication

**Implementation**:
```bash
# Using account key
az storage blob upload \
    --file ./myfile.txt \
    --name myfile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount \
    --account-key "your-account-key"
```

**Pros**: Simple to implement
**Cons**: Full access to storage account, key rotation challenges

### 2. Shared Access Signature (SAS)

**Description**: Provides delegated access with specific permissions and time limits

**Types**:
- **Account SAS**: Access to multiple services
- **Service SAS**: Access to specific service
- **User Delegation SAS**: Secured with Azure AD credentials

**Implementation**:
```bash
# Generate SAS token
az storage blob generate-sas \
    --name myfile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount \
    --permissions r \
    --expiry 2024-12-31T23:59:59Z

# Use SAS token
curl "https://mystorageaccount.blob.core.windows.net/mycontainer/myfile.txt?<sas-token>"
```

**Pros**: Granular permissions, time-limited access
**Cons**: Token management complexity

### 3. Azure Active Directory (Azure AD)

**Description**: Uses Azure AD identities for authentication and authorization

**Implementation**:
```bash
# Login with Azure AD
az login

# Upload with Azure AD auth
az storage blob upload \
    --file ./myfile.txt \
    --name myfile.txt \
    --container-name mycontainer \
    --account-name mystorageaccount \
    --auth-mode login
```

**Pros**: Centralized identity management, no key management
**Cons**: More complex setup

### 4. Managed Identity

**Description**: Uses Azure-managed identities for Azure resources

**Implementation**:
```bash
# Assign role to managed identity
az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee <managed-identity-id> \
    --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account>
```

**Pros**: No credential management, secure for Azure resources
**Cons**: Limited to Azure resources

### 5. Anonymous Public Access

**Description**: Allows public read access without authentication

**Configuration**:
- Set container public access level to "Blob" or "Container"
- Access via direct URL without authentication

**Implementation**:
```bash
# Public access (no auth required)
curl "https://mystorageaccount.blob.core.windows.net/publiccontainer/myfile.txt"
```

**Pros**: Simple public access
**Cons**: No access control, security risk

## Access Control Levels

### Container Level Access:
- **Private**: No anonymous access
- **Blob**: Anonymous read access for blobs only
- **Container**: Anonymous read access for containers and blobs

### RBAC Roles:
- **Storage Blob Data Owner**: Full access
- **Storage Blob Data Contributor**: Read/write/delete access
- **Storage Blob Data Reader**: Read-only access

## Best Practices

### Security:
1. **Use Azure AD** authentication when possible
2. **Implement least privilege** access
3. **Rotate access keys** regularly
4. **Use SAS tokens** for temporary access
5. **Enable secure transfer** (HTTPS only)

### Performance:
1. **Choose appropriate blob type** for use case
2. **Use block blob** for most scenarios
3. **Implement retry logic** for resilience
4. **Consider access tiers** for cost optimization

### Management:
1. **Organize blobs** with meaningful naming conventions
2. **Use metadata** for additional information
3. **Implement lifecycle policies** for automated management
4. **Monitor access patterns** and costs

## Common Use Cases

### Web Applications:
- Static website hosting
- Media file storage
- Document storage

### Data Analytics:
- Data lake storage
- Log file storage
- Backup and archive

### Application Integration:
- File sharing between applications
- Content distribution
- Mobile app backend storage
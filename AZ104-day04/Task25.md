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

### Method 1: Azure Portal

#### Upload Blob:
1. **Navigate to Storage Account**
   - Go to Azure Portal
   - Select your storage account

2. **Create Container**
   - Click "Containers" in left menu
   - Click "+ Container"
   - Enter container name
   - Set public access level
   - Click "Create"

3. **Upload Blob**
   - Click on container name
   - Click "Upload" button
   - Select files or drag and drop
   - Configure advanced options if needed
   - Click "Upload"

#### Access Blob:
1. **Navigate to blob** in container
2. **Copy blob URL** from properties
3. **Access via URL** (if public) or download

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
$ctx = (Get-AzStorageAccount -ResourceGroupName "myRG" -Name "mystorageaccount").Context

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
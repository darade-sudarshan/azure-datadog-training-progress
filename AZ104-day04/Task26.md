# Task 26: Azure Storage Account Advanced Features

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

### Step 2: Configure Stored Access Policy

#### Create Container for Access Policy

1. **Navigate to Containers**
   - In the storage account, click "Containers" under "Data storage"
   - Click "+ Container" to create a new container
   - **Name**: `secure-documents`
   - **Public access level**: `Private (no anonymous access)`
   - Click "Create"

#### Create Stored Access Policy

1. **Access Container Settings**
   - Click on the container name (`secure-documents`)
   - Click "Access policy" in the left menu

2. **Add Stored Access Policy**
   - Click "+ Add policy"
   - **Identifier**: `read-write-policy`
   - **Permissions**: Select required permissions:
     - ☑ Read - Read blob content and metadata
     - ☑ Write - Write blob content and metadata
     - ☑ Delete - Delete blobs
     - ☑ List - List blobs in container
   - **Start time**: Set when policy becomes active (e.g., current date/time)
   - **Expiry time**: Set when policy expires (e.g., 1 year from now)
   - Click "OK"

3. **Save Access Policy**
   - Click "Save" to apply the stored access policy
   - Policy is now available for SAS token generation

#### Generate SAS Using Stored Access Policy

1. **Upload Test Blob**
   - Upload a test file to the container
   - Click "Upload" and select a file

2. **Generate SAS Token**
   - Click on the uploaded blob
   - Click "Generate SAS" in the toolbar
   - **Signing method**: `Account key`
   - **Stored access policy**: Select `read-write-policy`
   - **Start and expiry time**: Automatically populated from policy
   - **Permissions**: Automatically set from policy
   - Click "Generate SAS token and URL"

3. **Use Generated SAS**
   - Copy the **Blob SAS URL**
   - Test access using the URL
   - Share with authorized users

#### Manage Stored Access Policies

1. **Modify Policy**
   - Go back to container → "Access policy"
   - Click on existing policy (`read-write-policy`)
   - **Modify permissions**: Remove "Write" and "Delete" permissions
   - **Update expiry time**: Extend or reduce validity period
   - Click "OK" and "Save"

2. **Revoke Policy**
   - Select the policy and click "Delete"
   - All SAS tokens using this policy become invalid immediately
   - Click "Save" to confirm

### Step 3: Configure Immutable Blob Storage

#### Create Container for Immutable Storage

1. **Create Compliance Container**
   - Navigate to "Containers"
   - Click "+ Container"
   - **Name**: `compliance-data`
   - **Public access level**: `Private (no anonymous access)`
   - Click "Create"

#### Enable Version-Level Immutability

1. **Configure Storage Account Settings**
   - Go to storage account level
   - Click "Data protection" under "Data management"
   - **Version-level immutability support**: ☑ Enable
   - Click "Save"

#### Set Time-Based Retention Policy

1. **Access Container Immutability**
   - Click on `compliance-data` container
   - Click "Access policy" in the left menu
   - Scroll down to "Immutable blob storage"

2. **Add Time-Based Retention Policy**
   - Click "+ Add policy"
   - **Policy type**: `Time-based retention`
   - **Retention period**: Enter duration:
     - **Years**: `7` (for 7-year retention)
     - **Days**: `2555` (equivalent to 7 years)
   - **Policy state**: `Unlocked` (for testing)
   - Click "OK"

3. **Test Immutability (Unlocked State)**
   - Upload a test document to the container
   - Try to delete or modify the blob
   - Verify that operations are blocked
   - Note: In unlocked state, policy can still be modified

4. **Lock the Policy (Production)**
   - Click on the retention policy
   - Click "Lock policy"
   - **Confirmation**: Type "yes" to confirm
   - Click "Lock"
   - **Warning**: Once locked, policy cannot be deleted, only extended

#### Set Legal Hold Policy

1. **Add Legal Hold**
   - In the same "Access policy" section
   - Under "Legal holds", click "+ Add legal hold"
   - **Tag**: `legal-case-2024-001`
   - **Description**: `Litigation hold for contract dispute`
   - Click "OK"

2. **Test Legal Hold**
   - Upload documents to the container
   - Verify that blobs cannot be deleted or modified
   - Legal hold takes precedence over retention policies

3. **Remove Legal Hold**
   - When legal case is resolved, click on the legal hold
   - Click "Remove legal hold"
   - Confirm removal
   - Blobs now follow time-based retention policy only

#### Monitor Immutable Storage

1. **View Policy Status**
   - Check policy state (Locked/Unlocked)
   - Monitor retention period remaining
   - Track legal holds applied

2. **Audit Compliance**
   - Go to "Activity log" to view policy changes
   - Monitor access attempts and policy modifications
   - Generate compliance reports

### Step 4: Configure Data Redundancy

#### View Current Redundancy

1. **Check Current Settings**
   - Go to storage account "Overview"
   - View current **Replication** setting
   - Note the redundancy type (LRS, ZRS, GRS, etc.)

2. **Understand Redundancy Options**
   - **LRS**: 3 copies in single datacenter
   - **ZRS**: 3 copies across availability zones
   - **GRS**: 6 copies (3 local + 3 in paired region)
   - **RA-GRS**: GRS + read access to secondary region
   - **GZRS**: ZRS + GRS combined
   - **RA-GZRS**: GZRS + read access to secondary

#### Change Redundancy Type

1. **Navigate to Configuration**
   - Click "Configuration" under "Settings"
   - Find "Replication" section

2. **Select New Redundancy**
   - **Current**: `Locally-redundant storage (LRS)`
   - **Change to**: `Geo-redundant storage (GRS)`
   - **Cost impact**: Review pricing changes
   - **Availability impact**: Note SLA improvements

3. **Apply Changes**
   - Click "Save"
   - **Warning**: Data migration may take time
   - Monitor replication status during transition

#### Monitor Replication Status

1. **Check Replication Health**
   - Go to "Monitoring" → "Insights"
   - View replication metrics
   - Monitor any replication lag

2. **View Secondary Region Access**
   - For RA-GRS/RA-GZRS accounts:
   - Note secondary endpoint URL
   - Test read access to secondary region
   - Format: `https://[account]-secondary.blob.core.windows.net`

### Step 5: Advanced Security Configuration

#### Configure Network Access

1. **Restrict Network Access**
   - Go to "Networking" under "Security + networking"
   - **Public network access**: `Enabled from selected virtual networks and IP addresses`
   - **Virtual networks**: Add allowed VNets
   - **IP addresses**: Add allowed IP ranges
   - **Exceptions**: 
     - ☑ Allow Azure services on the trusted services list
     - ☑ Allow read access to storage logging
     - ☑ Allow read access to storage metrics

2. **Configure Private Endpoints**
   - Click "Private endpoint connections"
   - Click "+ Private endpoint"
   - Configure private endpoint for secure VNet access

#### Enable Advanced Threat Protection

1. **Configure Microsoft Defender**
   - Go to "Microsoft Defender for Cloud" under "Security + networking"
   - **Microsoft Defender for Storage**: `On`
   - **Malware scanning**: Enable for blob uploads
   - **Sensitive data threat detection**: Enable
   - Click "Save"

2. **Set Up Alerts**
   - Configure alert rules for suspicious activities
   - Set up email notifications
   - Monitor security recommendations

### Step 6: Lifecycle Management and Automation

#### Configure Lifecycle Policies

1. **Create Lifecycle Rule**
   - Go to "Lifecycle management" under "Data management"
   - Click "Add a rule"
   - **Rule name**: `compliance-lifecycle`
   - **Rule scope**: `Apply rule to all blobs in the storage account`

2. **Set Tier Transitions**
   - **Base blobs**:
     - If last modified > 30 days ago → Move to Cool storage
     - If last modified > 90 days ago → Move to Archive storage
     - If last modified > 2555 days ago → Delete blob
   - **Snapshots**: Configure similar rules
   - **Versions**: Set retention for blob versions

3. **Apply to Specific Containers**
   - **Limit blobs with filters**
   - **Container name**: `compliance-data`
   - **Blob name prefix**: `documents/`
   - **Blob types**: Block blobs

#### Set Up Monitoring and Alerts

1. **Configure Storage Insights**
   - Go to "Insights" under "Monitoring"
   - View capacity, transactions, and availability
   - Set up custom dashboards

2. **Create Alert Rules**
   - Go to "Alerts" under "Monitoring"
   - Click "+ New alert rule"
   - **Condition**: Used capacity > 80%
   - **Action group**: Email notifications
   - **Alert rule name**: `Storage Capacity Alert`

### Step 7: Compliance and Governance

#### Configure Audit Logging

1. **Enable Diagnostic Settings**
   - Go to "Diagnostic settings" under "Monitoring"
   - Click "+ Add diagnostic setting"
   - **Name**: `storage-audit-logs`
   - **Categories**: 
     - ☑ StorageRead
     - ☑ StorageWrite
     - ☑ StorageDelete
   - **Destination**: Log Analytics workspace
   - Click "Save"

2. **Monitor Access Patterns**
   - View logs in Log Analytics
   - Create custom queries for compliance reporting
   - Set up automated compliance checks

#### Generate Compliance Reports

1. **Create Custom Workbook**
   - Go to "Workbooks" under "Monitoring"
   - Create custom compliance dashboard
   - Include immutability status, access logs, policy changes

2. **Export Compliance Data**
   - Use Log Analytics queries
   - Export data for regulatory reporting
   - Schedule automated reports

### Step 8: Disaster Recovery and Business Continuity

#### Configure Account Failover

1. **Prepare for Failover**
   - Ensure GRS or RA-GRS redundancy
   - Document failover procedures
   - Test application compatibility

2. **Initiate Customer-Managed Failover**
   - Go to "Geo-replication" under "Data management"
   - **Current status**: View primary and secondary regions
   - **Failover**: Click "Prepare for failover" (if needed)
   - **Warning**: Potential data loss during failover

3. **Monitor Failover Process**
   - Track failover progress
   - Update application endpoints
   - Verify data accessibility

#### Test Recovery Procedures

1. **Regular Testing**
   - Test secondary region access (RA-GRS)
   - Verify backup and restore procedures
   - Document recovery time objectives (RTO)

2. **Update Disaster Recovery Plan**
   - Include storage account failover procedures
   - Train operations team
   - Regular DR drills

---

## Method 2: Using Azure CLI

## Stored Access Policy

### What is Stored Access Policy?

A stored access policy provides an additional level of control over service-level shared access signatures (SAS) on the server side. It allows you to change the start time, expiry time, or permissions for a signature, or to revoke it after it has been issued.

### Benefits:
- **Centralized control** over SAS permissions
- **Revoke access** without regenerating storage account keys
- **Modify permissions** without redistributing SAS tokens
- **Audit and compliance** capabilities

### Creating Stored Access Policy

#### Azure CLI:
```bash
# Create stored access policy for container
az storage container policy create \
    --container-name mycontainer \
    --name mypolicy \
    --permissions rwdl \
    --start 2024-01-01T00:00:00Z \
    --expiry 2024-12-31T23:59:59Z \
    --account-name mystorageaccount
```

#### PowerShell:
```powershell
# Create access policy
$policy = New-AzStorageContainerStoredAccessPolicy \
    -Container "mycontainer" \
    -Policy "mypolicy" \
    -Permission rwdl \
    -StartTime (Get-Date) \
    -ExpiryTime (Get-Date).AddYears(1) \
    -Context $ctx
```

#### REST API:
```xml
<?xml version="1.0" encoding="utf-8"?>
<SignedIdentifiers>
  <SignedIdentifier>
    <Id>mypolicy</Id>
    <AccessPolicy>
      <Start>2024-01-01T00:00:00.0000000Z</Start>
      <Expiry>2024-12-31T23:59:59.0000000Z</Expiry>
      <Permission>rwdl</Permission>
    </AccessPolicy>
  </SignedIdentifier>
</SignedIdentifiers>
```

### Using Stored Access Policy with SAS:
```bash
# Generate SAS using stored access policy
az storage blob generate-sas \
    --name myblob.txt \
    --container-name mycontainer \
    --policy-name mypolicy \
    --account-name mystorageaccount
```

### Managing Stored Access Policies:
```bash
# List policies
az storage container policy list \
    --container-name mycontainer \
    --account-name mystorageaccount

# Update policy
az storage container policy update \
    --container-name mycontainer \
    --name mypolicy \
    --permissions r \
    --account-name mystorageaccount

# Delete policy
az storage container policy delete \
    --container-name mycontainer \
    --name mypolicy \
    --account-name mystorageaccount
```

## Immutable Blob Storage

### What is Immutable Blob Storage?

Immutable blob storage allows users to store business-critical data in a WORM (Write Once, Read Many) state. Data cannot be modified or deleted for a user-specified interval.

### Types of Immutability Policies:

#### 1. Time-based Retention Policy
- **Purpose**: Prevents modification/deletion for specified time period
- **Duration**: 1 day to 146,000 days (400 years)
- **State**: Locked or Unlocked

#### 2. Legal Hold Policy
- **Purpose**: Prevents modification/deletion until legal hold is removed
- **Duration**: Indefinite until explicitly cleared
- **Use case**: Legal investigations, compliance requirements

### Implementing Immutable Storage

#### Enable Immutable Storage:
```bash
# Create container with immutable storage
az storage container create \
    --name immutablecontainer \
    --account-name mystorageaccount \
    --public-access off
```

#### Set Time-based Retention Policy:
```bash
# Set retention policy (PowerShell)
Set-AzRmStorageContainerImmutabilityPolicy \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -StorageAccountName "mystorageaccount" \
    -ContainerName "immutablecontainer" \
    -ImmutabilityPeriod 365
```

#### Set Legal Hold:
```bash
# Set legal hold (PowerShell)
Add-AzRmStorageContainerLegalHold \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -StorageAccountName "mystorageaccount" \
    -ContainerName "immutablecontainer" \
    -Tag "legal-case-001"
```

### Policy States:

#### Unlocked State:
- **Testing phase** for retention period
- **Can be modified** or deleted
- **Can extend** retention period
- **Cannot shorten** retention period

#### Locked State:
- **Production-ready** immutability
- **Cannot be deleted** or modified
- **Cannot reduce** retention period
- **Can extend** retention period up to 5 times

### Lock Immutability Policy:
```bash
# Lock policy (PowerShell)
Lock-AzRmStorageContainerImmutabilityPolicy \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -StorageAccountName "mystorageaccount" \
    -ContainerName "immutablecontainer" \
    -Etag "policy-etag"
```

## Data Redundancy

### What is Data Redundancy?

Data redundancy ensures data durability and availability by maintaining multiple copies of data across different locations within Azure's infrastructure.

### Redundancy Options:

#### 1. Locally Redundant Storage (LRS)
- **Copies**: 3 copies within single datacenter
- **Durability**: 99.999999999% (11 9's)
- **Availability**: 99.9%
- **Cost**: Lowest
- **Use case**: Non-critical data, cost-sensitive scenarios

#### 2. Zone Redundant Storage (ZRS)
- **Copies**: 3 copies across 3 availability zones
- **Durability**: 99.9999999999% (12 9's)
- **Availability**: 99.9%
- **Cost**: Medium
- **Use case**: High availability within region

#### 3. Geo-Redundant Storage (GRS)
- **Copies**: 6 copies (3 local + 3 in paired region)
- **Durability**: 99.99999999999999% (16 9's)
- **Availability**: 99.9% (primary), 99% (secondary)
- **Cost**: Higher
- **Use case**: Disaster recovery, regional outage protection

#### 4. Read-Access Geo-Redundant Storage (RA-GRS)
- **Same as GRS** plus read access to secondary region
- **Availability**: 99.9% (primary), 99.9% (secondary read)
- **Use case**: Applications requiring read access during outages

#### 5. Geo-Zone-Redundant Storage (GZRS)
- **Combines ZRS and GRS**
- **Primary**: 3 copies across availability zones
- **Secondary**: 3 copies in paired region (LRS)
- **Durability**: 99.99999999999999% (16 9's)

#### 6. Read-Access Geo-Zone-Redundant Storage (RA-GZRS)
- **Same as GZRS** plus read access to secondary region
- **Highest availability** option

### Changing Redundancy:
```bash
# Change redundancy type
az storage account update \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --sku Standard_GRS
```

### Redundancy Comparison:

| Type | Local Copies | Regional Copies | AZ Protection | Regional Protection | Read Access Secondary |
|------|--------------|-----------------|---------------|--------------------|--------------------|
| LRS | 3 | 0 | No | No | No |
| ZRS | 3 (across AZ) | 0 | Yes | No | No |
| GRS | 3 | 3 | No | Yes | No |
| RA-GRS | 3 | 3 | No | Yes | Yes |
| GZRS | 3 (across AZ) | 3 | Yes | Yes | No |
| RA-GZRS | 3 (across AZ) | 3 | Yes | Yes | Yes |

## Storage Redundancy Best Practices

### Choosing Redundancy:

#### For Mission-Critical Data:
- **Use GZRS or RA-GZRS** for maximum protection
- **Consider compliance** requirements
- **Evaluate RTO/RPO** requirements

#### For Standard Applications:
- **Use GRS or RA-GRS** for regional protection
- **Use ZRS** for high availability within region
- **Balance cost vs. availability** needs

#### For Development/Testing:
- **Use LRS** for cost optimization
- **Consider data criticality**

### Monitoring Redundancy:

#### Check Replication Status:
```bash
# Get replication status
az storage account show \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --query "statusOfPrimary"
```

#### Monitor Metrics:
- **Availability metrics**
- **Replication lag** (for geo-redundant)
- **Failover status**

### Failover Scenarios:

#### Customer-Managed Failover:
```bash
# Initiate account failover (PowerShell)
Invoke-AzStorageAccountFailover \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
    -Name "mystorageaccount"
```

#### Considerations:
- **Data loss potential** during failover
- **Application updates** required for endpoint changes
- **Failback process** planning

## Implementation Examples

### Complete Setup with All Features:
```bash
# Create storage account with GRS
az storage account create \
    --name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --location southeastasia \
    --sku Standard_GRS \
    --kind StorageV2

# Create container for immutable storage
az storage container create \
    --name compliancedata \
    --account-name mystorageaccount

# Create stored access policy
az storage container policy create \
    --container-name compliancedata \
    --name readonlypolicy \
    --permissions r \
    --expiry 2025-12-31T23:59:59Z \
    --account-name mystorageaccount
```

### PowerShell Complete Example:
```powershell
# Create storage account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
    -Name "mystorageaccount" `
    -Location "East US" `
    -SkuName "Standard_GRS" `
    -Kind "StorageV2"

# Get context
$ctx = $storageAccount.Context

# Create container
New-AzStorageContainer -Name "compliancedata" -Context $ctx

# Set immutability policy
Set-AzRmStorageContainerImmutabilityPolicy `
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
    -StorageAccountName "mystorageaccount" `
    -ContainerName "compliancedata" `
    -ImmutabilityPeriod 2555 # 7 years
```

## Compliance and Governance

### Regulatory Compliance:
- **SEC 17a-4(f)** - Financial services
- **CFTC 1.31(c)-(d)** - Commodity trading
- **FINRA 4511(c)** - Securities industry
- **HIPAA** - Healthcare data
- **GDPR** - European data protection

### Audit Capabilities:
- **Activity logs** for policy changes
- **Access logs** for data operations
- **Compliance reports** for regulatory requirements
- **Retention verification** for legal holds
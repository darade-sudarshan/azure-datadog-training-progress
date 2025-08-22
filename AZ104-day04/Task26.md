# Task 26: Azure Storage Account Advanced Features

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
    -ResourceGroupName "myRG" \
    -StorageAccountName "mystorageaccount" \
    -ContainerName "immutablecontainer" \
    -ImmutabilityPeriod 365
```

#### Set Legal Hold:
```bash
# Set legal hold (PowerShell)
Add-AzRmStorageContainerLegalHold \
    -ResourceGroupName "myRG" \
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
    -ResourceGroupName "myRG" \
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
    --resource-group myRG \
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
    --resource-group myRG \
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
    -ResourceGroupName "myRG" \
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
    --resource-group myRG \
    --location eastus \
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
    -ResourceGroupName "myRG" `
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
    -ResourceGroupName "myRG" `
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
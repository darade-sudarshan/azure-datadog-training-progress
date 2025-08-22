# Task 27: Azure Storage Account - Advanced Blob Management

## Access Tiers

### What are Access Tiers?

Access tiers optimize storage costs based on data access patterns. Different tiers have varying storage costs and access costs.

### Types of Access Tiers:

#### 1. Hot Tier
- **Use case**: Frequently accessed data
- **Storage cost**: Highest
- **Access cost**: Lowest
- **Availability**: 99.9% (LRS), 99.99% (GRS)
- **Examples**: Active websites, mobile apps, streaming content

#### 2. Cool Tier
- **Use case**: Infrequently accessed data (30+ days)
- **Storage cost**: Lower than Hot
- **Access cost**: Higher than Hot
- **Minimum storage**: 30 days
- **Availability**: 99% (LRS), 99.9% (GRS)
- **Examples**: Backups, disaster recovery data

#### 3. Archive Tier
- **Use case**: Rarely accessed data (180+ days)
- **Storage cost**: Lowest
- **Access cost**: Highest
- **Minimum storage**: 180 days
- **Availability**: 99% (LRS), 99.9% (GRS)
- **Rehydration**: Required before access
- **Examples**: Long-term backups, compliance data

### Setting Access Tiers:

#### At Account Level:
```bash
# Set default access tier for storage account
az storage account update \
    --name mystorageaccount \
    --resource-group myRG \
    --access-tier Hot
```

#### At Blob Level:
```bash
# Set blob access tier
az storage blob set-tier \
    --name myblob.txt \
    --container-name mycontainer \
    --tier Cool \
    --account-name mystorageaccount
```

#### PowerShell:
```powershell
# Set blob tier
$blob = Get-AzStorageBlob -Container "mycontainer" -Blob "myblob.txt" -Context $ctx
$blob.ICloudBlob.SetStandardBlobTier("Archive")
```

### Rehydrating Archive Blobs:
```bash
# Rehydrate from archive (set to hot/cool)
az storage blob set-tier \
    --name myblob.txt \
    --container-name mycontainer \
    --tier Hot \
    --rehydrate-priority Standard \
    --account-name mystorageaccount
```

## Lifecycle Policies

### What are Lifecycle Policies?

Automated rules that transition blobs between access tiers or delete blobs based on age, last access time, or creation time.

### Policy Components:
- **Rules**: Define conditions and actions
- **Filters**: Specify which blobs to target
- **Actions**: Tier transitions or deletions

### Creating Lifecycle Policy:

#### JSON Policy Example:
```json
{
  "rules": [
    {
      "name": "ruleFoo",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["container1/foo"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 30
            },
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 90
            },
            "delete": {
              "daysAfterModificationGreaterThan": 2555
            }
          },
          "snapshot": {
            "delete": {
              "daysAfterCreationGreaterThan": 90
            }
          }
        }
      }
    }
  ]
}
```

#### Apply Policy via CLI:
```bash
# Create lifecycle policy
az storage account management-policy create \
    --account-name mystorageaccount \
    --resource-group myRG \
    --policy @policy.json
```

#### PowerShell:
```powershell
# Create lifecycle management policy
$rule = New-AzStorageAccountManagementPolicyRule `
    -Name "MoveToArchive" `
    -BlobType blockBlob `
    -TierToArchiveDaysAfterModificationGreaterThan 90

Set-AzStorageAccountManagementPolicy `
    -ResourceGroupName "myRG" `
    -StorageAccountName "mystorageaccount" `
    -Rule $rule
```

### Policy Actions:

#### Tier Transitions:
- **tierToCool**: Move to Cool tier
- **tierToArchive**: Move to Archive tier

#### Deletion:
- **delete**: Delete blobs
- **deleteAfterDaysFromCreation**: Delete based on creation date

#### Version Management:
- **tierToCoolAfterDaysSinceCreation**: For blob versions
- **deleteAfterDaysSinceCreation**: Delete old versions

### Managing Policies:
```bash
# View current policy
az storage account management-policy show \
    --account-name mystorageaccount \
    --resource-group myRG

# Update policy
az storage account management-policy update \
    --account-name mystorageaccount \
    --resource-group myRG \
    --policy @updated-policy.json

# Delete policy
az storage account management-policy delete \
    --account-name mystorageaccount \
    --resource-group myRG
```

## Object Replication

### What is Object Replication?

Asynchronously copies block blobs between storage accounts, providing disaster recovery and data locality benefits.

### Requirements:
- **Source and destination** must be different storage accounts
- **Blob versioning** must be enabled on both accounts
- **Change feed** must be enabled on source account

### Setting Up Object Replication:

#### Enable Prerequisites:
```bash
# Enable versioning on both accounts
az storage account blob-service-properties update \
    --account-name sourcestorageaccount \
    --resource-group myRG \
    --enable-versioning true

az storage account blob-service-properties update \
    --account-name deststorageaccount \
    --resource-group myRG \
    --enable-versioning true

# Enable change feed on source
az storage account blob-service-properties update \
    --account-name sourcestorageaccount \
    --resource-group myRG \
    --enable-change-feed true
```

#### Create Replication Policy:
```json
{
  "policyId": "policy1",
  "sourceAccount": "sourcestorageaccount",
  "destinationAccount": "deststorageaccount",
  "rules": [
    {
      "ruleId": "rule1",
      "sourceContainer": "sourcecontainer",
      "destinationContainer": "destcontainer",
      "filters": {
        "prefixMatch": ["folder1/"]
      }
    }
  ]
}
```

#### Apply Replication Policy:
```bash
# Create object replication policy
az storage account or-policy create \
    --account-name sourcestorageaccount \
    --resource-group myRG \
    --policy @replication-policy.json
```

#### PowerShell:
```powershell
# Create replication policy
$rule = New-AzStorageObjectReplicationPolicyRule `
    -SourceContainer "sourcecontainer" `
    -DestinationContainer "destcontainer" `
    -PrefixMatch "folder1/"

New-AzStorageObjectReplicationPolicy `
    -ResourceGroupName "myRG" `
    -StorageAccountName "sourcestorageaccount" `
    -Rule $rule `
    -DestinationAccountId "/subscriptions/.../deststorageaccount"
```

### Monitoring Replication:
```bash
# Check replication status
az storage account or-policy show \
    --account-name sourcestorageaccount \
    --resource-group myRG \
    --policy-id policy1
```

## Blob Snapshots

### What are Blob Snapshots?

Read-only versions of a blob captured at a specific point in time. Useful for backup and recovery scenarios.

### Creating Snapshots:

#### CLI:
```bash
# Create blob snapshot
az storage blob snapshot \
    --name myblob.txt \
    --container-name mycontainer \
    --account-name mystorageaccount
```

#### PowerShell:
```powershell
# Create snapshot
$blob = Get-AzStorageBlob -Container "mycontainer" -Blob "myblob.txt" -Context $ctx
$snapshot = $blob.ICloudBlob.CreateSnapshot()
```

#### REST API:
```bash
curl -X PUT \
  "https://mystorageaccount.blob.core.windows.net/mycontainer/myblob.txt?comp=snapshot" \
  -H "Authorization: Bearer <token>" \
  -H "x-ms-version: 2020-04-08"
```

### Working with Snapshots:

#### List Snapshots:
```bash
# List all snapshots of a blob
az storage blob list \
    --container-name mycontainer \
    --prefix myblob.txt \
    --include snapshots \
    --account-name mystorageaccount
```

#### Access Snapshot:
```bash
# Download specific snapshot
az storage blob download \
    --name myblob.txt \
    --container-name mycontainer \
    --snapshot "2024-01-15T10:30:00.0000000Z" \
    --file ./snapshot-file.txt \
    --account-name mystorageaccount
```

#### Delete Snapshot:
```bash
# Delete specific snapshot
az storage blob delete \
    --name myblob.txt \
    --container-name mycontainer \
    --snapshot "2024-01-15T10:30:00.0000000Z" \
    --account-name mystorageaccount
```

### Snapshot Billing:
- **Incremental billing**: Only charged for unique data
- **Base blob changes**: Snapshots retain original data
- **Deletion**: Snapshots persist even if base blob is deleted

## Blob Versioning

### What is Blob Versioning?

Automatically maintains previous versions of blobs when they are modified, providing comprehensive data protection.

### Enabling Blob Versioning:

#### CLI:
```bash
# Enable versioning
az storage account blob-service-properties update \
    --account-name mystorageaccount \
    --resource-group myRG \
    --enable-versioning true
```

#### PowerShell:
```powershell
# Enable versioning
Enable-AzStorageBlobVersioning \
    -ResourceGroupName "myRG" \
    -StorageAccountName "mystorageaccount"
```

#### ARM Template:
```json
{
  "type": "Microsoft.Storage/storageAccounts/blobServices",
  "apiVersion": "2021-04-01",
  "properties": {
    "isVersioningEnabled": true
  }
}
```

### Working with Versions:

#### List Versions:
```bash
# List all versions of a blob
az storage blob list \
    --container-name mycontainer \
    --prefix myblob.txt \
    --include versions \
    --account-name mystorageaccount
```

#### Access Specific Version:
```bash
# Download specific version
az storage blob download \
    --name myblob.txt \
    --container-name mycontainer \
    --version-id "2024-01-15T10:30:00.0000000Z" \
    --file ./version-file.txt \
    --account-name mystorageaccount
```

#### Promote Version:
```bash
# Copy old version to current
az storage blob copy start \
    --source-blob myblob.txt \
    --source-container mycontainer \
    --source-version-id "2024-01-15T10:30:00.0000000Z" \
    --destination-blob myblob.txt \
    --destination-container mycontainer \
    --account-name mystorageaccount
```

### Version Management:

#### Delete Specific Version:
```bash
# Delete version (not current)
az storage blob delete \
    --name myblob.txt \
    --container-name mycontainer \
    --version-id "2024-01-15T10:30:00.0000000Z" \
    --account-name mystorageaccount
```

#### Lifecycle Policy for Versions:
```json
{
  "rules": [
    {
      "name": "deleteOldVersions",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "actions": {
          "version": {
            "delete": {
              "daysAfterCreationGreaterThan": 365
            }
          }
        }
      }
    }
  ]
}
```

## Comparison: Snapshots vs Versioning

| Feature | Snapshots | Versioning |
|---------|-----------|------------|
| **Creation** | Manual | Automatic |
| **Trigger** | On-demand | Every modification |
| **Management** | Manual deletion | Lifecycle policies |
| **Performance** | No impact on writes | Slight impact on writes |
| **Use Case** | Point-in-time backup | Continuous protection |
| **Cost** | Incremental | Incremental |

## Best Practices

### Access Tiers:
1. **Monitor access patterns** to optimize tier selection
2. **Use lifecycle policies** for automatic tier management
3. **Consider early deletion fees** for Cool and Archive tiers
4. **Plan rehydration time** for Archive tier access

### Lifecycle Policies:
1. **Start with conservative rules** and adjust based on usage
2. **Use filters** to target specific blob types or prefixes
3. **Test policies** in non-production environments first
4. **Monitor policy execution** through storage analytics

### Object Replication:
1. **Enable in different regions** for disaster recovery
2. **Monitor replication lag** and status
3. **Consider bandwidth costs** for cross-region replication
4. **Use filters** to replicate only necessary data

### Snapshots and Versioning:
1. **Choose based on use case**: Manual vs automatic protection
2. **Implement retention policies** to manage costs
3. **Monitor storage usage** as versions accumulate
4. **Use with lifecycle policies** for automated cleanup

### Cost Optimization:
1. **Combine features strategically** (tiers + lifecycle + versioning)
2. **Regular cleanup** of old versions and snapshots
3. **Monitor billing** for incremental charges
4. **Use analytics** to understand access patterns
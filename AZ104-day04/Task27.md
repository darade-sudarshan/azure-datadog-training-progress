# Task 27: Azure Storage Account - Advanced Blob Management

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

### Step 2: Configure Access Tiers

#### Set Default Access Tier at Account Level

1. **Navigate to Configuration**
   - In the storage account, click "Configuration" under "Settings"
   - Find "Blob access tier (default)" section

2. **Change Default Tier**
   - **Current setting**: View current default tier
   - **Available options**:
     - `Hot` - Frequently accessed data ($0.0184/GB/month)
     - `Cool` - Infrequently accessed data ($0.01/GB/month)
   - Select desired default tier
   - Click "Save"

#### Manage Individual Blob Access Tiers

1. **Navigate to Container**
   - Click "Containers" under "Data storage"
   - Click on a container with existing blobs

2. **Change Single Blob Tier**
   - Click on a blob name
   - Click "Change tier" in the toolbar
   - **Current tier**: View current access tier
   - **New tier**: Select from:
     - `Hot` - Immediate access, higher storage cost
     - `Cool` - 30-day minimum, lower storage cost
     - `Archive` - 180-day minimum, lowest cost, requires rehydration
   - **Rehydration priority** (for Archive to Hot/Cool):
     - `Standard` - Up to 15 hours
     - `High` - Up to 1 hour (higher cost)
   - Click "Save"

3. **Bulk Tier Changes**
   - Select multiple blobs using checkboxes
   - Click "Change tier" in the toolbar
   - Select new tier for all selected blobs
   - Click "Save"

#### Monitor Tier Distribution

1. **View Storage Analytics**
   - Go to "Insights" under "Monitoring"
   - **Capacity** tab shows storage by tier:
     - Hot tier usage and cost
     - Cool tier usage and cost
     - Archive tier usage and cost
   - **Transactions** tab shows access patterns

### Step 3: Configure Lifecycle Management Policies

#### Create Lifecycle Management Rule

1. **Navigate to Lifecycle Management**
   - Click "Lifecycle management" under "Data management"
   - Click "Add a rule"

2. **Configure Rule Details**
   - **Rule name**: `auto-tier-policy`
   - **Rule scope**: Choose scope:
     - `Apply rule to all blobs in the storage account`
     - `Limit blobs with filters` (for specific containers/prefixes)

3. **Set Filters** (if "Limit blobs" selected)
   - **Blob types**: ☑ Block blobs
   - **Container name**: Specify container (e.g., `documents`)
   - **Blob name prefix**: Specify prefix (e.g., `archive/`)

4. **Configure Base Blob Actions**
   - **Tier to cool storage**:
     - ☑ Enable
     - **Days after last modification**: `30`
   - **Tier to archive storage**:
     - ☑ Enable
     - **Days after last modification**: `90`
   - **Delete blob**:
     - ☑ Enable
     - **Days after last modification**: `2555` (7 years)

5. **Configure Snapshot Actions** (if snapshots enabled)
   - **Delete snapshots**:
     - ☑ Enable
     - **Days after creation**: `90`

6. **Configure Version Actions** (if versioning enabled)
   - **Tier versions to cool storage**:
     - ☑ Enable
     - **Days after creation**: `30`
   - **Tier versions to archive storage**:
     - ☑ Enable
     - **Days after creation**: `90`
   - **Delete versions**:
     - ☑ Enable
     - **Days after creation**: `365`

7. **Review and Create**
   - Review all settings
   - Click "Add" to create the rule

#### Manage Existing Rules

1. **View Active Rules**
   - See list of all lifecycle rules
   - Check rule status (Enabled/Disabled)
   - View rule details and filters

2. **Edit Rule**
   - Click on rule name
   - Modify conditions and actions
   - Click "Update"

3. **Disable/Enable Rule**
   - Toggle rule status
   - Temporarily disable without deleting

4. **Delete Rule**
   - Select rule and click "Delete"
   - Confirm deletion

### Step 4: Configure Object Replication

#### Prerequisites Setup

1. **Enable Blob Versioning**
   - Go to "Data protection" under "Data management"
   - **Versioning for blobs**: ☑ Enable
   - Click "Save"

2. **Enable Change Feed**
   - In the same "Data protection" section
   - **Blob change feed**: ☑ Enable
   - Click "Save"

#### Create Object Replication Policy

1. **Navigate to Object Replication**
   - Click "Object replication" under "Data management"
   - Click "Create replication rules"

2. **Configure Source Account**
   - **Source storage account**: Current account (auto-selected)
   - **Source container**: Select container to replicate

3. **Configure Destination Account**
   - **Destination storage account**: Select target account
   - **Destination container**: Select or create target container
   - **Note**: Must be different storage account

4. **Set Replication Filters**
   - **Blob name prefix**: Specify prefix to replicate (e.g., `important/`)
   - **Blob types**: Block blobs (default)

5. **Review and Create**
   - **Policy name**: Auto-generated or custom
   - **Rule name**: Auto-generated or custom
   - Click "Create"

#### Monitor Replication Status

1. **View Replication Policies**
   - See all active replication policies
   - Check policy status and health

2. **Monitor Replication Progress**
   - View replication lag and status
   - Check failed replications
   - Monitor bandwidth usage

### Step 5: Manage Blob Snapshots

#### Create Manual Snapshots

1. **Navigate to Blob**
   - Go to container and select a blob
   - Click on the blob name

2. **Create Snapshot**
   - Click "Create snapshot" in the toolbar
   - **Snapshot name**: Auto-generated with timestamp
   - Click "Create"
   - Snapshot appears in blob list with timestamp

#### View and Manage Snapshots

1. **List Snapshots**
   - In container view, click "Show snapshots" toggle
   - View all snapshots with creation timestamps
   - Snapshots shown with 📷 icon

2. **Access Snapshot Data**
   - Click on snapshot entry
   - **Download**: Download snapshot content
   - **Properties**: View snapshot metadata
   - **Generate SAS**: Create access token for snapshot

3. **Delete Snapshots**
   - Select snapshot(s) using checkboxes
   - Click "Delete" in toolbar
   - **Warning**: Deletion is permanent
   - Confirm deletion

#### Restore from Snapshot

1. **Copy Snapshot to New Blob**
   - Click on snapshot
   - Click "Copy" in toolbar
   - **Destination**: Specify new blob name
   - Click "Copy"

2. **Overwrite Current Blob**
   - Copy snapshot content over current blob
   - **Warning**: Current blob data will be lost

### Step 6: Configure Blob Versioning

#### Enable Blob Versioning

1. **Navigate to Data Protection**
   - Go to "Data protection" under "Data management"
   - **Versioning for blobs**: ☑ Enable
   - Click "Save"

2. **Understand Versioning Behavior**
   - Every blob modification creates a new version
   - Previous versions are automatically preserved
   - Current version is always the latest

#### Work with Blob Versions

1. **View Blob Versions**
   - Navigate to container
   - Click "Show versions" toggle
   - See all versions with timestamps
   - Current version marked as "Current"

2. **Access Previous Versions**
   - Click on any version entry
   - **Download**: Get version content
   - **Properties**: View version metadata
   - **Generate SAS**: Create access token

3. **Promote Previous Version**
   - Click on desired version
   - Click "Promote to current version"
   - **Warning**: Creates new current version
   - Previous current becomes a version

4. **Delete Specific Versions**
   - Select version(s) to delete
   - Click "Delete" in toolbar
   - **Note**: Cannot delete current version
   - Confirm deletion

### Step 7: Monitor and Analyze Blob Usage

#### Storage Analytics and Insights

1. **View Capacity Metrics**
   - Go to "Insights" under "Monitoring"
   - **Capacity** tab shows:
     - Total storage by tier
     - Version and snapshot storage
     - Growth trends over time

2. **Analyze Transaction Patterns**
   - **Transactions** tab shows:
     - Read/write operations
     - Tier transition activities
     - Access patterns by time

3. **Monitor Costs**
   - **Cost analysis** shows:
     - Storage costs by tier
     - Transaction costs
     - Data transfer costs

#### Set Up Alerts

1. **Create Storage Alerts**
   - Go to "Alerts" under "Monitoring"
   - Click "+ New alert rule"
   - **Condition**: Select metrics:
     - Used capacity
     - Transaction count
     - Availability
   - **Threshold**: Set limits
   - **Action**: Configure notifications

### Step 8: Advanced Blob Security

#### Configure Blob-Level Security

1. **Set Blob Access Policies**
   - Navigate to specific blob
   - Click "Access policy"
   - Configure container-level access
   - Set stored access policies

2. **Enable Soft Delete**
   - Go to "Data protection"
   - **Soft delete for blobs**: ☑ Enable
   - **Retention period**: `7 days` (1-365 days)
   - **Soft delete for containers**: ☑ Enable
   - Click "Save"

3. **Configure Immutable Storage** (if needed)
   - Set time-based retention policies
   - Configure legal holds
   - Lock policies for compliance

#### Monitor Security Events

1. **Enable Diagnostic Logging**
   - Go to "Diagnostic settings" under "Monitoring"
   - Enable blob service logs
   - Send to Log Analytics workspace

2. **Review Access Logs**
   - Monitor blob access patterns
   - Track unauthorized access attempts
   - Analyze security events

### Step 9: Optimize Performance and Costs

#### Performance Optimization

1. **Monitor Performance Metrics**
   - View latency and throughput metrics
   - Identify performance bottlenecks
   - Optimize access patterns

2. **Configure CDN** (if needed)
   - Set up Azure CDN for blob content
   - Improve global access performance
   - Reduce bandwidth costs

#### Cost Optimization

1. **Analyze Cost Patterns**
   - Review storage costs by tier
   - Identify optimization opportunities
   - Monitor lifecycle policy effectiveness

2. **Implement Cost Controls**
   - Set up budget alerts
   - Optimize tier transitions
   - Clean up unnecessary versions/snapshots

### Step 10: Automation and Integration

#### Set Up Event-Driven Automation

1. **Configure Event Grid**
   - Go to "Events" under "Settings"
   - Create event subscriptions
   - **Event types**: Blob created, deleted, tier changed
   - **Endpoint**: Azure Function, Logic App, or webhook

2. **Automate Blob Processing**
   - Trigger functions on blob events
   - Automate tier transitions
   - Process uploaded content

#### Integration with Applications

1. **Generate Connection Strings**
   - Go to "Access keys"
   - Copy connection strings for applications
   - Use in application configuration

2. **Configure CORS** (for web apps)
   - Go to "Resource sharing (CORS)"
   - Configure allowed origins and methods
   - Enable cross-origin blob access

---

## Method 2: Using Azure CLI

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
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
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
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
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
    --resource-group sa1_test_eic_SudarshanDarade

# Update policy
az storage account management-policy update \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --policy @updated-policy.json

# Delete policy
az storage account management-policy delete \
    --account-name mystorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade
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
    --resource-group sa1_test_eic_SudarshanDarade \
    --enable-versioning true

az storage account blob-service-properties update \
    --account-name deststorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
    --enable-versioning true

# Enable change feed on source
az storage account blob-service-properties update \
    --account-name sourcestorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
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
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
    -StorageAccountName "sourcestorageaccount" `
    -Rule $rule `
    -DestinationAccountId "/subscriptions/.../deststorageaccount"
```

### Monitoring Replication:
```bash
# Check replication status
az storage account or-policy show \
    --account-name sourcestorageaccount \
    --resource-group sa1_test_eic_SudarshanDarade \
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
    --resource-group sa1_test_eic_SudarshanDarade \
    --enable-versioning true
```

#### PowerShell:
```powershell
# Enable versioning
Enable-AzStorageBlobVersioning \
    -ResourceGroupName "sa1_test_eic_SudarshanDarade" \
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
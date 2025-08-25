# Task 33: Azure Backup Advanced Features

## Method 1: Using Azure Portal (GUI)

### MARS Agent Installation and Configuration via Portal

1. **Download MARS Agent from Portal**
   - Go to **Recovery Services vaults**
   - Select your vault: `rsv-backup-vault-portal`
   - Go to **Getting Started** → **Backup**
   - **Where is your workload running?**: `On-premises`
   - **What do you want to backup?**: `Files and folders`
   - Click **Download Agent for Windows Server**
   - Save installer to target server

2. **Download Vault Credentials**
   - In the same backup configuration page
   - Click **Download** vault credentials
   - **Expiry**: Credentials valid for 10 days
   - Save `.VaultCredentials` file securely

3. **Install MARS Agent via GUI**
   - Run `MARSAgentInstaller.exe` as Administrator
   - **Welcome**: Click **Next**
   - **License Agreement**: Accept and click **Next**
   - **Installation Folder**: Default or custom path
   - **Proxy Configuration**: Configure if needed
     - **Use proxy server**: Check if required
     - **Proxy server address**: Enter details
     - **Authentication**: Configure credentials
   - Click **Install**
   - **Installation Complete**: Click **Proceed to Registration**

4. **Register Server via GUI**
   - **Microsoft Azure Backup** console opens
   - Click **Register Server**
   - **Vault Identification**:
     - **Vault credentials file**: Browse and select downloaded file
     - Click **Next**
   - **Encryption Setting**:
     - **Generate passphrase**: Auto-generate
     - **Enter passphrase**: Manual entry
     - **Save passphrase to**: Secure location
   - **Proxy Settings**: Configure if needed
   - Click **Finish**

### Configure MARS Backup via Portal Interface

1. **Schedule Backup Wizard**
   - Open **Microsoft Azure Backup** console
   - Click **Schedule Backup** in Actions panel
   - **Getting Started**: Click **Next**

2. **Select Items to Backup**
   - **Add Items**: Click to browse folders
   - Select folders/files:
     - `C:\ImportantData`
     - `C:\Documents`
     - `C:\DatabaseBackups`
   - **Exclusion Settings**: 
     - **File Types**: `*.tmp, *.log, *.cache`
     - **Folders**: Temporary folders
   - Click **Next**

3. **Specify Backup Schedule**
   - **Backup frequency**: 
     - `Daily` (recommended)
     - `Weekly` (specific days)
   - **Daily backup times**: 
     - **First backup**: `11:00 PM`
     - **Second backup**: `6:00 AM` (optional)
   - **Time zone**: Select appropriate zone
   - Click **Next**

4. **Select Retention Policy**
   - **Daily retention**: `30 days`
   - **Weekly retention**: 
     - **Keep weekly backups**: `12 weeks`
     - **Day of week**: `Sunday`
   - **Monthly retention**:
     - **Keep monthly backups**: `12 months`
     - **Week of month**: `First`
     - **Day of week**: `Sunday`
   - **Yearly retention**:
     - **Keep yearly backups**: `1 year`
     - **Month**: `January`
     - **Week**: `First`
     - **Day**: `Sunday`
   - Click **Next**

5. **Choose Initial Backup Type**
   - **Automatically over the network**: Recommended
   - **Offline using Azure Import/Export**: For large datasets
   - **Network bandwidth usage**: Configure throttling
     - **Enable internet bandwidth usage throttling**
     - **Work hours**: 9:00 AM to 6:00 PM
     - **Work day bandwidth**: 512 Kbps
     - **Non-work hours bandwidth**: Unlimited
   - Click **Next**

6. **Confirmation and Completion**
   - Review backup configuration
   - Click **Finish**
   - **Run backup now**: Check to start immediate backup
   - Click **Close**

### Perform MARS Backup and Recovery via GUI

1. **Manual Backup Trigger**
   - Open **Microsoft Azure Backup** console
   - Click **Back Up Now** in Actions panel
   - **Back Up Items**: Select items to backup
   - **Retain Backup Till**: Select retention date
   - **Backup Progress**: Monitor progress
   - Click **Close** when complete

2. **File Recovery via GUI**
   - Click **Recover Data** in Actions panel
   - **Getting Started**: Click **Next**
   - **Select Recovery Mode**:
     - `Individual files and folders`
     - `Volumes`
   - Click **Next**

3. **Select Volume and Date**
   - **Volume**: Select source volume
   - **Calendar**: Choose backup date
   - **Time**: Select specific backup time
   - Click **Next**

4. **Browse and Recover**
   - **Browse**: Navigate folder structure
   - **Search**: Find specific files
   - **Select items**: Check files/folders to recover
   - **Recovery options**:
     - **Recover to**: Original or alternate location
     - **Overwrite options**: Skip, Replace, Create copies
     - **Security**: Restore ACL permissions
   - Click **Recover**

### File Share Backup via Portal

1. **Navigate to Storage Account**
   - Go to **Storage accounts**
   - Select account: `mystorageaccount`
   - Go to **Data management** → **Backup**

2. **Configure File Share Backup**
   - **File shares**: Select shares to backup
     - `documents-share`
     - `projects-share`
   - **Recovery Services vault**: `rsv-backup-vault-portal`
   - **Backup policy**: Create new or select existing

3. **Create File Share Backup Policy**
   - Click **Create a new policy**
   - **Policy name**: `FileSharePolicy-Portal`
   - **Backup schedule**:
     - **Frequency**: `Daily`
     - **Time**: `3:00 AM`
     - **Timezone**: `(UTC+08:00) Singapore`
   - **Retention range**:
     - **Daily backup retention**: `30 days`
     - **Weekly backup retention**: `12 weeks` (Sunday)
     - **Monthly backup retention**: `12 months` (First Sunday)
     - **Yearly backup retention**: `1 year` (January, First Sunday)
   - Click **OK**

4. **Enable Backup**
   - Review configuration
   - Click **Enable backup**
   - Monitor enablement progress

### File Share Recovery via Portal

1. **Access File Share Backup**
   - Go to Recovery Services vault
   - Select **Backup items** → **Azure Storage (Azure Files)**
   - Click on file share name

2. **Restore File Share**
   - Click **Restore**
   - **Recovery point**: Select from calendar
   - **Restore type**:
     - `Full Share`: Complete file share
     - `Item Level`: Specific files/folders

3. **Configure Full Share Restore**
   - **Restore location**:
     - `Original location`: Overwrite existing
     - `Alternate location`: Different storage account
   - For alternate location:
     - **Storage account**: Select target account
     - **File share**: Enter target share name
   - **Conflict resolution**:
     - `Overwrite`: Replace existing files
     - `Skip`: Keep existing files
   - Click **Restore**

4. **Configure Item-Level Restore**
   - **Browse recovery point**: Navigate folder structure
   - **Select items**: Check specific files/folders
   - **Restore location**: Original or alternate
   - **Restore options**: Overwrite, Skip, Create copy
   - Click **Restore**

### Web App Backup via Portal

1. **Navigate to App Service**
   - Go to **App Services**
   - Select web app: `mywebapp-portal`
   - Go to **Settings** → **Backups**

2. **Configure Backup Settings**
   - Click **Configure**
   - **Backup Storage**:
     - **Storage account**: Select or create account
     - **Container**: `webappbackups`
   - **Backup schedule**:
     - **Scheduled backup**: `On`
     - **Backup frequency**: `Daily`
     - **Start time**: `2:00 AM`
     - **Timezone**: Select appropriate zone
   - **Retention**: `30 days`
   - **Keep at least one backup**: `Yes`

3. **Database Backup Configuration**
   - **Databases**: Click **Included (0)**
   - **Add database**:
     - **Database type**: `SQL Database`
     - **Connection string**: Enter connection details
     - **Database name**: `MyAppDatabase`
   - Click **OK**

4. **Save and Enable**
   - Click **Save**
   - **Manual backup**: Click **Backup** for immediate backup
   - Monitor backup progress

### Web App Restore via Portal

1. **Access Backup History**
   - Go to App Service → **Backups**
   - View **Backup History**
   - Select backup to restore

2. **Restore Options**
   - Click **Restore**
   - **Restore destination**:
     - `Overwrite existing app`
     - `Restore to new app`
   - **Restore configuration**:
     - **App content**: Include app files
     - **App configuration**: Include settings
     - **Database**: Include database restore

3. **Configure New App Restore**
   - **App name**: `mywebapp-restored`
   - **Resource group**: Select target group
   - **App Service plan**: Select or create plan
   - Click **OK**

### Backup Reports via Portal

1. **Configure Backup Reports**
   - Go to Recovery Services vault
   - Select **Backup Reports** under **Monitoring**
   - **Configure workspace**: 
     - **Log Analytics workspace**: Create or select existing
     - **Storage account**: For report data storage
   - Click **Configure**

2. **Access Backup Workbooks**
   - Go to **Azure Monitor** → **Workbooks**
   - Search for **Backup Reports**
   - Click on **Backup Reports** template
   - **Parameters**:
     - **Subscriptions**: Select subscriptions
     - **Resource Groups**: Select groups
     - **Vaults**: Select Recovery Services vaults
     - **Time Range**: Last 30 days
   - Click **Apply**

3. **View Report Sections**
   - **Summary**: Overall backup health
   - **Backup Items**: Protected items status
   - **Usage**: Storage consumption trends
   - **Jobs**: Success/failure rates
   - **Alerts**: Active backup alerts
   - **Policies**: Policy compliance

### Backup Vault Configuration via Portal

1. **Create Backup Vault**
   - Go to Azure Portal → Search "Backup vaults"
   - Click **Create**
   - **Subscription**: Select subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Vault name**: `bv-backup-vault-portal`
   - **Region**: `Southeast Asia`
   - **Storage redundancy**: `Locally-redundant storage`
   - Click **Review + create** → **Create**

2. **Configure VM Disk Backup**
   - Go to created Backup vault
   - Select **Backup** under **Data management**
   - **Datasource type**: `Azure Disks`
   - **Vault**: Select backup vault
   - **Backup policy**: Create or select policy
   - **Azure Disks**: Select disks to backup
   - Click **Review + configure backup**

3. **Create Disk Backup Policy**
   - **Policy name**: `DiskBackupPolicy-Portal`
   - **Backup schedule**:
     - **Frequency**: `Daily`
     - **Time**: `2:00 AM`
   - **Retention**:
     - **Daily**: `30 days`
     - **Weekly**: `12 weeks`
     - **Monthly**: `12 months`
   - Click **Create**

4. **Configure Blob Backup**
   - Select **Backup** → **Azure Blobs**
   - **Storage accounts**: Select accounts for operational backup
   - **Backup policy**: Operational backup (continuous)
   - **Point-in-time restore**: Up to 365 days
   - Click **Configure backup**

### Advanced Backup Features via Portal

1. **Cross Region Restore**
   - Go to Recovery Services vault → **Properties**
   - **Backup Configuration**:
     - **Storage replication type**: `Geo-redundant storage`
     - **Cross Region Restore**: `Enable`
   - Click **Save**

2. **Restore in Secondary Region**
   - Go to **Backup items** → Select VM
   - Click **Cross Region Restore**
   - **Secondary region**: Automatically selected
   - **Recovery point**: Select from available points
   - **Restore configuration**: Configure VM settings
   - Click **Restore**

3. **Soft Delete Configuration**
   - Go to vault → **Properties** → **Security Settings**
   - **Soft Delete**: `Enable`
   - **Security features**: `Enable`
   - **Days to retain**: `14 days` (default)
   - Click **Save**

4. **Undelete Backup Items**
   - Go to **Backup items**
   - **Filter**: Show deleted items
   - Select deleted item
   - Click **Undelete**
   - Confirm restoration

### Monitoring and Alerting via Portal

1. **Configure Backup Alerts**
   - Go to **Monitor** → **Alerts**
   - Click **Create** → **Alert rule**
   - **Resource**: Select Recovery Services vault
   - **Condition**: Configure alert conditions
     - **Signal**: Backup Health Event
     - **Threshold**: Greater than 0
   - **Actions**: Select action group
   - **Alert details**: Name and description
   - Click **Create alert rule**

2. **View Backup Health**
   - Go to vault → **Backup Health**
   - **Health status**: View overall health
   - **Critical issues**: Address urgent problems
   - **Warnings**: Review and resolve
   - **Recommendations**: Follow best practices

3. **Monitor Backup Jobs**
   - Go to **Backup jobs** under **Monitoring**
   - **Filter options**:
     - **Time range**: Last 24 hours, 7 days
     - **Status**: Failed, In progress, Completed
     - **Workload type**: Azure VM, Files, etc.
   - **Job details**: Click on jobs for detailed information

## Method 2: Using PowerShell and CLI

### MARS Agent (Microsoft Azure Recovery Services Agent)

### Overview
MARS Agent enables backup of files, folders, and system state from Windows machines (on-premises or Azure VMs) directly to Azure Recovery Services vault without requiring a backup server.

### MARS Agent Installation

#### Prerequisites
- Windows Server 2016 or later / Windows 10 or later
- .NET Framework 4.5 or later
- Internet connectivity to Azure
- Minimum 2.5 GB free space for cache location

#### Installation Steps
1. **Download MARS Agent**
   - Navigate to Recovery Services vault
   - Go to **Getting Started** > **Backup**
   - Select **On-premises** > **Files and folders**
   - Download MARS Agent installer

2. **Install Agent**
   ```cmd
   # Run installer as administrator
   MARSAgentInstaller.exe /q /nu
   ```

3. **Download Vault Credentials**
   - In Recovery Services vault
   - Go to **Settings** > **Properties** > **Backup Credentials**
   - Download vault credentials file

#### Register MARS Agent
```powershell
# Register agent with vault
$VaultCredentialsFilePath = "C:\Downloads\vault_credentials.VaultCredentials"
$EncryptionPassphrase = "MySecurePassphrase123!"

# Start registration
Start-OBRegistration -VaultCredentials $VaultCredentialsFilePath -Confirm:$false

# Set encryption passphrase
Set-OBMachineSetting -EncryptionPassphrase $EncryptionPassphrase -SecurityPIN "1234"
```

### MARS Agent Backup Configuration

#### Create Backup Policy
```powershell
# Create new backup policy
$Policy = New-OBPolicy

# Add files and folders to backup
$FileSpec = New-OBFileSpec -FileSpec "C:\ImportantData"
$FileSpec2 = New-OBFileSpec -FileSpec "C:\Documents"
Add-OBFileSpec -Policy $Policy -FileSpec $FileSpec
Add-OBFileSpec -Policy $Policy -FileSpec $FileSpec2

# Exclude file types
$Exclusion = New-OBFileSpec -FileSpec "*.tmp" -Exclude
Add-OBFileSpec -Policy $Policy -FileSpec $Exclusion

# Set backup schedule
$Schedule = New-OBSchedule -DaysOfWeek Monday,Wednesday,Friday -TimesOfDay 02:00,14:00
Set-OBSchedule -Policy $Policy -Schedule $Schedule

# Set retention policy
$RetentionPolicy = New-OBRetentionPolicy -RetentionDays 30 -RetentionWeeks 12 -RetentionMonths 12 -RetentionYears 1
Set-OBRetentionPolicy -Policy $Policy -RetentionPolicy $RetentionPolicy

# Apply policy
Set-OBPolicy -Policy $Policy -Confirm:$false
```

#### Manual Backup Trigger
```powershell
# Start immediate backup
Start-OBBackup -Policy $Policy

# Check backup status
Get-OBJob -Last 5
```

### MARS Agent Recovery

#### Browse Recovery Points
```powershell
# Get available recovery points
$RecoveryPoints = Get-OBRecoveryPoint
$RecoveryPoints | Select-Object BackupTime, IsComplete

# Get specific recovery point
$RP = Get-OBRecoveryPoint -StartDate "2024-01-01" -EndDate "2024-01-31"
```

#### File Recovery
```powershell
# Start recovery wizard
Start-OBRecovery -RecoveryPoint $RecoveryPoints[0]

# Recover to original location
$RecoveryOption = New-OBRecoveryOption -DestinationPath "C:\RecoveredData" -OverwriteType CreateCopy
Start-OBRecovery -RecoveryPoint $RecoveryPoints[0] -RecoveryOption $RecoveryOption
```

#### System State Recovery
```powershell
# Backup system state
$SystemStatePolicy = New-OBPolicy
$SystemStateFileSpec = New-OBFileSpec -SystemState
Add-OBFileSpec -Policy $SystemStatePolicy -FileSpec $SystemStateFileSpec
Set-OBPolicy -Policy $SystemStatePolicy

# Recover system state
Start-OBSystemStateRecovery -RecoveryPoint $RecoveryPoints[0] -AlternateLocation "C:\SystemStateRestore"
```

## File Share Backup

### Azure Files Backup Setup

#### Enable Backup via Portal
1. Navigate to **Storage Account**
2. Select **File shares** under Data storage
3. Choose file share to backup
4. Click **Backup** in the toolbar
5. Select or create Recovery Services vault
6. Choose backup policy
7. Click **Enable backup**

#### PowerShell Configuration
```powershell
# Variables
$resourceGroupName = "rg-storage"
$storageAccountName = "mystorageaccount"
$fileShareName = "myfileshare"
$vaultName = "rsv-backup-vault"

# Get storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

# Register storage account for backup
Register-AzRecoveryServicesBackupContainer -ResourceGroupName $resourceGroupName -Name $storageAccountName -ServiceType AzureStorage -WorkloadType AzureFiles

# Get backup policy
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultAzureFileSharePolicy"

# Enable backup protection
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $resourceGroupName -Name $fileShareName -Policy $policy
```

### File Share Backup Policy
```powershell
# Create custom file share backup policy
$schedulePolicy = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType AzureFiles
$schedulePolicy.ScheduleRunTimes[0] = "2024-01-01 03:00:00"
$schedulePolicy.ScheduleRunFrequency = "Daily"

$retentionPolicy = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureFiles
$retentionPolicy.DailySchedule.DurationCountInDays = 30
$retentionPolicy.WeeklySchedule.DurationCountInWeeks = 12
$retentionPolicy.MonthlySchedule.DurationCountInMonths = 12

New-AzRecoveryServicesBackupProtectionPolicy -Name "CustomFileSharePolicy" -WorkloadType AzureFiles -RetentionPolicy $retentionPolicy -SchedulePolicy $schedulePolicy
```

### File Share Recovery
```powershell
# Get backup item
$backupItem = Get-AzRecoveryServicesBackupItem -WorkloadType AzureFiles -Name $fileShareName

# Get recovery points
$recoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupItem

# Full share restore to original location
Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -ResolveConflict Overwrite

# Restore to alternate location
Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -TargetStorageAccountName "targetstorageaccount" -TargetFileShareName "targetshare" -TargetFolder "RestoreFolder"

# Item-level restore
$recoveryConfig = Get-AzRecoveryServicesBackupWorkloadRecoveryConfig -RecoveryPoint $recoveryPoints[0] -TargetItem "/folder/file.txt"
Restore-AzRecoveryServicesBackupItem -WLRecoveryConfig $recoveryConfig
```

## Web App Backup

### App Service Backup Configuration

#### Enable via Portal
1. Navigate to **App Service**
2. Go to **Settings** > **Backups**
3. Click **Configure**
4. Select storage account and container
5. Configure backup schedule
6. Include/exclude databases
7. Click **Save**

#### PowerShell Setup
```powershell
# Variables
$resourceGroupName = "rg-webapp"
$webAppName = "mywebapp"
$storageAccountName = "backupstorageaccount"
$containerName = "webappbackups"

# Get web app
$webApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName

# Get storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value

# Create backup configuration
$backupConfig = @{
    Name = "DailyBackup"
    StorageAccountUrl = "https://$storageAccountName.blob.core.windows.net/$containerName"
    FrequencyInterval = 1
    FrequencyUnit = "Day"
    RetentionPeriodInDays = 30
    StartTime = "2024-01-01T02:00:00"
    KeepAtLeastOneBackup = $true
    Databases = @()
}

# Apply backup configuration
Set-AzWebAppBackupConfiguration -ResourceGroupName $resourceGroupName -Name $webAppName -BackupName $backupConfig.Name -StorageAccountUrl $backupConfig.StorageAccountUrl -FrequencyInterval $backupConfig.FrequencyInterval -FrequencyUnit $backupConfig.FrequencyUnit -RetentionPeriodInDays $backupConfig.RetentionPeriodInDays -StartTime $backupConfig.StartTime
```

### Database Backup with Web App
```powershell
# Include SQL Database in backup
$databaseConfig = @{
    ConnectionString = "Server=myserver.database.windows.net;Database=mydatabase;User Id=myuser;Password=mypassword;"
    DatabaseType = "SqlAzure"
    Name = "MyDatabase"
}

$backupConfig.Databases += $databaseConfig
Set-AzWebAppBackupConfiguration -ResourceGroupName $resourceGroupName -Name $webAppName -BackupName $backupConfig.Name -StorageAccountUrl $backupConfig.StorageAccountUrl -FrequencyInterval $backupConfig.FrequencyInterval -FrequencyUnit $backupConfig.FrequencyUnit -RetentionPeriodInDays $backupConfig.RetentionPeriodInDays -StartTime $backupConfig.StartTime -Databases $backupConfig.Databases
```

### Web App Restore
```powershell
# List available backups
$backups = Get-AzWebAppBackupList -ResourceGroupName $resourceGroupName -Name $webAppName

# Restore from backup
Restore-AzWebAppBackup -ResourceGroupName $resourceGroupName -Name $webAppName -BackupId $backups[0].BackupId -Overwrite

# Restore to different app
Restore-AzWebAppBackup -ResourceGroupName $resourceGroupName -Name $webAppName -BackupId $backups[0].BackupId -TargetResourceGroupName "rg-webapp-restore" -TargetName "mywebapp-restored"
```

## Backup Reports

### Configure Backup Reports

#### Log Analytics Workspace Setup
```powershell
# Create Log Analytics workspace for backup reports
$workspaceName = "law-backup-reports"
$resourceGroupName = "sa1_test_eic_SudarshanDarade"

New-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName -Location "East US" -Sku "PerGB2018"

# Configure diagnostic settings for Recovery Services vault
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name "rsv-backup-vault"
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName

$diagnosticSetting = @{
    Name = "BackupDiagnostics"
    ResourceId = $vault.ID
    WorkspaceId = $workspace.ResourceId
    Enabled = $true
    Categories = @("AzureBackupReport", "CoreAzureBackup", "AddonAzureBackupJobs", "AddonAzureBackupAlerts", "AddonAzureBackupPolicy", "AddonAzureBackupStorage", "AddonAzureBackupProtectedInstance")
}

Set-AzDiagnosticSetting @diagnosticSetting
```

#### Backup Reports Workbook
1. Navigate to **Azure Monitor**
2. Go to **Workbooks** > **Public Templates**
3. Search for "Backup Reports"
4. Click **Backup Reports** template
5. Configure parameters:
   - Subscription
   - Resource Group
   - Recovery Services Vault
   - Time Range

### Custom Backup Queries
```kql
// Backup job success rate
AddonAzureBackupJobs
| where TimeGenerated > ago(30d)
| summarize Total = count(), Successful = countif(JobStatus == "Completed") by bin(TimeGenerated, 1d)
| extend SuccessRate = (Successful * 100.0) / Total
| render timechart

// Backup storage consumption
AddonAzureBackupStorage
| where TimeGenerated > ago(30d)
| summarize StorageConsumed = sum(StorageConsumedInMBs) by BackupItemUniqueId, bin(TimeGenerated, 1d)
| render timechart

// Failed backup jobs
AddonAzureBackupJobs
| where JobStatus == "Failed"
| where TimeGenerated > ago(7d)
| summarize count() by BackupItemUniqueId, JobFailureCode
| order by count_ desc
```

## Backup Vault for VM and Blob

### Backup Vault Overview
Backup Vault is the next-generation backup solution supporting newer workloads like Azure Database for PostgreSQL, Azure Blobs, and Azure Disks.

### Create Backup Vault
```powershell
# Create Backup Vault
$resourceGroupName = "sa1_test_eic_SudarshanDarade"
$vaultName = "bv-backup-vault"
$location = "East US"

# Create resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Backup Vault
$vault = New-AzDataProtectionBackupVault -ResourceGroupName $resourceGroupName -VaultName $vaultName -Location $location -StorageSetting @{Type="LocallyRedundant"; CrossRegionRestore="Disabled"}
```

### VM Backup with Backup Vault
```powershell
# Create backup policy for VM
$policyTemplate = Get-AzDataProtectionPolicyTemplate -DatasourceType AzureDisk
$policy = New-AzDataProtectionBackupPolicy -ResourceGroupName $resourceGroupName -VaultName $vaultName -Name "VMDiskPolicy" -Policy $policyTemplate

# Configure backup for VM disk
$vmId = "/subscriptions/subscription-id/resourceGroups/rg-vm/providers/Microsoft.Compute/virtualMachines/myvm"
$diskId = "/subscriptions/subscription-id/resourceGroups/rg-vm/providers/Microsoft.Compute/disks/myvm-disk"

$backupInstance = Initialize-AzDataProtectionBackupInstance -DatasourceType AzureDisk -DatasourceLocation $location -PolicyId $policy.Id -DatasourceId $diskId
New-AzDataProtectionBackupInstance -ResourceGroupName $resourceGroupName -VaultName $vaultName -BackupInstance $backupInstance
```

### Blob Backup Configuration
```powershell
# Enable operational backup for blobs
$storageAccountId = "/subscriptions/subscription-id/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/mystorageaccount"

# Create backup policy for blobs
$blobPolicyTemplate = Get-AzDataProtectionPolicyTemplate -DatasourceType AzureBlob
$blobPolicy = New-AzDataProtectionBackupPolicy -ResourceGroupName $resourceGroupName -VaultName $vaultName -Name "BlobBackupPolicy" -Policy $blobPolicyTemplate

# Configure backup for storage account
$blobBackupInstance = Initialize-AzDataProtectionBackupInstance -DatasourceType AzureBlob -DatasourceLocation $location -PolicyId $blobPolicy.Id -DatasourceId $storageAccountId
New-AzDataProtectionBackupInstance -ResourceGroupName $resourceGroupName -VaultName $vaultName -BackupInstance $blobBackupInstance
```

### Point-in-Time Restore for Blobs
```powershell
# Get backup instance
$backupInstance = Get-AzDataProtectionBackupInstance -ResourceGroupName $resourceGroupName -VaultName $vaultName -Name "mystorageaccount-mystorageaccount"

# Get recovery points
$recoveryPoints = Get-AzDataProtectionRecoveryPoint -ResourceGroupName $resourceGroupName -VaultName $vaultName -BackupInstanceName $backupInstance.Name

# Restore to point in time
$restoreRequest = Initialize-AzDataProtectionRestoreRequest -DatasourceType AzureBlob -SourceDataStore OperationalStore -RestoreLocation $location -RestoreType OriginalLocation -PointInTime "2024-01-15T10:00:00.0000000Z"

Start-AzDataProtectionBackupInstanceRestore -ResourceGroupName $resourceGroupName -VaultName $vaultName -BackupInstanceName $backupInstance.Name -Parameter $restoreRequest
```

## Advanced Backup Features

### Cross Region Restore
```powershell
# Enable Cross Region Restore
Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy GeoRedundant -CrossRegionRestore Enabled

# Restore VM in secondary region
$secondaryRegion = "West US"
$crrJob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -TargetResourceGroupName "rg-vm-secondary" -UseSecondaryRegion -TargetRegion $secondaryRegion
```

### Soft Delete Protection
```powershell
# Enable soft delete
Set-AzRecoveryServicesVaultProperty -Vault $vault -SoftDeleteFeatureState Enable

# Disable soft delete
Set-AzRecoveryServicesVaultProperty -Vault $vault -SoftDeleteFeatureState Disable

# Undelete backup item
$deletedItems = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM -DeleteState Deleted
Undo-AzRecoveryServicesBackupItemDeletion -Item $deletedItems[0]
```

### Backup Encryption
```powershell
# Configure customer-managed keys
$keyVaultId = "/subscriptions/subscription-id/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/mykeyvault"
$keyName = "backup-encryption-key"
$keyVersion = "key-version"

Set-AzRecoveryServicesVaultProperty -Vault $vault -EncryptionKeyId "$keyVaultId/keys/$keyName/$keyVersion"
```

## Monitoring and Alerting

### Backup Alerts
```powershell
# Create backup alert rule
$actionGroup = Get-AzActionGroup -ResourceGroupName $resourceGroupName -Name "BackupAlerts"

$criteria = New-AzMetricAlertRuleV2Criteria -MetricName "BackupHealthEvent" -Operator GreaterThan -Threshold 0
$alertRule = Add-AzMetricAlertRuleV2 -Name "BackupFailureAlert" -ResourceGroupName $resourceGroupName -WindowSize 00:05:00 -Frequency 00:01:00 -TargetResourceId $vault.ID -Condition $criteria -ActionGroupId $actionGroup.Id -Severity 2
```

### Backup Health Monitoring
```kql
// Backup health dashboard query
AddonAzureBackupAlerts
| where TimeGenerated > ago(24h)
| summarize AlertCount = count() by AlertStatus, AlertCode
| render piechart
```

## Best Practices

### Security
- Use managed identities for authentication
- Enable soft delete protection
- Implement RBAC for backup operations
- Regular security audits

### Performance
- Schedule backups during off-peak hours
- Use incremental backups
- Monitor backup job performance
- Optimize retention policies

### Cost Management
- Right-size backup policies
- Use appropriate storage redundancy
- Monitor backup storage consumption
- Implement lifecycle policies

### Compliance
- Document backup procedures
- Regular restore testing
- Maintain backup logs
- Compliance reporting

## Portal Best Practices

### Security Best Practices
1. **Access Control**
   - Implement Azure RBAC for backup operations
   - Use managed identities where possible
   - Regular access reviews and audits
   - Enable MFA for critical operations

2. **Data Protection**
   - Enable soft delete for accidental deletion protection
   - Use customer-managed keys for encryption
   - Implement cross-region restore for critical workloads
   - Regular security assessments

### Operational Excellence
1. **Backup Strategy**
   - Define clear backup and retention policies
   - Regular backup testing and validation
   - Document recovery procedures
   - Implement automated monitoring

2. **Performance Optimization**
   - Schedule backups during off-peak hours
   - Use incremental backups to reduce time and storage
   - Monitor backup job performance
   - Optimize network bandwidth usage

### Cost Management
1. **Storage Optimization**
   - Choose appropriate storage redundancy levels
   - Implement lifecycle policies for long-term retention
   - Monitor storage consumption trends
   - Use backup vault for newer workloads

2. **Policy Management**
   - Right-size retention policies based on requirements
   - Regular policy reviews and optimization
   - Use appropriate backup frequencies
   - Implement data archival strategies

### Monitoring and Alerting
1. **Proactive Monitoring**
   - Configure comprehensive backup alerts
   - Monitor backup health and job success rates
   - Set up automated reporting
   - Regular backup validation

2. **Troubleshooting**
   - Maintain backup job logs
   - Quick issue identification and resolution
   - Regular agent health checks
   - Network connectivity monitoring
# Task 33: Azure Backup Advanced Features

## MARS Agent (Microsoft Azure Recovery Services Agent)

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
$resourceGroupName = "rg-backup"

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
$resourceGroupName = "rg-backup"
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
# Task 32: Azure Backup

## Overview
Azure Backup is a cloud-based backup service that protects data in Microsoft Azure. It provides secure, cost-effective backup solutions for VMs, files, databases, and applications with centralized management through Recovery Services vaults.

## Azure Backup Features

### Key Capabilities
- **Application-consistent backups** - Ensures data integrity
- **Incremental backups** - Only changed data after initial backup
- **Long-term retention** - Up to 99 years retention
- **Cross-region restore** - Restore in different Azure regions
- **Instant restore** - Fast recovery using snapshots
- **Encryption** - Data encrypted in transit and at rest
- **Role-based access control** - Granular permissions

### Backup Types
- **Azure VM Backup** - Full VM protection
- **Azure Files Backup** - File share protection
- **SQL Server in Azure VM** - Database backup
- **SAP HANA in Azure VM** - Enterprise database backup
- **Azure Database for PostgreSQL** - Managed database backup

### Backup Policies
- **Daily backup** - Once per day
- **Weekly backup** - Specific days of week
- **Monthly backup** - Specific date each month
- **Yearly backup** - Long-term archival

## Create Recovery Services Vault

### Method 1: Azure Portal
1. Navigate to **Recovery Services vaults**
2. Click **+ Create**
3. Configure basic settings:
   - **Subscription**: Select subscription
   - **Resource group**: Create or select existing
   - **Vault name**: Enter unique name
   - **Region**: Select location
4. Click **Review + create**
5. Click **Create**

### Method 2: PowerShell
```powershell
# Create Recovery Services Vault
$resourceGroupName = "rg-backup"
$vaultName = "rsv-backup-vault"
$location = "East US"

# Create resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Recovery Services Vault
New-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName -Location $location

# Set vault context
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName
Set-AzRecoveryServicesVaultContext -Vault $vault

# Configure backup storage redundancy
Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy LocallyRedundant
```

### Method 3: Azure CLI
```bash
# Create resource group
az group create --name rg-backup --location eastus

# Create Recovery Services Vault
az backup vault create \
  --resource-group rg-backup \
  --name rsv-backup-vault \
  --location eastus

# Set backup storage redundancy
az backup vault backup-properties set \
  --name rsv-backup-vault \
  --resource-group rg-backup \
  --backup-storage-redundancy LocallyRedundant
```

### Method 4: ARM Template
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vaultName": {
      "type": "string",
      "defaultValue": "rsv-backup-vault"
    }
  },
  "resources": [
    {
      "type": "Microsoft.RecoveryServices/vaults",
      "apiVersion": "2021-01-01",
      "name": "[parameters('vaultName')]",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "RS0",
        "tier": "Standard"
      },
      "properties": {}
    }
  ]
}
```

## VM Backup and Restore

### Enable VM Backup

#### Method 1: Azure Portal
1. Navigate to **Virtual machines**
2. Select VM to backup
3. Go to **Operations** > **Backup**
4. Select Recovery Services vault
5. Choose backup policy or create new
6. Click **Enable backup**

#### Method 2: PowerShell
```powershell
# Enable VM backup
$resourceGroupName = "rg-vm"
$vmName = "myvm"
$vaultName = "rsv-backup-vault"
$policyName = "DefaultPolicy"

# Get vault and set context
$vault = Get-AzRecoveryServicesVault -ResourceGroupName rg-backup -Name $vaultName
Set-AzRecoveryServicesVaultContext -Vault $vault

# Get backup policy
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyName

# Enable backup for VM
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $resourceGroupName -Name $vmName -Policy $policy
```

### Create Backup Policy
```powershell
# Create custom backup policy
$schedulePolicy = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType AzureVM
$schedulePolicy.ScheduleRunTimes[0] = "2024-01-01 02:00:00"
$schedulePolicy.ScheduleRunFrequency = "Daily"

$retentionPolicy = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureVM
$retentionPolicy.DailySchedule.DurationCountInDays = 30
$retentionPolicy.WeeklySchedule.DurationCountInWeeks = 12
$retentionPolicy.MonthlySchedule.DurationCountInMonths = 12
$retentionPolicy.YearlySchedule.DurationCountInYears = 1

New-AzRecoveryServicesBackupProtectionPolicy -Name "CustomVMPolicy" -WorkloadType AzureVM -RetentionPolicy $retentionPolicy -SchedulePolicy $schedulePolicy
```

### Trigger On-Demand Backup
```powershell
# Trigger immediate backup
$backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -Name $vmName
Backup-AzRecoveryServicesBackupItem -Item $backupItem
```

### VM Restore Options

#### Full VM Restore
```powershell
# Get recovery points
$backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -Name $vmName
$recoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupItem

# Restore VM to new location
$restoreJob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -StorageAccountName "mystorageaccount" -StorageAccountResourceGroupName "rg-storage"
```

#### Disk Restore
```powershell
# Restore disks only
$restoreJob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -RestoreOnlyOSDisk -StorageAccountName "mystorageaccount" -StorageAccountResourceGroupName "rg-storage"
```

#### File Recovery
1. Navigate to **Recovery Services vault**
2. Go to **Backup items** > **Azure Virtual Machine**
3. Select VM and recovery point
4. Click **File Recovery**
5. Download executable script
6. Run script on target machine
7. Browse and copy required files
8. Unmount when complete

## File Backup and Restore

### Azure Files Backup

#### Enable Azure Files Backup
1. Navigate to **Storage accounts**
2. Select storage account with file shares
3. Go to **Data management** > **Backup**
4. Select file share to backup
5. Choose Recovery Services vault
6. Configure backup policy
7. Click **Enable backup**

#### PowerShell Configuration
```powershell
# Enable Azure Files backup
$storageAccountName = "mystorageaccount"
$fileShareName = "myfileshare"
$resourceGroupName = "rg-storage"

# Register storage account
Register-AzRecoveryServicesBackupContainer -ResourceGroupName $resourceGroupName -Name $storageAccountName -ServiceType AzureStorage

# Get backup policy
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultAzureFileSharePolicy"

# Enable backup
Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $resourceGroupName -Name $fileShareName -Policy $policy
```

### File Share Restore

#### Full Share Restore
```powershell
# Get backup item
$backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureFiles -Name $fileShareName

# Get recovery points
$recoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupItem

# Restore to original location
Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -ResolveConflict Overwrite

# Restore to alternate location
Restore-AzRecoveryServicesBackupItem -RecoveryPoint $recoveryPoints[0] -TargetStorageAccountName "targetstorageaccount" -TargetFileShareName "targetshare"
```

#### Item-Level Recovery
```powershell
# Restore specific files/folders
$recoveryConfig = Get-AzRecoveryServicesBackupWorkloadRecoveryConfig -RecoveryPoint $recoveryPoints[0] -TargetItem $targetItem
Restore-AzRecoveryServicesBackupItem -WLRecoveryConfig $recoveryConfig
```

### On-Premises File Backup (MARS Agent)

#### Install MARS Agent
1. Download Microsoft Azure Recovery Services Agent
2. Run installation with vault credentials
3. Configure proxy settings if needed
4. Register with Recovery Services vault

#### Configure Backup
```powershell
# Schedule backup using MARS agent
$policy = New-OBPolicy
$fileSpec = New-OBFileSpec -FileSpec "C:\ImportantData"
Add-OBFileSpec -Policy $policy -FileSpec $fileSpec

$schedule = New-OBSchedule -DaysOfWeek Monday,Wednesday,Friday -TimesOfDay 02:00
Set-OBSchedule -Policy $policy -Schedule $schedule

$retention = New-OBRetentionPolicy -RetentionDays 30
Set-OBRetentionPolicy -Policy $policy -RetentionPolicy $retention

Set-OBPolicy -Policy $policy -Confirm:$false
```

## Remove Data from Recovery Vault

### Stop Backup Protection

#### Retain Backup Data
```powershell
# Stop backup but keep existing recovery points
$backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -Name $vmName
Disable-AzRecoveryServicesBackupProtection -Item $backupItem -RemoveRecoveryPoints:$false
```

#### Delete Backup Data
```powershell
# Stop backup and delete all recovery points
Disable-AzRecoveryServicesBackupProtection -Item $backupItem -RemoveRecoveryPoints:$true -Force
```

### Delete Recovery Points
```powershell
# Delete specific recovery point
$recoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupItem
Remove-AzRecoveryServicesBackupRecoveryPoint -RecoveryPoint $recoveryPoints[0] -Force
```

### Delete Recovery Services Vault

#### Prerequisites Check
```powershell
# Check for backup items
Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM

# Check for backup containers
Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM

# Check for registered servers
Get-AzRecoveryServicesBackupContainer -ContainerType Windows
```

#### Delete Vault
```powershell
# Remove all backup items first
$backupItems = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
foreach ($item in $backupItems) {
    Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints:$true -Force
}

# Unregister backup containers
$containers = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM
foreach ($container in $containers) {
    Unregister-AzRecoveryServicesBackupContainer -Container $container
}

# Delete vault
Remove-AzRecoveryServicesVault -Vault $vault -Force
```

## Backup Monitoring and Management

### Backup Jobs Monitoring
```powershell
# Get backup jobs
Get-AzRecoveryServicesBackupJob -Status InProgress
Get-AzRecoveryServicesBackupJob -Status Failed
Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-7)

# Get job details
$job = Get-AzRecoveryServicesBackupJob -JobId "job-id"
Get-AzRecoveryServicesBackupJobDetail -Job $job
```

### Backup Reports
```powershell
# Configure backup reports
$storageAccount = Get-AzStorageAccount -ResourceGroupName "rg-storage" -Name "reportsstorageaccount"
Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy GeoRedundant -CrossRegionRestore Enabled
```

### Alerts Configuration
1. Navigate to **Recovery Services vault**
2. Go to **Monitoring** > **Backup Alerts**
3. Configure alert rules for:
   - Backup failures
   - Restore failures
   - Configuration issues

## Best Practices

### Security
- Enable soft delete for accidental deletion protection
- Use Azure RBAC for access control
- Enable MFA for critical operations
- Regular security reviews

### Cost Optimization
- Choose appropriate backup frequency
- Configure retention policies based on requirements
- Use incremental backups
- Monitor backup storage consumption

### Performance
- Schedule backups during off-peak hours
- Use instant restore for faster recovery
- Implement backup policy optimization
- Regular backup testing

### Compliance
- Document backup procedures
- Regular restore testing
- Compliance reporting
- Audit backup activities

## Troubleshooting

### Common Issues
1. **Backup failures**
   - Check VM agent status
   - Verify network connectivity
   - Review error codes

2. **Slow backup performance**
   - Check VM performance
   - Network bandwidth issues
   - Storage throttling

3. **Restore failures**
   - Verify target location capacity
   - Check permissions
   - Network connectivity

### Error Resolution
```powershell
# Check backup item health
$backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -Name $vmName
$backupItem.HealthStatus

# Get error details
Get-AzRecoveryServicesBackupJob -Status Failed | Get-AzRecoveryServicesBackupJobDetail
```
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

## Method 1: Using Azure Portal (GUI)

### Create Recovery Services Vault via Portal

1. **Navigate to Recovery Services Vaults**
   - Go to Azure Portal → Search "Recovery Services vaults"
   - Click **Create**

2. **Configure Vault Settings**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Vault name**: `rsv-backup-vault-portal`
   - **Region**: `Southeast Asia`

3. **Review and Create**
   - Click **Review + create**
   - Click **Create**

4. **Configure Vault Properties**
   - Go to created vault
   - Select **Properties** under **Settings**
   - **Backup Configuration**:
     - **Storage replication type**: `Locally-redundant storage (LRS)`
     - **Cross Region Restore**: `Enable` (for GRS)
   - **Security Settings**:
     - **Soft Delete**: `Enable`
     - **Security PIN**: `Enable`
   - Click **Save**

### Enable VM Backup via Portal

1. **Navigate to Virtual Machine**
   - Go to **Virtual machines**
   - Select VM to backup: `vm-web-server`
   - Go to **Operations** → **Backup**

2. **Configure Backup Settings**
   - **Recovery Services vault**: Select `rsv-backup-vault-portal`
   - **Choose backup policy**: Select existing or create new
   - Click **Enable backup**

3. **Create Custom Backup Policy**
   - Click **Create a new policy**
   - **Policy name**: `CustomVMPolicy-Portal`
   - **Backup schedule**:
     - **Frequency**: `Daily`
     - **Time**: `2:00 AM`
     - **Timezone**: `(UTC+08:00) Kuala Lumpur, Singapore`
   - **Retention range**:
     - **Daily backup retention**: `30 days`
     - **Weekly backup retention**: `12 weeks` (Sunday)
     - **Monthly backup retention**: `12 months` (First Sunday)
     - **Yearly backup retention**: `1 year` (First Sunday of January)
   - Click **OK**

4. **Monitor Backup Enablement**
   - Go to Recovery Services vault
   - Select **Backup items** under **Protected items**
   - Verify VM appears in list
   - Check **Backup status**: `Healthy`

### Trigger On-Demand Backup via Portal

1. **Access Backup Items**
   - Go to Recovery Services vault
   - Select **Backup items** → **Azure Virtual Machine**
   - Click on VM name

2. **Initiate Backup**
   - Click **Backup now**
   - **Retain backup till**: Select date (default 30 days)
   - Click **OK**

3. **Monitor Backup Job**
   - Go to **Backup jobs** under **Monitoring**
   - View job status and progress
   - Check completion time and details

### VM Restore via Portal

#### Full VM Restore
1. **Access Recovery Points**
   - Go to vault → **Backup items** → **Azure Virtual Machine**
   - Click on VM name
   - Click **Restore VM**

2. **Select Recovery Point**
   - **Recovery point**: Choose from calendar view
   - **Recovery point type**: 
     - `Crash-consistent` (faster)
     - `App-consistent` (recommended)
   - Click **OK**

3. **Configure Restore Settings**
   - **Restore Type**: 
     - `Create new virtual machine`
     - `Replace existing`
     - `Restore disks`
   - **Virtual machine name**: `vm-restored-portal`
   - **Resource group**: Select target group
   - **Virtual network**: Select VNet
   - **Subnet**: Select subnet
   - **Storage account**: Select for staging
   - Click **Restore**

#### Disk Restore
1. **Select Restore Disks**
   - Choose **Restore disks** option
   - **Storage account**: Select staging account
   - **Resource group**: Target resource group
   - Click **Restore**

2. **Create VM from Restored Disks**
   - Go to **Backup jobs** and wait for completion
   - Navigate to storage account
   - Find restored VHD files
   - Use **Deploy template** from job details
   - Configure new VM settings
   - Click **Create**

#### File-Level Recovery
1. **Access File Recovery**
   - Go to backup item → **File Recovery**
   - Select recovery point
   - Click **Download Executable**

2. **Mount Recovery Point**
   - Download and run executable on target machine
   - Script will mount recovery point as drive
   - Browse mounted drive for required files
   - Copy files to desired location

3. **Unmount Recovery Point**
   - Run unmount command from script
   - Or use portal **Unmount Disks** option

### Azure Files Backup via Portal

1. **Navigate to Storage Account**
   - Go to **Storage accounts**
   - Select storage account with file shares
   - Go to **Data management** → **Backup**

2. **Configure File Share Backup**
   - **File shares**: Select shares to backup
   - **Recovery Services vault**: Select vault
   - **Backup policy**: Choose or create policy
   - Click **Enable backup**

3. **Create File Share Backup Policy**
   - **Policy name**: `FileSharePolicy-Portal`
   - **Backup schedule**:
     - **Frequency**: `Daily`
     - **Time**: `3:00 AM`
   - **Retention**:
     - **Daily**: `30 days`
     - **Weekly**: `12 weeks`
     - **Monthly**: `12 months`
   - Click **Create**

### File Share Restore via Portal

1. **Access File Share Backup**
   - Go to vault → **Backup items** → **Azure Storage (Azure Files)**
   - Click on file share name
   - Click **Restore**

2. **Select Restore Type**
   - **Full Share**: Restore entire file share
   - **Item Level**: Restore specific files/folders

3. **Configure Full Share Restore**
   - **Recovery point**: Select from available points
   - **Restore location**:
     - `Original location` (overwrite)
     - `Alternate location`
   - For alternate location:
     - **Storage account**: Target account
     - **File share**: Target share name
   - Click **Restore**

4. **Configure Item-Level Restore**
   - **Recovery point**: Select point
   - **Restore location**: Original or alternate
   - **Files and folders**: Browse and select items
   - **Restore options**: Skip, Replace, or Create copy
   - Click **Restore**

### MARS Agent Installation via Portal

1. **Download MARS Agent**
   - Go to Recovery Services vault
   - Select **Backup** under **Getting Started**
   - **Where is your workload running?**: `On-premises`
   - **What do you want to backup?**: `Files and folders`
   - Click **Download Agent for Windows Server**

2. **Download Vault Credentials**
   - Click **Download** vault credentials
   - Save file to server being backed up

3. **Install MARS Agent**
   - Run downloaded installer on target server
   - Follow installation wizard
   - **Installation folder**: Default or custom path
   - **Proxy configuration**: Configure if needed
   - Click **Install**

4. **Register Server**
   - Launch **Microsoft Azure Backup** console
   - Click **Register Server**
   - **Vault credentials file**: Browse and select downloaded file
   - **Encryption settings**: Generate or provide passphrase
   - **Passphrase location**: Save securely
   - Click **Finish**

### Configure On-Premises Backup via Portal

1. **Schedule Backup**
   - Open **Microsoft Azure Backup** console
   - Click **Schedule Backup**
   - **Items to backup**: Select files/folders
     - Add: `C:\ImportantData`
     - Add: `C:\DatabaseBackups`
   - **Backup schedule**:
     - **Frequency**: `Daily`
     - **Time**: `11:00 PM`
   - **Retention policy**:
     - **Daily**: `30 days`
     - **Weekly**: `12 weeks`
     - **Monthly**: `12 months`
   - Click **Finish**

2. **Perform Initial Backup**
   - Click **Back Up Now**
   - **Retain backup till**: Select date
   - **Backup options**: Online or offline
   - Click **Back Up**

### Backup Monitoring via Portal

1. **Monitor Backup Jobs**
   - Go to Recovery Services vault
   - Select **Backup jobs** under **Monitoring**
   - **Filter options**:
     - **Time range**: Last 24 hours, 7 days, etc.
     - **Status**: All, In progress, Failed, Completed
     - **Workload type**: Azure VM, Azure Files, etc.

2. **View Job Details**
   - Click on specific job
   - View **Job details**:
     - Start time, duration, status
     - Error messages (if failed)
     - Data transferred
     - Recovery point created

3. **Backup Alerts**
   - Go to **Backup Alerts** under **Monitoring**
   - View active alerts:
     - Backup failures
     - Configuration issues
     - Agent connectivity problems
   - Configure alert rules:
     - **Alert type**: Critical, Warning, Information
     - **Notification**: Email, SMS, webhook

### Backup Reports via Portal

1. **Configure Backup Reports**
   - Go to vault → **Backup Reports** under **Monitoring**
   - **Configure workspace**: Select Log Analytics workspace
   - **Storage account**: Select for report data
   - Click **Configure**

2. **View Reports**
   - **Summary**: Overall backup health
   - **Backup Items**: Protected items status
   - **Usage**: Storage consumption trends
   - **Jobs**: Backup job success/failure rates
   - **Policies**: Policy compliance

### Manage Backup Policies via Portal

1. **View Backup Policies**
   - Go to vault → **Backup policies** under **Manage**
   - View existing policies by workload type

2. **Modify Backup Policy**
   - Click on policy name
   - **Backup schedule**: Modify frequency/time
   - **Retention range**: Adjust retention periods
   - **Advanced settings**: Configure as needed
   - Click **Save**

3. **Delete Backup Policy**
   - Select policy (must have no associated items)
   - Click **Delete**
   - Confirm deletion

### Stop Backup Protection via Portal

1. **Access Backup Item**
   - Go to vault → **Backup items**
   - Select workload type
   - Click on item name

2. **Stop Backup Options**
   - Click **Stop backup**
   - **Choose option**:
     - `Retain backup data` (keep existing recovery points)
     - `Delete backup data` (remove all recovery points)
   - **Reason**: Select from dropdown
   - **Comments**: Add explanation
   - Type item name to confirm
   - Click **Stop backup**

### Delete Recovery Services Vault via Portal

1. **Prerequisites Check**
   - Ensure no backup items exist
   - Stop protection for all items
   - Delete all backup data
   - Unregister all servers

2. **Delete Vault**
   - Go to vault **Overview**
   - Click **Delete**
   - **Type vault name**: Confirm deletion
   - Click **Delete**

### Troubleshooting via Portal

1. **Check Backup Health**
   - Go to vault → **Backup items**
   - Review **Backup status** column
   - Click on items with issues

2. **Review Failed Jobs**
   - Go to **Backup jobs**
   - Filter by **Status**: `Failed`
   - Click on failed job for details
   - Review error codes and messages

3. **Agent Connectivity Issues**
   - Go to **Backup Infrastructure** → **Protected Servers**
   - Check **Connection Status**
   - Review **Last Contact Time**
   - Download latest agent if needed

4. **Common Solutions**
   - **VM Agent Issues**: Restart VM or reinstall agent
   - **Network Issues**: Check NSG rules and firewall
   - **Permission Issues**: Verify RBAC assignments
   - **Storage Issues**: Check available space

## Method 2: Using PowerShell and CLI

### Create Recovery Services Vault

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
$resourceGroupName = "sa1_test_eic_SudarshanDarade"
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
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia

# Create Recovery Services Vault
az backup vault create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name rsv-backup-vault \
  --location southeastasia

# Set backup storage redundancy
az backup vault backup-properties set \
  --name rsv-backup-vault \
  --resource-group sa1_test_eic_SudarshanDarade \
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
$vault = Get-AzRecoveryServicesVault -ResourceGroupName sa1_test_eic_SudarshanDarade -Name $vaultName
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

## Portal Best Practices

### Security Best Practices
1. **Access Control**
   - Use Azure RBAC for granular permissions
   - Implement least privilege access
   - Regular access reviews
   - Enable MFA for critical operations

2. **Data Protection**
   - Enable soft delete protection
   - Use cross-region restore for critical workloads
   - Implement backup encryption
   - Regular security assessments

### Cost Optimization
1. **Policy Management**
   - Right-size retention policies
   - Use appropriate backup frequencies
   - Implement lifecycle management
   - Regular policy reviews

2. **Storage Optimization**
   - Choose appropriate redundancy levels
   - Monitor storage consumption
   - Use incremental backups
   - Archive old recovery points

### Operational Excellence
1. **Monitoring and Alerting**
   - Configure comprehensive alerts
   - Regular backup health checks
   - Automated reporting
   - Proactive issue resolution

2. **Testing and Validation**
   - Regular restore testing
   - Disaster recovery drills
   - Backup validation procedures
   - Documentation updates

### Performance Optimization
1. **Backup Scheduling**
   - Schedule during off-peak hours
   - Distribute backup windows
   - Consider network bandwidth
   - Monitor backup duration

2. **Infrastructure Sizing**
   - Adequate network bandwidth
   - Sufficient storage performance
   - Proper VM sizing
   - Regular performance reviews
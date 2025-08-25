# Task 34: Azure Site Recovery (ASR)

## Overview
Azure Site Recovery is a disaster recovery service that helps ensure business continuity by keeping business apps and workloads running during outages. ASR replicates workloads from primary to secondary location and orchestrates recovery when outages occur.

## Key Features

### Disaster Recovery Capabilities
- **Continuous replication** - Real-time data synchronization
- **Automated failover** - Orchestrated recovery processes
- **Application-consistent snapshots** - Ensures data integrity
- **Recovery plans** - Automated multi-tier application recovery
- **Test failover** - Non-disruptive DR testing
- **Failback** - Return to primary site after recovery

### Supported Scenarios
- **Azure to Azure** - Between Azure regions
- **VMware to Azure** - On-premises VMware VMs to Azure
- **Hyper-V to Azure** - On-premises Hyper-V VMs to Azure
- **Physical servers to Azure** - Physical Windows/Linux servers to Azure

## Method 1: Using Azure Portal (GUI)

### Create Recovery Services Vault for ASR via Portal

1. **Navigate to Recovery Services Vaults**
   - Go to Azure Portal → Search "Recovery Services vaults"
   - Click **Create**

2. **Configure Vault Settings**
   - **Subscription**: Select your subscription
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Vault name**: `rsv-asr-vault-portal`
   - **Region**: `Southeast Asia` (primary region)

3. **Review and Create**
   - Click **Review + create**
   - Click **Create**

4. **Configure Vault Properties**
   - Go to created vault
   - Select **Properties** under **Settings**
   - **Storage replication type**: `Geo-redundant storage (GRS)`
   - **Cross Region Restore**: `Enable`
   - **Security Settings**:
     - **Soft Delete**: `Enable`
     - **Security PIN**: `Enable`
   - Click **Save**

### Azure to Azure Replication via Portal

1. **Enable Site Recovery**
   - Go to Recovery Services vault
   - Select **Site Recovery** under **Getting Started**
   - Click **Enable Site Recovery**

2. **Prepare Infrastructure**
   - **Source**: `Azure`
   - **Target**: `Azure`
   - **Source location**: `Southeast Asia`
   - **Target location**: `East Asia`
   - **Source resource group**: `rg-vm-source`
   - **Target resource group**: `rg-vm-target`
   - **Source virtual network**: `vnet-source`
   - **Target virtual network**: `vnet-target`
   - Click **OK**

3. **Configure Replication Settings**
   - **Replication policy**: Create new or select existing
   - **Policy name**: `A2A-ReplicationPolicy-Portal`
   - **Recovery point retention**: `24 hours`
   - **App-consistent snapshot frequency**: `4 hours`
   - **Replication frequency**: `5 minutes`
   - Click **Create**

4. **Enable Replication for VMs**
   - Click **Enable replication**
   - **Source**: Configure source settings
     - **Location**: `Southeast Asia`
     - **Resource group**: `rg-vm-source`
     - **Virtual machine deployment model**: `Resource Manager`
   - **Virtual machines**: Select VMs to replicate
     - Check `vm-web-server`
     - Check `vm-db-server`
   - Click **Next**

5. **Configure Target Settings**
   - **Target location**: `East Asia`
   - **Target resource group**: `rg-vm-target`
   - **Target virtual network**: `vnet-target`
   - **Target subnet**: `subnet-target`
   - **Target availability set**: None or select existing
   - **Cache storage account**: Select or create account
   - Click **Next**

6. **Configure Replication Policy**
   - **Replication policy**: Select created policy
   - Click **Next**

7. **Review and Enable**
   - Review all settings
   - Click **Enable replication**
   - Monitor replication enablement progress

### Monitor Replication Status via Portal

1. **View Replicated Items**
   - Go to vault → **Replicated items** under **Protected items**
   - View replication status for each VM:
     - **Status**: Protected, Enabling protection, etc.
     - **Replication health**: Healthy, Warning, Critical
     - **RPO**: Recovery Point Objective status
     - **Last recovery point**: Timestamp of latest point

2. **Detailed Replication Health**
   - Click on VM name for detailed view
   - **Overview**: General health and status
   - **Recovery points**: Available recovery points
   - **Latest recovery points**:
     - **Latest crash-consistent**: Most recent point
     - **Latest app-consistent**: Application-consistent point
   - **Replication health**: Detailed health information

3. **Infrastructure View**
   - Go to **Site Recovery Infrastructure**
   - **Azure virtual machines**: View protected VMs
   - **Replication policies**: View and manage policies
   - **Network mapping**: Source to target network mapping
   - **Storage mapping**: Storage account mappings

### Failover Operations via Portal

#### Test Failover
1. **Initiate Test Failover**
   - Go to **Replicated items**
   - Select VM: `vm-web-server`
   - Click **Test failover**

2. **Configure Test Failover**
   - **Recovery point**: Choose recovery point
     - `Latest processed (low RTO)`
     - `Latest app-consistent`
     - `Custom` (select specific point)
   - **Azure virtual network**: Select test network
     - `vnet-test` (isolated test network)
   - Click **OK**

3. **Monitor Test Failover**
   - Go to **Site Recovery jobs** under **Monitoring**
   - Monitor "Test failover" job progress
   - View job details and any errors

4. **Validate Test Environment**
   - Navigate to target resource group
   - Verify test VM creation
   - Connect and validate application functionality
   - Test network connectivity

5. **Cleanup Test Failover**
   - Return to replicated item
   - Click **Cleanup test failover**
   - **Notes**: Add test results and observations
   - Check **Testing is complete**
   - Click **OK**

#### Planned Failover
1. **Initiate Planned Failover**
   - Select replicated item
   - Click **Planned failover**
   - **Warning**: Planned failover will shut down source VM

2. **Configure Planned Failover**
   - **Failover direction**: `Southeast Asia to East Asia`
   - **Recovery point**: Select recovery point
   - **Shut down machines before beginning failover**: Check
   - Click **OK**

3. **Monitor and Commit**
   - Monitor failover job progress
   - After successful failover, click **Commit**
   - Confirm commit operation

#### Unplanned Failover
1. **Initiate Unplanned Failover**
   - Select replicated item
   - Click **Failover**
   - **Warning**: Source VMs may not be cleanly shut down

2. **Configure Unplanned Failover**
   - **Failover direction**: `Southeast Asia to East Asia`
   - **Recovery point**: Choose appropriate point
     - `Latest` (most recent data)
     - `Latest app-consistent` (application consistency)
   - Click **OK**

3. **Post-Failover Actions**
   - Monitor failover completion
   - Verify VM startup in target region
   - Update DNS records if needed
   - Commit failover when ready

### Recovery Plans via Portal

1. **Create Recovery Plan**
   - Go to vault → **Recovery Plans** under **Manage**
   - Click **Create recovery plan**
   - **Name**: `WebApp-RecoveryPlan-Portal`
   - **Source**: `Southeast Asia`
   - **Target**: `East Asia`
   - **Allow items with deployment model**: `Resource Manager`
   - Click **Select items**

2. **Add Items to Recovery Plan**
   - **Available items**: Select VMs to include
     - `vm-web-server` (Group 1)
     - `vm-db-server` (Group 1)
   - **Selected items**: Review selected VMs
   - Click **OK**

3. **Customize Recovery Plan**
   - Click **Customize** on created plan
   - **Groups**: Organize VMs into groups
     - **Group 1**: Database servers (start first)
     - **Group 2**: Web servers (start after Group 1)
   - **Add action**: Add scripts or manual actions
     - **Pre-action**: Scripts to run before group
     - **Post-action**: Scripts to run after group

4. **Add Scripts to Recovery Plan**
   - Click **Add action** → **Script**
   - **Action name**: `Start-DatabaseServices`
   - **Location**: `Primary side` or `Recovery side`
   - **Script location**: Azure Automation runbook
   - **Azure Automation Account**: Select account
   - **Runbook**: Select PowerShell runbook
   - Click **OK**

5. **Test Recovery Plan**
   - Click **Test failover** on recovery plan
   - **Recovery point**: Select point for all VMs
   - **Azure virtual network**: Select test network
   - Click **OK**
   - Monitor multi-VM failover progress

### VMware to Azure Replication via Portal

1. **Prepare Infrastructure**
   - Go to vault → **Site Recovery**
   - **Source**: `On-premises`
   - **Target**: `Azure`
   - **Machine type**: `VMware VMs`
   - Click **Prepare infrastructure**

2. **Download Configuration Server**
   - **Step 1**: Download Configuration Server OVA
   - **Step 2**: Download vault registration key
   - **Step 3**: Deploy OVA in VMware environment

3. **Configure On-Premises Environment**
   - Deploy Configuration Server VM from OVA
   - **Network settings**: Configure static IP
   - **Registration**: Use downloaded vault key
   - **MySQL setup**: Configure database
   - **Finalize setup**: Complete configuration

4. **Add VMware Servers**
   - Go to **Site Recovery Infrastructure** → **Configuration Servers**
   - Verify Configuration Server registration
   - **Process Servers**: View registered process servers
   - **vCenter Servers**: Add vCenter/vSphere hosts
     - **Server type**: `vCenter Server`
     - **Server FQDN/IP**: vCenter server address
     - **Credentials**: vCenter admin credentials

5. **Enable Replication for VMware VMs**
   - Click **Enable replication**
   - **Source**: Configure source environment
     - **Source location**: On-premises
     - **Source machine type**: VMware VMs
     - **Configuration Server**: Select server
   - **Virtual machines**: Select VMs from vCenter
   - **Target**: Configure Azure target settings
   - **Replication policy**: Create or select policy
   - Click **Enable replication**

### Network Configuration via Portal

1. **Network Mapping**
   - Go to **Site Recovery Infrastructure** → **Network mapping**
   - Click **Add network mapping**
   - **Source network**: Select source VNet
   - **Target network**: Select target VNet
   - **Mapping type**: `One-to-one mapping`
   - Click **OK**

2. **IP Address Configuration**
   - Go to replicated item → **Compute and Network**
   - **Network interfaces**: Configure each NIC
     - **Target subnet**: Select target subnet
     - **IP allocation**: `Static` or `Dynamic`
     - **IP address**: Specify static IP if needed
   - **VM size**: Configure target VM size
   - **Availability set**: Select target availability set
   - Click **Save**

### Failback Operations via Portal

1. **Prepare for Failback**
   - Ensure source environment is ready
   - Configure reverse replication
   - Set up process server in Azure (if needed)

2. **Enable Reverse Replication**
   - Go to failed-over VM in target region
   - Click **Re-protect**
   - **Source**: Current location (target region)
   - **Target**: Original location (source region)
   - **Replication policy**: Select or create policy
   - **Cache storage account**: Select account
   - Click **OK**

3. **Execute Failback**
   - After reverse replication completes
   - Click **Planned failover**
   - **Direction**: Target to source region
   - **Recovery point**: Select appropriate point
   - Click **OK**

4. **Commit Failback**
   - Monitor failback completion
   - Verify VM startup in original location
   - Click **Commit** to finalize failback
   - Re-enable forward replication if needed

### Monitoring and Reporting via Portal

1. **Site Recovery Dashboard**
   - Go to vault **Overview**
   - **Replication health**: Overall health status
   - **Failover readiness**: VMs ready for failover
   - **Test failover success**: Recent test results
   - **Configuration issues**: Items needing attention

2. **Jobs Monitoring**
   - Go to **Site Recovery jobs**
   - **Filter options**:
     - **Time range**: Last 24 hours, 7 days
     - **Status**: All, Failed, In progress
     - **Job type**: Replication, Failover, Test failover
   - **Job details**: Click on jobs for detailed information

3. **Infrastructure Health**
   - Go to **Site Recovery Infrastructure**
   - **Configuration Servers**: Health and connectivity
   - **Process Servers**: Performance and capacity
   - **Replication policies**: Policy compliance
   - **Network mapping**: Mapping status

4. **Capacity Planning**
   - Go to **Site Recovery** → **Capacity planning**
   - **Deployment planner**: Download and run tool
   - **Capacity planning report**: Upload and view results
   - **Bandwidth requirements**: Network planning
   - **Storage requirements**: Target storage planning

### Automation via Portal

1. **Azure Automation Integration**
   - Go to **Automation Accounts**
   - Create automation account for ASR scripts
   - **Runbooks**: Create PowerShell runbooks
   - **Schedules**: Automate DR testing

2. **Recovery Plan Automation**
   - Add automation runbooks to recovery plans
   - **Pre-actions**: Database preparation scripts
   - **Post-actions**: Application startup scripts
   - **Manual actions**: Human intervention points

3. **Monitoring Automation**
   - **Azure Monitor**: Set up ASR monitoring
   - **Log Analytics**: Collect ASR logs
   - **Alerts**: Automated alert notifications
   - **Dashboards**: Custom monitoring dashboards

## Method 2: Using PowerShell and CLI

### Create Recovery Services Vault
```powershell
# Create Recovery Services Vault for ASR
$resourceGroupName = "rg-asr"
$vaultName = "rsv-asr-vault"
$location = "East US"
$targetLocation = "West US"

# Create resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Recovery Services Vault
$vault = New-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName -Location $location

# Set vault context
Set-AzRecoveryServicesVaultContext -Vault $vault

# Configure vault properties
Set-AzRecoveryServicesVaultProperty -Vault $vault -SoftDeleteFeatureState Disable
```

### Configure Replication Settings
```powershell
# Create replication policy
$replicationPolicy = New-AzRecoveryServicesAsrPolicy -Name "ReplicationPolicy" -ReplicationProvider "A2A" -ReplicationFrequencyInSeconds 300 -RecoveryPointRetentionInHours 24 -ApplicationConsistentSnapshotFrequencyInHours 4

# Get source and target regions
$sourceRegion = Get-AzRecoveryServicesAsrFabric | Where-Object {$_.FriendlyName -eq $location}
$targetRegion = Get-AzRecoveryServicesAsrFabric | Where-Object {$_.FriendlyName -eq $targetLocation}

# Create protection container mapping
$sourceContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $sourceRegion
$targetContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $targetRegion

$containerMapping = New-AzRecoveryServicesAsrProtectionContainerMapping -Name "ContainerMapping" -Policy $replicationPolicy -PrimaryProtectionContainer $sourceContainer -RecoveryProtectionContainer $targetContainer
```

## Azure to Azure Replication

### Enable VM Replication
```powershell
# Variables
$vmResourceGroupName = "rg-vm-source"
$vmName = "myvm"
$targetResourceGroupName = "rg-vm-target"
$targetVNetName = "vnet-target"
$targetSubnetName = "subnet-target"

# Get source VM
$vm = Get-AzVM -ResourceGroupName $vmResourceGroupName -Name $vmName

# Get target network details
$targetVNet = Get-AzVirtualNetwork -ResourceGroupName $targetResourceGroupName -Name $targetVNetName
$targetSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $targetVNet -Name $targetSubnetName

# Create replication protected item
$replicationProtectedItem = New-AzRecoveryServicesAsrReplicationProtectedItem -AzureToAzure -AzureVmId $vm.Id -Name $vmName -ProtectionContainerMapping $containerMapping -RecoveryResourceGroupId "/subscriptions/subscription-id/resourceGroups/$targetResourceGroupName" -RecoveryCloudServiceId $targetSubnet.Id
```

### Configure Replication Settings
```powershell
# Update replication settings
Set-AzRecoveryServicesAsrReplicationProtectedItem -InputObject $replicationProtectedItem -RecoveryResourceGroupId "/subscriptions/subscription-id/resourceGroups/$targetResourceGroupName" -RecoveryCloudServiceId $targetSubnet.Id -RecoveryAvailabilitySetId $null
```

### Monitor Replication Status
```powershell
# Check replication health
Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $sourceContainer | Select-Object FriendlyName, ReplicationHealth, ProtectionState

# Get replication details
$replicationItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -Name $vmName -ProtectionContainer $sourceContainer
$replicationItem.ReplicationHealth
$replicationItem.ProtectionState
```

## VMware to Azure Replication

### Configuration Server Setup
1. **Download Configuration Server OVA**
   - Navigate to Recovery Services vault
   - Go to **Site Recovery** > **Prepare Infrastructure**
   - Download Configuration Server OVA template

2. **Deploy Configuration Server**
   ```bash
   # Deploy OVA in VMware environment
   # Configure network settings
   # Register with Recovery Services vault
   ```

3. **Install Mobility Service**
   ```powershell
   # Push installation via Configuration Server
   $configServer = "config-server.domain.com"
   $passphrase = "ConfigServerPassphrase"
   
   # Install on Windows VM
   MobSvcInstaller.exe /Role "MS" /InstallLocation "C:\Program Files (x86)\Microsoft Azure Site Recovery" /Platform "VmWare" /Silent /PassphraseFilePath "C:\passphrase.txt"
   ```

### Enable VMware VM Replication
```powershell
# Create protection container for VMware
$vmwareContainer = Get-AzRecoveryServicesAsrProtectionContainer -FriendlyName "VMware"

# Create replication policy for VMware
$vmwarePolicy = New-AzRecoveryServicesAsrPolicy -VMwareToAzure -Name "VMwareReplicationPolicy" -RecoveryPointRetentionInHours 24 -ApplicationConsistentSnapshotFrequencyInHours 4 -RPOWarningThresholdInMinutes 15

# Enable replication for VMware VM
$vmwareVM = Get-AzRecoveryServicesAsrProtectableItem -ProtectionContainer $vmwareContainer -FriendlyName "vmware-vm-01"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $targetResourceGroupName -Name "asrcachestorage"

New-AzRecoveryServicesAsrReplicationProtectedItem -VMwareToAzure -ProtectableItem $vmwareVM -Name "vmware-vm-01" -Policy $vmwarePolicy -RecoveryResourceGroupId "/subscriptions/subscription-id/resourceGroups/$targetResourceGroupName" -LogStorageAccountId $storageAccount.Id -ProcessServerId $processServer.Id
```

## Failover Operations

### Test Failover
```powershell
# Create test failover
$testNetwork = Get-AzVirtualNetwork -ResourceGroupName $targetResourceGroupName -Name "vnet-test"
$testFailoverJob = Start-AzRecoveryServicesAsrTestFailoverJob -ReplicationProtectedItem $replicationProtectedItem -Direction PrimaryToRecovery -AzureVMNetworkId $testNetwork.Id

# Monitor test failover
do {
    $job = Get-AzRecoveryServicesAsrJob -Job $testFailoverJob
    Start-Sleep 30
} while ($job.State -eq "InProgress")

# Cleanup test failover
$cleanupJob = Start-AzRecoveryServicesAsrTestFailoverCleanupJob -ReplicationProtectedItem $replicationProtectedItem
```

### Planned Failover
```powershell
# Start planned failover
$plannedFailoverJob = Start-AzRecoveryServicesAsrPlannedFailoverJob -ReplicationProtectedItem $replicationProtectedItem -Direction PrimaryToRecovery

# Monitor failover progress
Get-AzRecoveryServicesAsrJob -Job $plannedFailoverJob

# Commit failover
$commitJob = Start-AzRecoveryServicesAsrCommitFailoverJob -ReplicationProtectedItem $replicationProtectedItem
```

### Unplanned Failover
```powershell
# Get available recovery points
$recoveryPoints = Get-AzRecoveryServicesAsrRecoveryPoint -ReplicationProtectedItem $replicationProtectedItem

# Start unplanned failover
$unplannedFailoverJob = Start-AzRecoveryServicesAsrUnplannedFailoverJob -ReplicationProtectedItem $replicationProtectedItem -Direction PrimaryToRecovery -RecoveryPoint $recoveryPoints[0]

# Monitor and commit
Get-AzRecoveryServicesAsrJob -Job $unplannedFailoverJob
Start-AzRecoveryServicesAsrCommitFailoverJob -ReplicationProtectedItem $replicationProtectedItem
```

## Recovery Plans

### Create Recovery Plan
```powershell
# Create recovery plan
$recoveryPlan = New-AzRecoveryServicesAsrRecoveryPlan -Name "WebAppRecoveryPlan" -PrimaryFabric $sourceRegion -RecoveryFabric $targetRegion -ReplicationProtectedItem $replicationProtectedItem

# Add multiple VMs to recovery plan
$webServerVM = Get-AzRecoveryServicesAsrReplicationProtectedItem -Name "web-server" -ProtectionContainer $sourceContainer
$dbServerVM = Get-AzRecoveryServicesAsrReplicationProtectedItem -Name "db-server" -ProtectionContainer $sourceContainer

$recoveryPlan = New-AzRecoveryServicesAsrRecoveryPlan -Name "MultiTierApp" -PrimaryFabric $sourceRegion -RecoveryFabric $targetRegion -ReplicationProtectedItem @($webServerVM, $dbServerVM)
```

### Customize Recovery Plan
```powershell
# Add pre-action script
$preActionScript = New-AzRecoveryServicesAsrRecoveryPlanAction -Name "PreFailoverScript" -FailoverDirection PrimaryToRecovery -FailoverType PlannedFailover -ScriptPath "https://storageaccount.blob.core.windows.net/scripts/pre-failover.ps1"

# Add post-action script
$postActionScript = New-AzRecoveryServicesAsrRecoveryPlanAction -Name "PostFailoverScript" -FailoverDirection PrimaryToRecovery -FailoverType PlannedFailover -ScriptPath "https://storageaccount.blob.core.windows.net/scripts/post-failover.ps1"

# Update recovery plan with actions
Set-AzRecoveryServicesAsrRecoveryPlan -RecoveryPlan $recoveryPlan -Action $preActionScript, $postActionScript
```

### Execute Recovery Plan
```powershell
# Test recovery plan
$testRecoveryPlanJob = Start-AzRecoveryServicesAsrTestFailoverJob -RecoveryPlan $recoveryPlan -Direction PrimaryToRecovery

# Planned failover with recovery plan
$plannedRecoveryPlanJob = Start-AzRecoveryServicesAsrPlannedFailoverJob -RecoveryPlan $recoveryPlan -Direction PrimaryToRecovery

# Unplanned failover with recovery plan
$unplannedRecoveryPlanJob = Start-AzRecoveryServicesAsrUnplannedFailoverJob -RecoveryPlan $recoveryPlan -Direction PrimaryToRecovery
```

## Failback Operations

### Prepare for Failback
```powershell
# Create reverse replication policy
$failbackPolicy = New-AzRecoveryServicesAsrPolicy -Name "FailbackPolicy" -ReplicationProvider "A2A" -ReplicationFrequencyInSeconds 300 -RecoveryPointRetentionInHours 24 -ApplicationConsistentSnapshotFrequencyInHours 4

# Enable reverse replication
$reverseReplicationJob = Start-AzRecoveryServicesAsrReverseReplicationJob -ReplicationProtectedItem $replicationProtectedItem -Policy $failbackPolicy
```

### Execute Failback
```powershell
# Planned failback
$failbackJob = Start-AzRecoveryServicesAsrPlannedFailoverJob -ReplicationProtectedItem $replicationProtectedItem -Direction RecoveryToPrimary

# Monitor failback
Get-AzRecoveryServicesAsrJob -Job $failbackJob

# Commit failback
Start-AzRecoveryServicesAsrCommitFailoverJob -ReplicationProtectedItem $replicationProtectedItem
```

## Network Configuration

### Network Mapping
```powershell
# Create network mapping
$sourceNetwork = Get-AzVirtualNetwork -ResourceGroupName $vmResourceGroupName -Name "vnet-source"
$targetNetwork = Get-AzVirtualNetwork -ResourceGroupName $targetResourceGroupName -Name "vnet-target"

$networkMapping = New-AzRecoveryServicesAsrNetworkMapping -Name "NetworkMapping" -PrimaryNetwork $sourceNetwork.Id -RecoveryNetwork $targetNetwork.Id -RecoveryFabric $targetRegion -PrimaryFabric $sourceRegion
```

### IP Configuration
```powershell
# Configure static IP for failover
$nicConfig = New-AzRecoveryServicesAsrVMNicConfig -NicId $vm.NetworkProfile.NetworkInterfaces[0].Id -RecoveryVMNetworkId $targetNetwork.Id -RecoveryVMSubnetName $targetSubnetName -RecoveryNicStaticIPAddress "10.0.1.100"

Set-AzRecoveryServicesAsrReplicationProtectedItem -InputObject $replicationProtectedItem -ASRVMNicConfiguration $nicConfig
```

## Monitoring and Reporting

### Replication Health Monitoring
```powershell
# Get replication health summary
$replicationItems = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $sourceContainer
$healthSummary = $replicationItems | Group-Object ReplicationHealth | Select-Object Name, Count

# Check RPO status
$replicationItems | Select-Object FriendlyName, LastRpoCalculatedTime, RpoInSeconds | Format-Table
```

### Job Monitoring
```powershell
# Get recent ASR jobs
$jobs = Get-AzRecoveryServicesAsrJob -StartTime (Get-Date).AddDays(-7)
$jobs | Select-Object Name, State, StartTime, EndTime, TargetObjectName | Format-Table

# Get failed jobs
$failedJobs = Get-AzRecoveryServicesAsrJob | Where-Object {$_.State -eq "Failed"}
$failedJobs | Select-Object Name, StateDescription, Errors
```

### Capacity Planning
```powershell
# Get capacity planning data
$capacityPlan = Get-AzRecoveryServicesAsrVaultUsage
$capacityPlan | Select-Object UsageType, CurrentValue, Limit

# Storage usage
$storageUsage = Get-AzRecoveryServicesAsrStorageClassification
$storageUsage | Select-Object FriendlyName, TotalSizeInBytes, UsedSizeInBytes
```

## Automation and Scripting

### PowerShell Automation
```powershell
# Automated DR drill script
function Start-DRDrill {
    param(
        [string]$RecoveryPlanName,
        [string]$TestNetworkId
    )
    
    $recoveryPlan = Get-AzRecoveryServicesAsrRecoveryPlan -Name $RecoveryPlanName
    $testJob = Start-AzRecoveryServicesAsrTestFailoverJob -RecoveryPlan $recoveryPlan -Direction PrimaryToRecovery -AzureVMNetworkId $TestNetworkId
    
    # Wait for completion
    do {
        Start-Sleep 60
        $job = Get-AzRecoveryServicesAsrJob -Job $testJob
        Write-Host "Test failover status: $($job.State)"
    } while ($job.State -eq "InProgress")
    
    if ($job.State -eq "Succeeded") {
        Write-Host "DR drill completed successfully"
        # Cleanup after testing
        Start-AzRecoveryServicesAsrTestFailoverCleanupJob -RecoveryPlan $recoveryPlan
    }
}
```

### ARM Template for ASR
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vaultName": {
      "type": "string"
    },
    "sourceRegion": {
      "type": "string"
    },
    "targetRegion": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.RecoveryServices/vaults",
      "apiVersion": "2021-01-01",
      "name": "[parameters('vaultName')]",
      "location": "[parameters('sourceRegion')]",
      "sku": {
        "name": "RS0",
        "tier": "Standard"
      },
      "properties": {}
    },
    {
      "type": "Microsoft.RecoveryServices/vaults/replicationPolicies",
      "apiVersion": "2021-01-01",
      "name": "[concat(parameters('vaultName'), '/A2APolicy')]",
      "dependsOn": [
        "[resourceId('Microsoft.RecoveryServices/vaults', parameters('vaultName'))]"
      ],
      "properties": {
        "providerSpecificInput": {
          "instanceType": "A2A",
          "recoveryPointRetentionInMinutes": 1440,
          "applicationConsistentSnapshotFrequencyInMinutes": 240
        }
      }
    }
  ]
}
```

## Best Practices

### Security
- Use managed identities for authentication
- Implement RBAC for ASR operations
- Enable soft delete for vault protection
- Regular security assessments

### Performance
- Monitor RPO and RTO metrics
- Optimize replication frequency
- Use premium storage for critical workloads
- Regular capacity planning

### Cost Optimization
- Right-size target resources
- Use appropriate storage tiers
- Monitor replication costs
- Implement automated shutdown for test environments

### Compliance
- Document DR procedures
- Regular DR testing schedule
- Maintain compliance reports
- Audit trail for all operations

## Troubleshooting

### Common Issues
```powershell
# Check replication errors
$replicationItem = Get-AzRecoveryServicesAsrReplicationProtectedItem -Name $vmName -ProtectionContainer $sourceContainer
$replicationItem.ReplicationHealthErrors

# Resolve connectivity issues
Test-AzRecoveryServicesAsrConnectivity -SourceFabric $sourceRegion -TargetFabric $targetRegion

# Check agent status
Get-AzRecoveryServicesAsrServicesProvider | Select-Object FriendlyName, LastHeartBeat, ConnectionStatus
```

### Performance Optimization
```powershell
# Monitor replication performance
$perfCounters = Get-AzRecoveryServicesAsrReplicationProtectedItem | Select-Object FriendlyName, RpoInSeconds, LastRpoCalculatedTime
$perfCounters | Where-Object {$_.RpoInSeconds -gt 900} # RPO > 15 minutes
```

### Disaster Recovery Testing
```powershell
# Automated DR test schedule
$testSchedule = @{
    RecoveryPlanName = "ProductionApp"
    TestFrequency = "Monthly"
    TestNetwork = "vnet-dr-test"
    NotificationEmail = "admin@company.com"
}

# Schedule recurring DR tests
Register-ScheduledJob -Name "MonthlyDRTest" -ScriptBlock {
    Start-DRDrill -RecoveryPlanName $using:testSchedule.RecoveryPlanName -TestNetworkId $using:testSchedule.TestNetwork
} -Trigger (New-JobTrigger -Weekly -DaysOfWeek Sunday -At "02:00")
```

## Portal Best Practices

### Security Best Practices
1. **Access Control**
   - Implement Azure RBAC for Site Recovery operations
   - Use managed identities for automation
   - Regular access reviews and audits
   - Enable MFA for critical DR operations

2. **Data Protection**
   - Enable soft delete for vault protection
   - Use customer-managed keys for encryption
   - Implement network security groups
   - Regular security assessments

### Operational Excellence
1. **DR Strategy**
   - Define clear RTO and RPO requirements
   - Regular DR testing and validation
   - Document recovery procedures
   - Implement automated monitoring

2. **Performance Optimization**
   - Monitor replication performance and RPO
   - Optimize network bandwidth usage
   - Use premium storage for critical workloads
   - Regular capacity planning

### Cost Management
1. **Resource Optimization**
   - Right-size target VM configurations
   - Use appropriate storage tiers
   - Monitor replication costs
   - Implement automated shutdown for test environments

2. **Efficiency Measures**
   - Optimize replication frequency
   - Use incremental replication
   - Regular policy reviews
   - Implement lifecycle management

### Monitoring and Alerting
1. **Proactive Monitoring**
   - Configure comprehensive ASR alerts
   - Monitor replication health and RPO
   - Set up automated reporting
   - Regular infrastructure health checks

2. **Incident Response**
   - Maintain DR runbooks and procedures
   - Quick issue identification and resolution
   - Regular communication plan testing
   - Post-incident reviews and improvements
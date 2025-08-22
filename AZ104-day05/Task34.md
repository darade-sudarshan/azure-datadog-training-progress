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

## Azure Site Recovery Setup

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
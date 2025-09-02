# Task-SQL-05: SQL Database Migration from On-Premises to Azure Cloud

## Overview
This task covers comprehensive database migration strategies and methods to move SQL Server databases from on-premises infrastructure to Azure cloud services including Azure SQL Database, Azure SQL Managed Instance, and SQL Server on Azure VMs.

## Migration Options Overview

### 1. Azure SQL Database (PaaS)
- **Best For**: Modern applications, SaaS solutions
- **Features**: Fully managed, auto-scaling, built-in intelligence
- **Limitations**: Some SQL Server features not supported
- **Migration Tools**: DMA, Azure Database Migration Service, BACPAC

### 2. Azure SQL Managed Instance (PaaS)
- **Best For**: Lift-and-shift scenarios, legacy applications
- **Features**: Near 100% SQL Server compatibility, VNet integration
- **Limitations**: Higher cost than SQL Database
- **Migration Tools**: DMS, native backup/restore, Log Replay Service

### 3. SQL Server on Azure VMs (IaaS)
- **Best For**: Full control requirements, custom configurations
- **Features**: Complete SQL Server compatibility, full administrative access
- **Limitations**: Customer manages OS and SQL Server
- **Migration Tools**: Backup/restore, Always On, Azure Site Recovery

## Task 1: Pre-Migration Assessment

### Install Data Migration Assistant (DMA)
1. Download DMA from Microsoft Download Center
2. Install on source SQL Server or management machine
3. Launch Data Migration Assistant

### Assess Source Database
```sql
-- Check database compatibility level
SELECT name, compatibility_level 
FROM sys.databases 
WHERE name = 'AdventureWorks2019';

-- Check database size and growth
SELECT 
    name,
    size * 8.0 / 1024 AS size_mb,
    max_size * 8.0 / 1024 AS max_size_mb,
    growth,
    is_percent_growth
FROM sys.database_files;

-- Identify deprecated features
SELECT 
    feature_name,
    feature_id,
    instance_name
FROM sys.dm_db_persisted_sku_features;
```

### DMA Assessment Steps
1. Create new assessment project
2. Select assessment type: "Azure SQL Database" or "Azure SQL Managed Instance"
3. Specify source server and database
4. Run compatibility assessment
5. Review feature parity report
6. Export assessment results

### Azure Migrate Assessment
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Create Azure Migrate project
az migrate project create \
  --name "SQLMigrationProject" \
  --resource-group "sa1_test_eic_SudarshanDarade" \
  --location "SouthEast Asia"
```

## Task 2: Prepare Azure Target Environment

### Create Resource Group and Networking
```bash
# Create resource group
az group create \
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia

# Create virtual network for Managed Instance
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-migration-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name ManagedInstance \
  --subnet-prefix 10.0.1.0/24

# Create route table for Managed Instance
az network route-table create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-mi-route-table

# Associate route table with subnet
az network vnet subnet update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name sql-migration-vnet \
  --name ManagedInstance \
  --route-table sql-mi-route-table
```

### Create Azure SQL Database
```bash
# Create logical SQL server
az sql server create \
  --name sql-migration-server \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --admin-user sqladmin \
  --admin-password P@ssw0rd123!

# Create Azure SQL Database
az sql db create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksAzure \
  --service-objective S2 \
  --backup-storage-redundancy Local

# Configure firewall
az sql server firewall-rule create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AllowOnPremises \
  --start-ip-address YOUR-PUBLIC-IP \
  --end-ip-address YOUR-PUBLIC-IP
```

### Create Azure SQL Managed Instance
```bash
# Create network security group
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-mi-nsg

# Create Managed Instance (takes 4-6 hours)
az sql mi create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-managed-instance-001 \
  --location southeastasia \
  --subnet /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/virtualNetworks/sql-migration-vnet/subnets/ManagedInstance \
  --admin-user sqladmin \
  --admin-password P@ssw0rd123! \
  --storage-size-in-gb 256 \
  --vcore 4 \
  --edition GeneralPurpose \
  --compute-generation Gen5 \
  --license-type BasePrice
```

## Task 3: Migration Method 1 - BACPAC Export/Import

### Export Database to BACPAC
```bash
# Create storage account
az storage account create \
  --name sqlmigrationstg001 \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --sku Standard_LRS

# Get storage key
STORAGE_KEY=$(az storage account keys list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --account-name sqlmigrationstg001 \
  --query '[0].value' -o tsv)

# Create container
az storage container create \
  --name backups \
  --account-name sqlmigrationstg001 \
  --account-key $STORAGE_KEY
```

### Export via SqlPackage
```bash
# Export database to BACPAC
SqlPackage.exe /Action:Export \
  /SourceServerName:"OnPremServer" \
  /SourceDatabaseName:"AdventureWorks2019" \
  /SourceUser:"sa" \
  /SourcePassword:"P@ssw0rd123!" \
  /TargetFile:"C:\Backup\AdventureWorks2019.bacpac"

# Upload to Azure Storage
az storage blob upload \
  --account-name sqlmigrationstg001 \
  --account-key $STORAGE_KEY \
  --container-name backups \
  --name AdventureWorks2019.bacpac \
  --file "C:\Backup\AdventureWorks2019.bacpac"
```

### Import to Azure SQL Database
```bash
# Import BACPAC to Azure SQL Database
az sql db import \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksImported \
  --storage-key-type StorageAccessKey \
  --storage-key $STORAGE_KEY \
  --storage-uri "https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019.bacpac" \
  --admin-user sqladmin \
  --admin-password P@ssw0rd123!
```

## Task 4: Migration Method 2 - Azure Database Migration Service

### Create Database Migration Service
```bash
# Create DMS instance
az dms create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-dms-service \
  --location southeastasia \
  --sku-name Premium_4vCores \
  --subnet /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/virtualNetworks/sql-migration-vnet/subnets/ManagedInstance
```

### Create Migration Project
```bash
# Create migration project
az dms project create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --service-name sql-dms-service \
  --name SQLMigrationProject \
  --location southeastasia \
  --source-platform SQL \
  --target-platform SQLMI
```

### Configure Source and Target
```json
{
  "sourceConnectionInfo": {
    "serverName": "OnPremSQLServer",
    "authentication": "SqlAuthentication",
    "userName": "sa",
    "password": "P@ssw0rd123!",
    "encryptConnection": true,
    "trustServerCertificate": true
  },
  "targetConnectionInfo": {
    "serverName": "sql-managed-instance-001.database.windows.net",
    "authentication": "SqlAuthentication",
    "userName": "sqladmin",
    "password": "P@ssw0rd123!",
    "encryptConnection": true,
    "trustServerCertificate": false
  }
}
```

### Start Migration Task
```bash
# Create and start migration task
az dms project task create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --service-name sql-dms-service \
  --project-name SQLMigrationProject \
  --name MigrateAdventureWorks \
  --task-type MigrateSqlServerSqlMI \
  --source-connection-json source-connection.json \
  --target-connection-json target-connection.json \
  --database-options-json database-options.json
```

## Task 5: Migration Method 3 - Native Backup/Restore

### Create Full Backup
```sql
-- Create full backup on source server
BACKUP DATABASE AdventureWorks2019
TO URL = 'https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019_Full.bak'
WITH CREDENTIAL = 'AzureStorageCredential',
COMPRESSION, CHECKSUM, INIT;

-- Create differential backup
BACKUP DATABASE AdventureWorks2019
TO URL = 'https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019_Diff.bak'
WITH CREDENTIAL = 'AzureStorageCredential',
DIFFERENTIAL, COMPRESSION, CHECKSUM;

-- Create log backup
BACKUP LOG AdventureWorks2019
TO URL = 'https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019_Log.trn'
WITH CREDENTIAL = 'AzureStorageCredential',
COMPRESSION, CHECKSUM;
```

### Create Storage Credential
```sql
-- Create credential for Azure Storage
CREATE CREDENTIAL [AzureStorageCredential]
WITH IDENTITY = 'sqlmigrationstg001',
SECRET = 'STORAGE-ACCESS-KEY';
```

### Restore to Managed Instance
```sql
-- Restore database to Managed Instance
RESTORE DATABASE AdventureWorks2019
FROM URL = 'https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019_Full.bak',
URL = 'https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019_Diff.bak',
URL = 'https://sqlmigrationstg001.blob.core.windows.net/backups/AdventureWorks2019_Log.trn'
WITH REPLACE, NORECOVERY;

-- Bring database online
RESTORE DATABASE AdventureWorks2019 WITH RECOVERY;
```

## Task 6: Migration Method 4 - Transactional Replication

### Configure Publisher (Source)
```sql
-- Enable replication on source database
USE AdventureWorks2019;
EXEC sp_replicationdboption 
    @dbname = 'AdventureWorks2019',
    @optname = 'publish',
    @value = 'true';

-- Create publication
EXEC sp_addpublication 
    @publication = 'AdventureWorks_Pub',
    @description = 'Publication for Azure migration',
    @sync_method = 'concurrent',
    @retention = 60,
    @allow_push = 'true',
    @allow_pull = 'true',
    @allow_anonymous = 'false',
    @enabled_for_internet = 'false',
    @snapshot_in_defaultfolder = 'true',
    @compress_snapshot = 'false',
    @ftp_port = 21,
    @allow_subscription_copy = 'false',
    @add_to_active_directory = 'false',
    @repl_freq = 'continuous',
    @status = 'active',
    @independent_agent = 'true';
```

### Add Articles to Publication
```sql
-- Add tables to publication
EXEC sp_addarticle 
    @publication = 'AdventureWorks_Pub',
    @article = 'Customer',
    @source_object = 'Customer',
    @type = 'logbased',
    @description = 'Customer table',
    @creation_script = null,
    @pre_creation_cmd = 'drop',
    @schema_option = 0x000000000803509F,
    @identityrangemanagementoption = 'manual',
    @destination_table = 'Customer',
    @destination_owner = 'dbo';
```

### Configure Subscriber (Azure SQL Database)
```sql
-- Create subscription on Azure SQL Database
EXEC sp_addsubscription 
    @publication = 'AdventureWorks_Pub',
    @subscriber = 'sql-migration-server.database.windows.net',
    @destination_db = 'AdventureWorksAzure',
    @subscription_type = 'Push',
    @sync_type = 'automatic',
    @article = 'all',
    @update_mode = 'read only',
    @subscriber_type = 0;
```

## Task 7: Online Migration with Minimal Downtime

### Log Replay Service for Managed Instance
```bash
# Start Log Replay Service
az sql midb log-replay start \
  --resource-group sa1_test_eic_SudarshanDarade \
  --managed-instance sql-managed-instance-001 \
  --name AdventureWorks2019 \
  --storage-uri "https://sqlmigrationstg001.blob.core.windows.net/backups/" \
  --storage-sas "SAS-TOKEN"

# Monitor progress
az sql midb log-replay show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --managed-instance sql-managed-instance-001 \
  --name AdventureWorks2019
```

### Complete Migration
```bash
# Complete the migration
az sql midb log-replay complete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --managed-instance sql-managed-instance-001 \
  --name AdventureWorks2019 \
  --last-backup-name "AdventureWorks2019_Log_Final.trn"
```

## Task 8: Post-Migration Tasks

### Update Connection Strings
```csharp
// Old connection string
string oldConnectionString = "Server=OnPremServer;Database=AdventureWorks2019;Integrated Security=true;";

// New Azure SQL Database connection string
string newConnectionString = "Server=sql-migration-server.database.windows.net;Database=AdventureWorksAzure;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;";

// New Managed Instance connection string
string miConnectionString = "Server=sql-managed-instance-001.database.windows.net;Database=AdventureWorks2019;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;";
```

### Update Statistics and Rebuild Indexes
```sql
-- Update statistics
EXEC sp_updatestats;

-- Rebuild indexes
ALTER INDEX ALL ON [dbo].[Customer] REBUILD;

-- Update compatibility level
ALTER DATABASE AdventureWorksAzure SET COMPATIBILITY_LEVEL = 150;

-- Enable Query Store
ALTER DATABASE AdventureWorksAzure SET QUERY_STORE = ON;
```

### Configure Security
```sql
-- Create database users
CREATE USER [app_user] WITH PASSWORD = 'AppP@ssw0rd123!';
ALTER ROLE db_datareader ADD MEMBER [app_user];
ALTER ROLE db_datawriter ADD MEMBER [app_user];

-- Enable Transparent Data Encryption
ALTER DATABASE AdventureWorksAzure SET ENCRYPTION ON;

-- Configure Dynamic Data Masking
ALTER TABLE [dbo].[Customer] 
ALTER COLUMN [EmailAddress] ADD MASKED WITH (FUNCTION = 'email()');
```

## Task 9: Performance Optimization

### Configure Service Tier
```bash
# Scale up Azure SQL Database
az sql db update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksAzure \
  --service-objective S3

# Configure auto-scaling
az sql db update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksAzure \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 2 \
  --compute-model Serverless \
  --auto-pause-delay 60
```

### Enable Automatic Tuning
```sql
-- Enable automatic tuning
ALTER DATABASE AdventureWorksAzure 
SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);

ALTER DATABASE AdventureWorksAzure 
SET AUTOMATIC_TUNING (CREATE_INDEX = ON);

ALTER DATABASE AdventureWorksAzure 
SET AUTOMATIC_TUNING (DROP_INDEX = ON);
```

### Monitor Performance
```sql
-- Check Query Store data
SELECT 
    q.query_id,
    qt.query_sql_text,
    rs.avg_duration,
    rs.avg_cpu_time,
    rs.avg_logical_io_reads
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_runtime_stats rs ON q.query_id = rs.query_id
ORDER BY rs.avg_duration DESC;
```

## Task 10: Validation and Testing

### Data Validation
```sql
-- Compare row counts
SELECT 'Source' as Location, COUNT(*) as RowCount FROM [OnPremServer].[AdventureWorks2019].[dbo].[Customer]
UNION ALL
SELECT 'Target' as Location, COUNT(*) as RowCount FROM [dbo].[Customer];

-- Compare checksums
SELECT CHECKSUM_AGG(CHECKSUM(*)) as TableChecksum 
FROM [dbo].[Customer];

-- Validate data integrity
DBCC CHECKDB('AdventureWorksAzure');
```

### Application Testing
```sql
-- Test application queries
SELECT TOP 10 * FROM [dbo].[Customer] 
WHERE [City] = 'Seattle';

-- Test stored procedures
EXEC [dbo].[GetCustomerOrders] @CustomerID = 123;

-- Test performance
SET STATISTICS IO ON;
SELECT COUNT(*) FROM [dbo].[SalesOrderDetail];
SET STATISTICS IO OFF;
```

### Load Testing
```powershell
# PowerShell script for load testing
$connectionString = "Server=sql-migration-server.database.windows.net;Database=AdventureWorksAzure;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=true;"

1..100 | ForEach-Object -Parallel {
    $connection = New-Object System.Data.SqlClient.SqlConnection($using:connectionString)
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT COUNT(*) FROM [dbo].[Customer]"
    $result = $command.ExecuteScalar()
    
    Write-Host "Thread $($_): $result rows"
    $connection.Close()
} -ThrottleLimit 10
```

## Task 11: Monitoring and Alerting

### Configure Azure Monitor
```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name sql-migration-logs

# Configure diagnostic settings
az monitor diagnostic-settings create \
  --resource "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/sql-migration-server/databases/AdventureWorksAzure" \
  --name "SQLDiagnostics" \
  --workspace "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/sql-migration-logs" \
  --logs '[{"category":"QueryStoreRuntimeStatistics","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

### Create Alerts
```bash
# Create CPU alert
az monitor metrics alert create \
  --name "High-CPU-Alert" \
  --resource-group sa1_test_eic_SudarshanDarade \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/sql-migration-server/databases/AdventureWorksAzure" \
  --condition "avg cpu_percent > 80" \
  --window-size 5m \
  --evaluation-frequency 1m
```

## Task 12: Disaster Recovery Setup

### Configure Geo-Replication
```bash
# Create secondary database
az sql db replica create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksAzure \
  --partner-resource-group sa1_test_eic_SudarshanDarade-dr \
  --partner-server sql-migration-server-dr \
  --service-objective S2
```

### Configure Backup Policies
```bash
# Configure long-term retention
az sql db ltr-policy set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --database AdventureWorksAzure \
  --weekly-retention P4W \
  --monthly-retention P12M \
  --yearly-retention P5Y \
  --week-of-year 1
```

## Task 13: Cost Optimization

### Monitor Costs
```bash
# Check database usage
az sql db show-usage \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksAzure

# Review pricing tier recommendations
az sql db show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-migration-server \
  --name AdventureWorksAzure \
  --query "recommendedIndex"
```

### Implement Cost Controls
```sql
-- Configure serverless for development databases
ALTER DATABASE AdventureWorksAzure_Dev
MODIFY (EDITION = 'GeneralPurpose', 
        SERVICE_OBJECTIVE = 'GP_S_Gen5_1',
        COMPUTE_MODEL = 'Serverless',
        AUTO_PAUSE_DELAY_IN_MINUTES = 60);
```

## Migration Checklist

### Pre-Migration
- ✅ Source database assessment completed
- ✅ Compatibility issues identified and resolved
- ✅ Target Azure environment prepared
- ✅ Network connectivity established
- ✅ Security requirements defined

### During Migration
- ✅ Migration method selected and executed
- ✅ Data validation performed
- ✅ Performance baseline established
- ✅ Application connectivity tested
- ✅ Rollback plan prepared

### Post-Migration
- ✅ Connection strings updated
- ✅ Security configured
- ✅ Performance optimized
- ✅ Monitoring and alerting set up
- ✅ Disaster recovery configured
- ✅ Documentation updated
- ✅ Team training completed

## Best Practices Summary

### Planning
- Conduct thorough assessment before migration
- Choose appropriate Azure service based on requirements
- Plan for minimal downtime during migration
- Prepare rollback procedures

### Security
- Use encrypted connections during migration
- Implement proper authentication and authorization
- Enable auditing and threat detection
- Configure network security groups appropriately

### Performance
- Right-size target resources
- Enable automatic tuning features
- Monitor performance metrics continuously
- Optimize queries for cloud environment

### Cost Management
- Use serverless for variable workloads
- Implement proper backup retention policies
- Monitor resource utilization regularly
- Consider reserved capacity for predictable workloads

---

**Next Steps**: Proceed to advanced Azure SQL topics including high availability, disaster recovery, and advanced security configurations.
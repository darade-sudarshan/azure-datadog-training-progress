# Task-SQL-06: SQL Database Password Reset and Azure Synapse Link Integration

## Overview
This task covers SQL Server password reset procedures for various scenarios and integrating Azure Synapse Link with SQL databases for real-time analytics and data processing.

## Part 1: SQL Database Password Reset

### Scenario 1: Azure SQL Database Server Admin Password Reset

#### Method 1: Azure Portal
1. Navigate to Azure Portal → SQL servers
2. Select your SQL server
3. Click "Reset password" in the Overview section
4. Enter new password: `NewP@ssw0rd123!`
5. Confirm password and click "Save"

#### Method 2: Azure CLI
```bash
# Reset SQL server admin password
az sql server update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-server-training \
  --admin-password "NewP@ssw0rd123!"

# Verify the change
az sql server show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-server-training \
  --query "administratorLogin"
```

#### Method 3: PowerShell
```powershell
# Reset admin password
Set-AzSqlServer -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
  -ServerName "sql-server-training" `
  -SqlAdministratorPassword (ConvertTo-SecureString "NewP@ssw0rd123!" -AsPlainText -Force)

# Verify connection
$connectionString = "Server=sql-server-training.database.windows.net;Database=master;User ID=sqladmin;Password=NewP@ssw0rd123!;Encrypt=true;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()
Write-Host "Connection successful: $($connection.State)"
$connection.Close()
```

### Scenario 2: SQL Database User Password Reset

#### Reset SQL Authentication User
```sql
-- Connect as server admin
USE [YourDatabase];

-- Reset user password
ALTER USER [username] WITH PASSWORD = 'NewUserP@ssw0rd123!';

-- Check user exists
SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE name = 'username';
```

#### Reset Contained Database User
```sql
-- For contained database users
USE [YourDatabase];

-- Reset contained user password
ALTER USER [contained_user] WITH PASSWORD = 'NewContainedP@ssw0rd123!';

-- Verify contained database authentication
SELECT containment_desc FROM sys.databases WHERE name = 'YourDatabase';
```

### Scenario 3: Azure SQL Managed Instance Password Reset

#### Reset via Azure CLI
```bash
# Reset Managed Instance admin password
az sql mi update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-managed-instance-001 \
  --admin-password "NewMIP@ssw0rd123!"

# Check status
az sql mi show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-managed-instance-001 \
  --query "state"
```

#### Reset via PowerShell
```powershell
# Reset MI admin password
Set-AzSqlInstance -ResourceGroupName "sa1_test_eic_SudarshanDarade" `
  -Name "sql-managed-instance-001" `
  -AdministratorPassword (ConvertTo-SecureString "NewMIP@ssw0rd123!" -AsPlainText -Force)
```

### Scenario 4: SQL Server on VM Password Reset

#### Reset SA Password
```sql
-- Method 1: Using ALTER LOGIN (if you have admin access)
ALTER LOGIN sa WITH PASSWORD = 'NewSAP@ssw0rd123!';
ALTER LOGIN sa ENABLE;

-- Method 2: Reset via SQL Server Configuration Manager
-- 1. Stop SQL Server service
-- 2. Start SQL Server in single-user mode: sqlservr.exe -m
-- 3. Connect via sqlcmd and reset password
-- 4. Restart SQL Server normally
```

#### Reset via Single-User Mode
```cmd
REM Stop SQL Server service
net stop MSSQLSERVER

REM Start in single-user mode
sqlservr.exe -m

REM In another command prompt, connect and reset
sqlcmd -S localhost -E
```

```sql
-- Reset SA password in single-user mode
ALTER LOGIN sa WITH PASSWORD = 'NewSAP@ssw0rd123!';
ALTER LOGIN sa ENABLE;
GO
```

#### Reset Windows Authentication User
```sql
-- Add Windows user as sysadmin
CREATE LOGIN [DOMAIN\username] FROM WINDOWS;
ALTER SERVER ROLE sysadmin ADD MEMBER [DOMAIN\username];

-- Remove if needed
ALTER SERVER ROLE sysadmin DROP MEMBER [DOMAIN\username];
DROP LOGIN [DOMAIN\username];
```

### Scenario 5: Emergency Password Reset Procedures

#### Using Azure AD Authentication
```bash
# Set Azure AD admin for SQL server
az sql server ad-admin create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server-name sql-server-training \
  --display-name "SQL Admin" \
  --object-id "user-object-id"

# Connect using Azure AD and reset SQL user
az sql server ad-admin show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server-name sql-server-training
```

#### Connect with Azure AD and Reset SQL Users
```sql
-- Connect using Azure AD authentication
-- Then reset SQL authentication users
USE [master];
ALTER LOGIN [sql_user] WITH PASSWORD = 'EmergencyP@ssw0rd123!';

-- Create new admin user if needed
CREATE LOGIN [emergency_admin] WITH PASSWORD = 'EmergencyAdminP@ssw0rd123!';
ALTER SERVER ROLE sysadmin ADD MEMBER [emergency_admin];
```

## Part 2: Azure Synapse Link Integration

### Overview of Azure Synapse Link
Azure Synapse Link enables near real-time analytics over operational data without impacting the performance of transactional workloads. It creates a seamless integration between operational stores and analytical stores.

### Supported Services
- **Azure Cosmos DB**: NoSQL analytical store
- **Azure SQL Database**: Relational analytical processing
- **Dataverse**: Business application data analytics

## Task 1: Prepare Environment for Synapse Link

### Create Azure Synapse Workspace
```bash
# Create resource group
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia

# Create storage account for Synapse
az storage account create \
  --name synapselinkstg001 \
  --resource-group sa1_test_eic_SudarshanDarade \
  --location southeastasia \
  --sku Standard_LRS \
  --kind StorageV2 \
  --hierarchical-namespace true

# Create file system
az storage fs create \
  --name synapse-workspace \
  --account-name synapselinkstg001

# Create Synapse workspace
az synapse workspace create \
  --name synapse-workspace-001 \
  --resource-group sa1_test_eic_SudarshanDarade \
  --storage-account synapselinkstg001 \
  --file-system synapse-workspace \
  --sql-admin-login-user synapseadmin \
  --sql-admin-login-password "SynapseP@ssw0rd123!" \
  --location southeastasia
```

### Configure Firewall Rules
```bash
# Allow Azure services
az synapse workspace firewall-rule create \
  --name AllowAzureServices \
  --workspace-name synapse-workspace-001 \
  --resource-group sa1_test_eic_SudarshanDarade \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Allow your IP
az synapse workspace firewall-rule create \
  --name AllowMyIP \
  --workspace-name synapse-workspace-001 \
  --resource-group sa1_test_eic_SudarshanDarade \
  --start-ip-address YOUR-IP-ADDRESS \
  --end-ip-address YOUR-IP-ADDRESS
```

## Task 2: Configure SQL Database for Synapse Link

### Enable Change Data Capture (CDC)
```sql
-- Connect to your SQL Database
USE [AdventureWorksLT];

-- Enable CDC on database
EXEC sys.sp_cdc_enable_db;

-- Verify CDC is enabled
SELECT name, is_cdc_enabled 
FROM sys.databases 
WHERE name = 'AdventureWorksLT';

-- Enable CDC on specific tables
EXEC sys.sp_cdc_enable_table
    @source_schema = N'SalesLT',
    @source_name = N'Customer',
    @role_name = NULL,
    @supports_net_changes = 1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'SalesLT',
    @source_name = N'Product',
    @role_name = NULL,
    @supports_net_changes = 1;
```

### Verify CDC Configuration
```sql
-- Check CDC-enabled tables
SELECT 
    s.name AS schema_name,
    t.name AS table_name,
    t.is_tracked_by_cdc
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_tracked_by_cdc = 1;

-- View CDC capture instances
SELECT 
    capture_instance,
    object_name,
    source_schema,
    source_table,
    start_lsn,
    end_lsn
FROM cdc.change_tables;
```

## Task 3: Create Linked Service in Synapse

### Create SQL Database Linked Service
```json
{
    "name": "AzureSqlDatabase_LinkedService",
    "type": "Microsoft.Synapse/workspaces/linkedservices",
    "properties": {
        "type": "AzureSqlDatabase",
        "typeProperties": {
            "connectionString": "Server=tcp:sql-server-training.database.windows.net,1433;Database=AdventureWorksLT;User ID=sqladmin;Password=P@ssw0rd123!;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        }
    }
}
```

### Create via Azure CLI
```bash
# Create linked service
az synapse linked-service create \
  --workspace-name synapse-workspace-001 \
  --name AzureSqlDatabase_LinkedService \
  --file @linked-service.json
```

### Create via Synapse Studio
1. Open Synapse Studio
2. Navigate to Manage → Linked services
3. Click "New"
4. Select "Azure SQL Database"
5. Configure connection:
   ```
   Name: AzureSqlDatabase_LinkedService
   Server name: sql-server-training.database.windows.net
   Database name: AdventureWorksLT
   Authentication type: SQL authentication
   User name: sqladmin
   Password: P@ssw0rd123!
   ```
6. Test connection and create

## Task 4: Create Datasets for Source Tables

### Create Customer Dataset
```json
{
    "name": "Customer_Dataset",
    "properties": {
        "linkedServiceName": {
            "referenceName": "AzureSqlDatabase_LinkedService",
            "type": "LinkedServiceReference"
        },
        "type": "AzureSqlTable",
        "schema": [],
        "typeProperties": {
            "schema": "SalesLT",
            "table": "Customer"
        }
    }
}
```

### Create Product Dataset
```json
{
    "name": "Product_Dataset",
    "properties": {
        "linkedServiceName": {
            "referenceName": "AzureSqlDatabase_LinkedService",
            "type": "LinkedServiceReference"
        },
        "type": "AzureSqlTable",
        "schema": [],
        "typeProperties": {
            "schema": "SalesLT",
            "table": "Product"
        }
    }
}
```

## Task 5: Create Synapse Pipeline for Data Integration

### Create Copy Pipeline
```json
{
    "name": "CopyFromSQLToSynapse",
    "properties": {
        "activities": [
            {
                "name": "CopyCustomerData",
                "type": "Copy",
                "inputs": [
                    {
                        "referenceName": "Customer_Dataset",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "Customer_Synapse_Dataset",
                        "type": "DatasetReference"
                    }
                ],
                "typeProperties": {
                    "source": {
                        "type": "AzureSqlSource",
                        "sqlReaderQuery": "SELECT * FROM SalesLT.Customer WHERE ModifiedDate > '@{pipeline().parameters.LastModifiedDate}'"
                    },
                    "sink": {
                        "type": "SqlDWSink",
                        "allowPolyBase": true,
                        "polyBaseSettings": {
                            "rejectType": "percentage",
                            "rejectValue": 10
                        }
                    }
                }
            }
        ],
        "parameters": {
            "LastModifiedDate": {
                "type": "string",
                "defaultValue": "1900-01-01"
            }
        }
    }
}
```

### Create Incremental Load Pipeline
```json
{
    "name": "IncrementalLoadPipeline",
    "properties": {
        "activities": [
            {
                "name": "LookupLastModifiedDate",
                "type": "Lookup",
                "typeProperties": {
                    "source": {
                        "type": "AzureSqlSource",
                        "sqlReaderQuery": "SELECT MAX(ModifiedDate) as LastModifiedDate FROM SalesLT.Customer"
                    },
                    "dataset": {
                        "referenceName": "Customer_Dataset",
                        "type": "DatasetReference"
                    }
                }
            },
            {
                "name": "CopyIncrementalData",
                "type": "Copy",
                "dependsOn": [
                    {
                        "activity": "LookupLastModifiedDate",
                        "dependencyConditions": ["Succeeded"]
                    }
                ],
                "typeProperties": {
                    "source": {
                        "type": "AzureSqlSource",
                        "sqlReaderQuery": "SELECT * FROM SalesLT.Customer WHERE ModifiedDate > '@{activity('LookupLastModifiedDate').output.firstRow.LastModifiedDate}'"
                    },
                    "sink": {
                        "type": "SqlDWSink"
                    }
                }
            }
        ]
    }
}
```

## Task 6: Configure Real-time Analytics

### Create Dedicated SQL Pool
```bash
# Create dedicated SQL pool
az synapse sql pool create \
  --name DedicatedPool001 \
  --performance-level DW100c \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name synapse-workspace-001
```

### Create External Tables for Analytics
```sql
-- Connect to dedicated SQL pool
-- Create external data source
CREATE EXTERNAL DATA SOURCE SqlDatabaseSource
WITH (
    TYPE = RDBMS,
    LOCATION = 'sql-server-training.database.windows.net',
    DATABASE_NAME = 'AdventureWorksLT',
    CREDENTIAL = SqlDatabaseCredential
);

-- Create external table
CREATE EXTERNAL TABLE ext_Customer (
    CustomerID int,
    NameStyle bit,
    Title nvarchar(8),
    FirstName nvarchar(50),
    MiddleName nvarchar(50),
    LastName nvarchar(50),
    Suffix nvarchar(10),
    CompanyName nvarchar(128),
    SalesPerson nvarchar(256),
    EmailAddress nvarchar(50),
    Phone nvarchar(25),
    PasswordHash varchar(128),
    PasswordSalt varchar(10),
    rowguid uniqueidentifier,
    ModifiedDate datetime
)
WITH (
    DATA_SOURCE = SqlDatabaseSource,
    SCHEMA_NAME = 'SalesLT',
    OBJECT_NAME = 'Customer'
);
```

## Task 7: Set Up Change Data Capture Integration

### Create CDC-based Pipeline
```sql
-- Query CDC changes
DECLARE @from_lsn binary(10), @to_lsn binary(10);
SET @from_lsn = sys.fn_cdc_get_min_lsn('SalesLT_Customer');
SET @to_lsn = sys.fn_cdc_get_max_lsn();

-- Get all changes
SELECT 
    __$operation,
    __$update_mask,
    CustomerID,
    FirstName,
    LastName,
    EmailAddress,
    ModifiedDate
FROM cdc.fn_cdc_get_all_changes_SalesLT_Customer(@from_lsn, @to_lsn, 'all');
```

### Create Synapse Pipeline for CDC
```json
{
    "name": "CDCToSynapsePipeline",
    "properties": {
        "activities": [
            {
                "name": "GetCDCChanges",
                "type": "Copy",
                "typeProperties": {
                    "source": {
                        "type": "AzureSqlSource",
                        "sqlReaderStoredProcedureName": "sp_get_cdc_changes",
                        "storedProcedureParameters": {
                            "from_lsn": {
                                "value": "@pipeline().parameters.from_lsn",
                                "type": "String"
                            },
                            "to_lsn": {
                                "value": "@pipeline().parameters.to_lsn",
                                "type": "String"
                            }
                        }
                    },
                    "sink": {
                        "type": "SqlDWSink",
                        "preCopyScript": "TRUNCATE TABLE staging.Customer_Changes"
                    }
                }
            }
        ]
    }
}
```

## Task 8: Monitor and Optimize Synapse Link

### Monitor Pipeline Runs
```bash
# List pipeline runs
az synapse pipeline-run query-by-workspace \
  --workspace-name synapse-workspace-001 \
  --last-updated-after "2024-01-01" \
  --last-updated-before "2024-12-31"

# Get specific pipeline run details
az synapse pipeline-run show \
  --workspace-name synapse-workspace-001 \
  --run-id "pipeline-run-id"
```

### Monitor SQL Pool Performance
```sql
-- Check active queries
SELECT 
    request_id,
    session_id,
    status,
    command,
    start_time,
    total_elapsed_time,
    resource_class
FROM sys.dm_pdw_exec_requests
WHERE status NOT IN ('Completed', 'Failed', 'Cancelled')
ORDER BY start_time DESC;

-- Monitor resource utilization
SELECT 
    node_id,
    cpu_count,
    physical_memory_kb / 1024 as physical_memory_mb,
    virtual_memory_kb / 1024 as virtual_memory_mb
FROM sys.dm_pdw_nodes_os_sys_info;
```

### Optimize Performance
```sql
-- Create columnstore indexes for better analytics performance
CREATE CLUSTERED COLUMNSTORE INDEX CCI_Customer 
ON dbo.Customer;

-- Create statistics for query optimization
CREATE STATISTICS stat_Customer_EmailAddress 
ON dbo.Customer (EmailAddress);

-- Partition large tables
CREATE TABLE dbo.Customer_Partitioned (
    CustomerID int,
    FirstName nvarchar(50),
    LastName nvarchar(50),
    EmailAddress nvarchar(50),
    ModifiedDate datetime
)
WITH (
    DISTRIBUTION = HASH(CustomerID),
    PARTITION (ModifiedDate RANGE RIGHT FOR VALUES 
        ('2023-01-01', '2023-07-01', '2024-01-01'))
);
```

## Task 9: Create Real-time Dashboard

### Create Synapse Notebook for Analytics
```python
# Synapse Notebook - Python
import pandas as pd
from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder.appName("SynapseAnalytics").getOrCreate()

# Read data from SQL pool
df = spark.read \
    .format("com.databricks.spark.sqldw") \
    .option("url", "jdbc:sqlserver://synapse-workspace-001-sql.sql.azuresynapse.net:1433;database=DedicatedPool001") \
    .option("tempDir", "abfss://synapse-workspace@synapselinkstg001.dfs.core.windows.net/temp") \
    .option("forwardSparkAzureStorageCredentials", "true") \
    .option("dbTable", "dbo.Customer") \
    .load()

# Perform analytics
customer_stats = df.groupBy("CompanyName").count().orderBy("count", ascending=False)
customer_stats.show(20)

# Create visualization data
customer_by_region = df.groupBy("SalesPerson").count().toPandas()
```

### Create Power BI Integration
```sql
-- Create view for Power BI
CREATE VIEW vw_CustomerAnalytics AS
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName as FullName,
    c.CompanyName,
    c.EmailAddress,
    COUNT(soh.SalesOrderID) as OrderCount,
    SUM(soh.TotalDue) as TotalSales,
    MAX(soh.OrderDate) as LastOrderDate
FROM dbo.Customer c
LEFT JOIN dbo.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.CompanyName, c.EmailAddress;
```

## Task 10: Troubleshooting Common Issues

### Password Reset Issues
```sql
-- Check login status
SELECT 
    name,
    is_disabled,
    is_policy_checked,
    is_expiration_checked,
    create_date,
    modify_date
FROM sys.sql_logins
WHERE name = 'username';

-- Check database user mapping
SELECT 
    dp.name AS principal_name,
    dp.type_desc AS principal_type,
    o.name AS object_name,
    p.permission_name,
    p.state_desc AS permission_state
FROM sys.database_permissions p
LEFT JOIN sys.objects o ON p.major_id = o.object_id
LEFT JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name = 'username';
```

### Synapse Link Connection Issues
```bash
# Test connectivity to SQL Database
az sql db show-connection-string \
  --client ado.net \
  --server sql-server-training \
  --name AdventureWorksLT

# Check Synapse workspace status
az synapse workspace show \
  --name synapse-workspace-001 \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "connectivityEndpoints"
```

### Performance Issues
```sql
-- Check CDC overhead
SELECT 
    capture_instance,
    start_lsn,
    end_lsn,
    DATEDIFF(minute, tran_begin_time, tran_end_time) as duration_minutes
FROM cdc.lsn_time_mapping
ORDER BY tran_end_time DESC;

-- Monitor Synapse pool utilization
SELECT 
    pool_name,
    status,
    create_time,
    provisioning_state
FROM sys.dm_pdw_nodes_exec_sql_text;
```

## Best Practices Summary

### Password Management
- Use strong passwords with complexity requirements
- Implement regular password rotation policies
- Use Azure AD authentication when possible
- Enable multi-factor authentication
- Document emergency access procedures

### Synapse Link Integration
- Enable CDC only on necessary tables
- Monitor CDC overhead on source systems
- Use incremental loading for large datasets
- Implement proper error handling and retry logic
- Optimize Synapse pools for analytical workloads

### Security
- Use managed identities for service-to-service authentication
- Implement network security groups and private endpoints
- Enable auditing and monitoring
- Regular security assessments
- Principle of least privilege access

### Performance
- Partition large tables appropriately
- Use columnstore indexes for analytical workloads
- Monitor and optimize query performance
- Implement proper resource management
- Regular maintenance and statistics updates

## Verification Checklist

- ✅ Password reset procedures tested and documented
- ✅ Emergency access procedures established
- ✅ Synapse workspace created and configured
- ✅ SQL Database CDC enabled and tested
- ✅ Linked services created and validated
- ✅ Data pipelines created and running
- ✅ Real-time analytics configured
- ✅ Monitoring and alerting set up
- ✅ Performance optimization implemented
- ✅ Security configurations validated

---

**Next Steps**: Proceed to advanced Azure Synapse Analytics topics including machine learning integration, advanced analytics, and enterprise data governance.
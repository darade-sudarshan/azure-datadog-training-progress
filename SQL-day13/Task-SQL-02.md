# Task-SQL-02: Azure SQL Server Management and Administration

## Overview
This task covers comprehensive Azure SQL Server management including components, dashboard navigation, activity monitoring, access control, settings configuration, data management, security, intelligent performance, monitoring, and troubleshooting.

## Azure SQL Server Components

### 1. Logical Server Components
- **Server**: Logical container for databases
- **Databases**: Individual database instances
- **Elastic Pools**: Shared resource pools for multiple databases
- **Firewall Rules**: Network access control
- **Server-level Logins**: Authentication principals
- **Server Roles**: Permission sets for server-level operations

### 2. Database Components
- **Tables**: Data storage structures
- **Indexes**: Performance optimization structures
- **Views**: Virtual tables based on queries
- **Stored Procedures**: Precompiled SQL code
- **Functions**: Reusable code blocks
- **Triggers**: Event-driven code execution

### 3. Security Components
- **Azure AD Integration**: Identity management
- **SQL Authentication**: Username/password authentication
- **Transparent Data Encryption (TDE)**: Data-at-rest encryption
- **Always Encrypted**: Column-level encryption
- **Row-Level Security**: Row-based access control
- **Dynamic Data Masking**: Sensitive data obfuscation

## Azure SQL Server Dashboard

### 1. Overview Dashboard
Navigate to SQL Server in Azure Portal to access:

#### Server Overview
- **Resource Information**: Name, subscription, resource group, location
- **Status**: Server state and availability
- **Connection Strings**: Various connection string formats
- **Server Admin**: Current administrator account
- **Version**: SQL Server version information

#### Quick Actions
- Create database
- Configure firewall
- Set up geo-replication
- Export/Import database
- Configure backup policies

### 2. Database Dashboard
For each database, the dashboard shows:

#### Essential Information
- **Database Status**: Online, paused, or offline
- **Service Tier**: Current pricing tier and performance level
- **Storage Used**: Current storage consumption
- **DTU/vCore Usage**: Resource utilization metrics
- **Connection Count**: Active connections

#### Performance Metrics
- CPU percentage
- Data IO percentage
- Log IO percentage
- Memory usage
- Deadlock count
- Blocked processes

## Activity Logs and Monitoring

### 1. Activity Log Configuration
```bash
# Enable activity logging
az monitor activity-log alert create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name "SQL-Server-Activity" \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade" \
  --condition category=Administrative \
  --action-groups myActionGroup
```

### 2. Diagnostic Settings
```bash
# Configure diagnostic settings
az monitor diagnostic-settings create \
  --resource "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/sql-server-training" \
  --name "SQLDiagnostics" \
  --logs '[{"category":"SQLSecurityAuditEvents","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --storage-account mystorageaccount
```

### 3. Query Store Configuration
```sql
-- Enable Query Store
ALTER DATABASE TrainingDB SET QUERY_STORE = ON;

-- Configure Query Store settings
ALTER DATABASE TrainingDB SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    MAX_STORAGE_SIZE_MB = 1000,
    INTERVAL_LENGTH_MINUTES = 60
);
```

### 4. Viewing Activity Logs
Access activity logs through:
- Azure Portal → SQL Server → Activity log
- Azure Monitor → Activity log
- PowerShell/CLI commands
- REST API calls

## Access Control and Security

### 1. Azure AD Authentication Setup
```bash
# Set Azure AD admin
az sql server ad-admin create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server-name sql-server-training \
  --display-name "SQL Admin" \
  --object-id "user-object-id"
```

### 2. Database-Level Security
```sql
-- Create database user from Azure AD
CREATE USER [user@domain.com] FROM EXTERNAL PROVIDER;

-- Grant permissions
ALTER ROLE db_datareader ADD MEMBER [user@domain.com];
ALTER ROLE db_datawriter ADD MEMBER [user@domain.com];

-- Create custom role
CREATE ROLE [CustomRole];
GRANT SELECT, INSERT, UPDATE ON SCHEMA::dbo TO [CustomRole];
ALTER ROLE [CustomRole] ADD MEMBER [user@domain.com];
```

### 3. Row-Level Security Implementation
```sql
-- Create security policy
CREATE SCHEMA Security;

CREATE FUNCTION Security.fn_securitypredicate(@Department AS nvarchar(50))
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS fn_securitypredicate_result
    WHERE @Department = USER_NAME() OR USER_NAME() = 'Manager';

CREATE SECURITY POLICY DepartmentFilter
ADD FILTER PREDICATE Security.fn_securitypredicate(Department)
ON dbo.Employees
WITH (STATE = ON);
```

### 4. Dynamic Data Masking
```sql
-- Apply data masking
ALTER TABLE Employees
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE Employees
ALTER COLUMN FirstName ADD MASKED WITH (FUNCTION = 'partial(1,"XXX",1)');
```

## SQL Server Settings Configuration

### 1. Server-Level Settings
```bash
# Configure server settings
az sql server update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name sql-server-training \
  --admin-password "NewP@ssw0rd123!" \
  --minimal-tls-version "1.2"
```

### 2. Database Configuration
```sql
-- Database-level settings
ALTER DATABASE TrainingDB SET AUTO_CLOSE OFF;
ALTER DATABASE TrainingDB SET AUTO_SHRINK OFF;
ALTER DATABASE TrainingDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE TrainingDB SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE TrainingDB SET COMPATIBILITY_LEVEL = 150;
```

### 3. Connection Policy
```bash
# Set connection policy
az sql server conn-policy update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --connection-type Default
```

### 4. Backup Configuration
```bash
# Configure backup retention
az sql db ltr-policy set \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --database TrainingDB \
  --weekly-retention P4W \
  --monthly-retention P12M \
  --yearly-retention P5Y \
  --week-of-year 1
```

## Data Management

### 1. Data Import/Export
```bash
# Import BACPAC file
az sql db import \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --name ImportedDB \
  --storage-key-type StorageAccessKey \
  --storage-key "storage-key" \
  --storage-uri "https://storage.blob.core.windows.net/backups/database.bacpac" \
  --admin-user sqladmin \
  --admin-password "P@ssw0rd123!"

# Export to BACPAC
az sql db export \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --name TrainingDB \
  --storage-key-type StorageAccessKey \
  --storage-key "storage-key" \
  --storage-uri "https://storage.blob.core.windows.net/backups/export.bacpac" \
  --admin-user sqladmin \
  --admin-password "P@ssw0rd123!"
```

### 2. Data Sync Configuration
```bash
# Create sync group
az sql db sync-group create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --database TrainingDB \
  --name "SyncGroup1" \
  --interval -1 \
  --conflict-resolution "HubWin" \
  --sync-database-id "/subscriptions/{sub-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/sql-server-training/databases/SyncDB"
```

### 3. Elastic Pool Management
```bash
# Create elastic pool
az sql elastic-pool create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --name "ElasticPool1" \
  --edition Standard \
  --dtu 100 \
  --database-dtu-max 20 \
  --database-dtu-min 5

# Move database to pool
az sql db update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --name TrainingDB \
  --elastic-pool ElasticPool1
```

## Security Management

### 1. Advanced Threat Protection
```bash
# Enable Advanced Threat Protection
az sql server atp-policy update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --state Enabled \
  --storage-account mystorageaccount \
  --storage-endpoint "https://mystorageaccount.blob.core.windows.net" \
  --storage-key "storage-key" \
  --retention-days 30
```

### 2. Vulnerability Assessment
```bash
# Configure vulnerability assessment
az sql server va-setting update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --storage-account mystorageaccount \
  --storage-container-path "https://mystorageaccount.blob.core.windows.net/vulnerability-assessment" \
  --storage-key "storage-key" \
  --recurring-scans true \
  --email-admins true
```

### 3. Transparent Data Encryption
```sql
-- Enable TDE
ALTER DATABASE TrainingDB SET ENCRYPTION ON;

-- Check TDE status
SELECT 
    db.name,
    db.is_encrypted,
    dm.encryption_state,
    dm.percent_complete,
    dm.key_algorithm,
    dm.key_length
FROM sys.databases db
LEFT OUTER JOIN sys.dm_database_encryption_keys dm
    ON db.database_id = dm.database_id;
```

### 4. Always Encrypted Configuration
```sql
-- Create column master key
CREATE COLUMN MASTER KEY [CMK1]
WITH (
    KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT',
    KEY_PATH = 'https://myvault.vault.azure.net/keys/mykey/version'
);

-- Create column encryption key
CREATE COLUMN ENCRYPTION KEY [CEK1]
WITH VALUES (
    COLUMN_MASTER_KEY = [CMK1],
    ALGORITHM = 'RSA_OAEP'
);

-- Encrypt column
ALTER TABLE Employees
ALTER COLUMN Email nvarchar(100) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (
    COLUMN_ENCRYPTION_KEY = [CEK1],
    ENCRYPTION_TYPE = Deterministic,
    ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
);
```

## Intelligent Performance

### 1. Automatic Tuning
```bash
# Enable automatic tuning
az sql db update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --server sql-server-training \
  --name TrainingDB \
  --auto-pause-delay 60 \
  --compute-model Serverless \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 1
```

### 2. Query Performance Insights
Access through Azure Portal:
- Navigate to SQL Database → Query Performance Insight
- Review top resource consuming queries
- Analyze query execution statistics
- View query execution plans

### 3. Performance Recommendations
```sql
-- View performance recommendations
SELECT 
    r.recommendation_id,
    r.type,
    r.state,
    r.created_time,
    r.last_refresh,
    JSON_VALUE(r.details, '$.implementationDetails.script') as script
FROM sys.dm_db_tuning_recommendations r;
```

### 4. Index Management
```sql
-- Create performance indexes
CREATE NONCLUSTERED INDEX IX_Employees_Department
ON Employees (Department)
INCLUDE (FirstName, LastName, Email);

-- Monitor index usage
SELECT 
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1;
```

## Monitoring and Alerting

### 1. Metrics Configuration
```bash
# Create metric alert
az monitor metrics alert create \
  --name "High-CPU-Alert" \
  --resource-group sa1_test_eic_SudarshanDarade \
  --scopes "/subscriptions/{sub-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/sql-server-training/databases/TrainingDB" \
  --condition "avg cpu_percent > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action myActionGroup
```

### 2. Log Analytics Integration
```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name "SQLLogAnalytics"

# Configure diagnostic settings
az monitor diagnostic-settings create \
  --resource "/subscriptions/{sub-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Sql/servers/sql-server-training/databases/TrainingDB" \
  --name "SQLDiagnostics" \
  --workspace "/subscriptions/{sub-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/SQLLogAnalytics" \
  --logs '[{"category":"QueryStoreRuntimeStatistics","enabled":true},{"category":"QueryStoreWaitStatistics","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]'
```

### 3. Custom Monitoring Queries
```sql
-- Monitor blocking sessions
SELECT 
    blocking_session_id,
    session_id,
    wait_type,
    wait_time,
    wait_resource,
    command,
    sql_handle
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

-- Monitor resource usage
SELECT 
    end_time,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    avg_memory_usage_percent,
    xtp_storage_percent,
    max_worker_percent,
    max_session_percent
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;
```

## Troubleshooting

### 1. Connection Issues
```sql
-- Check connection limits
SELECT 
    COUNT(*) as current_connections,
    @@MAX_CONNECTIONS as max_connections
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;

-- View active connections
SELECT 
    session_id,
    login_name,
    host_name,
    program_name,
    login_time,
    last_request_start_time,
    status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;
```

### 2. Performance Troubleshooting
```sql
-- Identify expensive queries
SELECT TOP 10
    qs.execution_count,
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    SUBSTRING(qt.text, qs.statement_start_offset/2+1,
        (CASE WHEN qs.statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2 + 1) AS statement_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.total_worker_time / qs.execution_count DESC;
```

### 3. Storage Issues
```sql
-- Check database size and growth
SELECT 
    name,
    size * 8.0 / 1024 AS size_mb,
    max_size * 8.0 / 1024 AS max_size_mb,
    growth,
    is_percent_growth
FROM sys.database_files;

-- Monitor space usage
SELECT 
    SCHEMA_NAME(t.schema_id) AS schema_name,
    t.name AS table_name,
    i.name AS index_name,
    p.partition_number,
    p.rows,
    a.total_pages * 8 AS total_space_kb,
    a.used_pages * 8 AS used_space_kb,
    (a.total_pages - a.used_pages) * 8 AS unused_space_kb
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
ORDER BY total_space_kb DESC;
```

### 4. Security Troubleshooting
```sql
-- Check user permissions
SELECT 
    p.principal_id,
    p.name AS principal_name,
    p.type_desc AS principal_type,
    r.role_principal_id,
    r.name AS role_name
FROM sys.database_principals p
LEFT JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE p.type IN ('S', 'U', 'G')
ORDER BY p.name;

-- View failed login attempts
SELECT 
    event_time,
    succeeded,
    principal_name,
    database_name,
    client_ip,
    application_name
FROM sys.fn_get_audit_file('https://mystorageaccount.blob.core.windows.net/sqldbauditlogs/*/*', default, default)
WHERE action_name = 'DATABASE AUTHENTICATION FAILED'
ORDER BY event_time DESC;
```

## Best Practices Summary

### 1. Security Best Practices
- Enable Azure AD authentication
- Use least privilege access
- Enable Advanced Threat Protection
- Configure auditing and monitoring
- Implement encryption for sensitive data

### 2. Performance Best Practices
- Monitor resource utilization regularly
- Use Query Performance Insights
- Implement proper indexing strategies
- Enable automatic tuning features
- Regular performance baseline reviews

### 3. Monitoring Best Practices
- Set up comprehensive alerting
- Use Log Analytics for centralized logging
- Monitor key performance metrics
- Regular security assessments
- Document troubleshooting procedures

### 4. Maintenance Best Practices
- Regular backup testing
- Keep statistics updated
- Monitor storage growth
- Review and optimize queries
- Plan for capacity scaling

## Verification Checklist

- ✅ SQL Server dashboard navigation completed
- ✅ Activity logs configured and reviewed
- ✅ Access control and security implemented
- ✅ Server settings optimized
- ✅ Data management procedures tested
- ✅ Security features enabled and configured
- ✅ Intelligent performance features activated
- ✅ Monitoring and alerting set up
- ✅ Troubleshooting procedures documented

---

**Next Steps**: Proceed to Task-SQL-03 for advanced SQL database optimization and maintenance procedures.
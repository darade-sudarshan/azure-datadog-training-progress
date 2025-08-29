# Task-SQL-04: SQL Server Stretch Database and Multiple Instance Configuration

## Overview
This task covers enabling SQL Server Stretch Database for hybrid cloud scenarios and creating multiple SQL Server instances on Azure Virtual Machines for development, testing, and production environments.

## SQL Server Stretch Database Overview

### What is Stretch Database?
SQL Server Stretch Database is a feature that dynamically stretches warm and cold transactional data from Microsoft SQL Server 2016 to Microsoft Azure. Stretch Database stores cold data in Azure while keeping hot data on-premises.

### Benefits
- **Cost Reduction**: Store cold data in Azure at lower cost
- **Transparent Access**: Query both hot and cold data seamlessly
- **Security**: Data remains encrypted during migration
- **No Application Changes**: Existing applications work without modification
- **Flexible Migration**: Choose which tables and rows to stretch

### Prerequisites
- SQL Server 2016 or later
- Azure subscription
- Database compatibility level 130 or higher
- Tables must have a primary key
- Firewall configured for Azure connectivity

## Task 1: Prepare Environment for Stretch Database

### Enable Stretch Database Feature
```sql
-- Check if Stretch Database is enabled
SELECT name, is_stretch_database_enabled 
FROM sys.databases 
WHERE name = 'StretchTestDB';

-- Enable Stretch Database at server level
EXEC sp_configure 'remote data archive', 1;
RECONFIGURE;
```

### Create Test Database and Table
```sql
-- Create database
CREATE DATABASE StretchTestDB;
GO

USE StretchTestDB;
GO

-- Create table suitable for stretching
CREATE TABLE Orders (
    OrderID int IDENTITY(1,1) PRIMARY KEY,
    CustomerID int NOT NULL,
    OrderDate datetime2 NOT NULL,
    OrderAmount decimal(10,2),
    Status nvarchar(20),
    Region nvarchar(50),
    CreatedDate datetime2 DEFAULT GETDATE()
);

-- Insert sample data with historical records
DECLARE @i int = 1;
WHILE @i <= 10000
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate, OrderAmount, Status, Region)
    VALUES 
        (@i % 100 + 1, 
         DATEADD(day, -(@i % 1000), GETDATE()), 
         RAND() * 1000 + 100,
         CASE @i % 3 WHEN 0 THEN 'Completed' WHEN 1 THEN 'Pending' ELSE 'Cancelled' END,
         CASE @i % 4 WHEN 0 THEN 'North' WHEN 1 THEN 'South' WHEN 2 THEN 'East' ELSE 'West' END);
    SET @i = @i + 1;
END
```

## Task 2: Configure Azure Resources for Stretch Database

### Create Azure SQL Database for Stretch
```bash
# Create resource group
az group create --name rg-stretch-database --location eastus

# Create SQL Server
az sql server create \
  --name stretch-sql-server-001 \
  --resource-group rg-stretch-database \
  --location eastus \
  --admin-user stretchadmin \
  --admin-password P@ssw0rd123!

# Configure firewall for Azure services
az sql server firewall-rule create \
  --resource-group rg-stretch-database \
  --server stretch-sql-server-001 \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Create database for stretch data
az sql db create \
  --resource-group rg-stretch-database \
  --server stretch-sql-server-001 \
  --name StretchRemoteDB \
  --service-objective S1
```

### Configure Server Firewall for On-Premises
```bash
# Get your public IP
curl -s https://ipinfo.io/ip

# Add firewall rule for on-premises server
az sql server firewall-rule create \
  --resource-group rg-stretch-database \
  --server stretch-sql-server-001 \
  --name AllowOnPremises \
  --start-ip-address YOUR-PUBLIC-IP \
  --end-ip-address YOUR-PUBLIC-IP
```

## Task 3: Enable Stretch Database via SSMS

### Using Stretch Database Wizard
1. Connect to SQL Server instance in SSMS
2. Right-click database → Tasks → Stretch → Enable
3. **Introduction Page**: Review Stretch Database benefits
4. **Select Tables**: Choose tables to stretch
   - Select "Orders" table
   - Choose stretch method: "Entire Table" or "Use a function"
5. **Configure Azure**: 
   ```
   Server: stretch-sql-server-001.database.windows.net
   Database: StretchRemoteDB
   Authentication: SQL Server Authentication
   Username: stretchadmin
   Password: P@ssw0rd123!
   ```
6. **Secure Credentials**: Create database master key
7. **Select IP Address**: Configure firewall rules
8. **Summary**: Review configuration
9. **Results**: Monitor enablement progress

### Manual Configuration via T-SQL
```sql
-- Create database master key
USE StretchTestDB;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKey@123!';

-- Create database scoped credential
CREATE DATABASE SCOPED CREDENTIAL StretchCredential
WITH IDENTITY = 'stretchadmin',
SECRET = 'P@ssw0rd123!';

-- Enable stretch for database
ALTER DATABASE StretchTestDB
SET REMOTE_DATA_ARCHIVE = ON (
    SERVER = 'stretch-sql-server-001.database.windows.net',
    CREDENTIAL = StretchCredential
);

-- Enable stretch for table
ALTER TABLE Orders
SET (REMOTE_DATA_ARCHIVE = ON (
    FILTER_PREDICATE = dbo.fn_stretchpredicate(OrderDate),
    MIGRATION_STATE = OUTBOUND
));
```

## Task 4: Create Stretch Filter Function

### Date-Based Filter Function
```sql
-- Create filter function for old orders
CREATE FUNCTION dbo.fn_stretchpredicate(@OrderDate datetime2)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS is_eligible
WHERE @OrderDate < DATEADD(year, -1, GETDATE());

-- Apply filter to table
ALTER TABLE Orders
SET (REMOTE_DATA_ARCHIVE = ON (
    FILTER_PREDICATE = dbo.fn_stretchpredicate(OrderDate),
    MIGRATION_STATE = OUTBOUND
));
```

### Status-Based Filter Function
```sql
-- Create filter for completed orders
CREATE FUNCTION dbo.fn_stretchpredicate_status(@Status nvarchar(20), @OrderDate datetime2)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS is_eligible
WHERE @Status = 'Completed' AND @OrderDate < DATEADD(month, -6, GETDATE());
```

## Task 5: Monitor Stretch Database

### Check Stretch Status
```sql
-- View stretch-enabled databases
SELECT 
    name,
    is_stretch_database_enabled,
    remote_data_archive_migration_state_desc
FROM sys.databases
WHERE is_stretch_database_enabled = 1;

-- View stretch-enabled tables
SELECT 
    t.name AS table_name,
    t.is_remote_data_archive_enabled,
    t.remote_data_archive_migration_state_desc,
    p.rows AS local_rows
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.is_remote_data_archive_enabled = 1
AND p.index_id IN (0,1);

-- Check migration progress
SELECT 
    table_name,
    migrated_rows,
    migration_direction,
    migration_state,
    start_time,
    end_time
FROM sys.dm_db_rda_migration_status;
```

### Monitor Data Movement
```sql
-- View stretch database statistics
SELECT 
    database_id,
    table_id,
    rows_migrated,
    rows_failed,
    batch_id,
    start_time_utc,
    end_time_utc
FROM sys.dm_db_rda_schema_update_status;

-- Check remote query execution
SELECT 
    session_id,
    request_id,
    start_time,
    status,
    command,
    database_id,
    blocking_session_id
FROM sys.dm_exec_requests
WHERE command LIKE '%REMOTE%';
```

## Task 6: Multiple SQL Server Instances on Azure VM

### Planning Multiple Instances
- **Default Instance**: MSSQLSERVER (port 1433)
- **Named Instances**: Custom names (dynamic ports or custom ports)
- **Resource Allocation**: CPU, memory, and storage per instance
- **Use Cases**: Development, Testing, Production separation

### Create VM for Multiple Instances
```bash
# Create larger VM for multiple instances
az vm create \
  --resource-group rg-sql-multi-instance \
  --name sql-multi-vm \
  --image MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:latest \
  --size Standard_D4s_v3 \
  --admin-username sqladmin \
  --admin-password P@ssw0rd123! \
  --os-disk-size-gb 256 \
  --data-disk-sizes-gb 128 128 \
  --storage-sku Premium_LRS \
  --nsg-rule RDP \
  --public-ip-sku Standard
```

### Configure Additional Ports
```bash
# Add ports for named instances
az network nsg rule create \
  --resource-group rg-sql-multi-instance \
  --nsg-name sql-multi-vmNSG \
  --name AllowSQL-Instance2 \
  --protocol Tcp \
  --priority 1002 \
  --destination-port-range 1434 \
  --access Allow

az network nsg rule create \
  --resource-group rg-sql-multi-instance \
  --nsg-name sql-multi-vmNSG \
  --name AllowSQL-Instance3 \
  --protocol Tcp \
  --priority 1003 \
  --destination-port-range 1435 \
  --access Allow
```

## Task 7: Install Multiple SQL Server Instances

### Install Second Instance (DEV)
1. RDP to the VM
2. Mount SQL Server installation media
3. Run setup.exe
4. Choose "New SQL Server stand-alone installation"
5. Configure instance:
   ```
   Instance Name: DEV
   Instance ID: DEV
   Instance root directory: C:\Program Files\Microsoft SQL Server\
   ```
6. Configure services:
   ```
   SQL Server Database Engine: Automatic
   SQL Server Agent: Automatic
   Account: NT Service\MSSQL$DEV
   ```
7. Set authentication mode: Mixed Mode
8. Add current user as SQL Server administrator

### Install Third Instance (TEST)
Repeat installation process with:
```
Instance Name: TEST
Instance ID: TEST
Service accounts: NT Service\MSSQL$TEST
```

### Configure Instance Ports
```sql
-- Connect to each instance and configure ports
-- For DEV instance (connect via SERVERNAME\DEV)
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.DEV\MSSQLServer\SuperSocketNetLib\Tcp\IPAll', 
    N'TcpPort', 
    REG_SZ, 
    N'1434';

-- For TEST instance (connect via SERVERNAME\TEST)
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.TEST\MSSQLServer\SuperSocketNetLib\Tcp\IPAll', 
    N'TcpPort', 
    REG_SZ, 
    N'1435';
```

### Restart SQL Server Services
```powershell
# Restart services for port changes
Restart-Service -Name "MSSQL$DEV" -Force
Restart-Service -Name "MSSQL$TEST" -Force
Restart-Service -Name "SQLAgent$DEV" -Force
Restart-Service -Name "SQLAgent$TEST" -Force
```

## Task 8: Configure Multiple Instance Resources

### Memory Configuration
```sql
-- Configure memory for default instance (4GB)
EXEC sp_configure 'max server memory (MB)', 4096;
RECONFIGURE;

-- Configure memory for DEV instance (2GB)
-- Connect to DEV instance
EXEC sp_configure 'max server memory (MB)', 2048;
RECONFIGURE;

-- Configure memory for TEST instance (2GB)
-- Connect to TEST instance
EXEC sp_configure 'max server memory (MB)', 2048;
RECONFIGURE;
```

### CPU Configuration
```sql
-- Configure CPU affinity for instances
-- Default instance: CPUs 0-1
EXEC sp_configure 'affinity mask', 3; -- Binary: 11 (CPUs 0,1)
RECONFIGURE;

-- DEV instance: CPU 2
-- Connect to DEV instance
EXEC sp_configure 'affinity mask', 4; -- Binary: 100 (CPU 2)
RECONFIGURE;

-- TEST instance: CPU 3
-- Connect to TEST instance
EXEC sp_configure 'affinity mask', 8; -- Binary: 1000 (CPU 3)
RECONFIGURE;
```

### Storage Configuration
```sql
-- Configure different data directories for each instance
-- Default instance
ALTER DATABASE tempdb MODIFY FILE (
    NAME = 'tempdev',
    FILENAME = 'C:\Data\Default\tempdb.mdf'
);

-- DEV instance
ALTER DATABASE tempdb MODIFY FILE (
    NAME = 'tempdev',
    FILENAME = 'D:\Data\DEV\tempdb.mdf'
);

-- TEST instance
ALTER DATABASE tempdb MODIFY FILE (
    NAME = 'tempdev',
    FILENAME = 'E:\Data\TEST\tempdb.mdf'
);
```

## Task 9: Connect to Multiple Instances

### Connection Strings
```
Default Instance: SERVER-NAME,1433
DEV Instance: SERVER-NAME\DEV,1434
TEST Instance: SERVER-NAME\TEST,1435
```

### SSMS Connections
1. **Default Instance**:
   ```
   Server: VM-IP-ADDRESS
   Authentication: SQL Server Authentication
   Login: sa
   Password: P@ssw0rd123!
   ```

2. **DEV Instance**:
   ```
   Server: VM-IP-ADDRESS\DEV
   Authentication: SQL Server Authentication
   Login: sa
   Password: P@ssw0rd123!
   ```

3. **TEST Instance**:
   ```
   Server: VM-IP-ADDRESS\TEST
   Authentication: SQL Server Authentication
   Login: sa
   Password: P@ssw0rd123!
   ```

### PowerShell Connection Test
```powershell
# Test connections to all instances
$instances = @(
    "VM-IP-ADDRESS,1433",
    "VM-IP-ADDRESS\DEV,1434",
    "VM-IP-ADDRESS\TEST,1435"
)

foreach ($instance in $instances) {
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=$instance;Integrated Security=true;Connection Timeout=5"
        $connection.Open()
        Write-Host "✓ Connected to $instance" -ForegroundColor Green
        $connection.Close()
    }
    catch {
        Write-Host "✗ Failed to connect to $instance" -ForegroundColor Red
    }
}
```

## Task 10: Instance Management and Monitoring

### Service Management
```powershell
# Check all SQL Server services
Get-Service -Name "*SQL*" | Select-Object Name, Status, StartType

# Start/Stop specific instances
Start-Service -Name "MSSQL$DEV"
Stop-Service -Name "MSSQL$TEST"

# Set service startup type
Set-Service -Name "MSSQL$DEV" -StartupType Automatic
```

### Performance Monitoring
```sql
-- Monitor instance resource usage
SELECT 
    @@SERVERNAME as InstanceName,
    cpu_count,
    hyperthread_ratio,
    physical_memory_kb / 1024 as physical_memory_mb,
    committed_kb / 1024 as committed_memory_mb,
    committed_target_kb / 1024 as target_memory_mb
FROM sys.dm_os_sys_info;

-- Check instance-specific wait stats
SELECT TOP 10
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
ORDER BY wait_time_ms DESC;
```

### Cross-Instance Queries
```sql
-- Query from one instance to another
-- From default instance, query DEV instance
SELECT * FROM OPENROWSET(
    'SQLNCLI',
    'Server=localhost\DEV;Trusted_Connection=yes;',
    'SELECT @@SERVERNAME as ServerName, DB_NAME() as DatabaseName'
);

-- Create linked server for cross-instance queries
EXEC sp_addlinkedserver 
    @server = 'DEV_INSTANCE',
    @srvproduct = 'SQL Server',
    @provider = 'SQLNCLI',
    @datasrc = 'localhost\DEV';

-- Query via linked server
SELECT * FROM DEV_INSTANCE.master.sys.databases;
```

## Task 11: Stretch Database Maintenance

### Pause and Resume Migration
```sql
-- Pause migration
ALTER TABLE Orders SET (REMOTE_DATA_ARCHIVE (MIGRATION_STATE = PAUSED));

-- Resume migration
ALTER TABLE Orders SET (REMOTE_DATA_ARCHIVE (MIGRATION_STATE = OUTBOUND));

-- Force migration of specific rows
EXEC sp_rda_reconcile_batch @objname = 'dbo.Orders';
```

### Disable Stretch Database
```sql
-- Disable stretch for table (bring data back)
ALTER TABLE Orders SET (REMOTE_DATA_ARCHIVE = OFF_WITHOUT_DATA_RECOVERY);

-- Or bring data back first
ALTER TABLE Orders SET (REMOTE_DATA_ARCHIVE (MIGRATION_STATE = INBOUND));

-- Disable stretch for database
ALTER DATABASE StretchTestDB SET REMOTE_DATA_ARCHIVE = OFF;
```

## Task 12: Best Practices and Troubleshooting

### Stretch Database Best Practices
- **Table Selection**: Choose tables with historical data
- **Filter Functions**: Use efficient predicates
- **Indexing**: Maintain indexes on frequently queried columns
- **Monitoring**: Regular monitoring of migration progress
- **Security**: Use encrypted connections and strong credentials

### Multiple Instance Best Practices
- **Resource Planning**: Allocate CPU, memory, and storage appropriately
- **Port Management**: Use consistent port assignments
- **Service Accounts**: Use separate service accounts per instance
- **Backup Strategy**: Separate backup schedules and locations
- **Monitoring**: Instance-specific monitoring and alerting

### Common Issues and Solutions

#### Stretch Database Issues
```sql
-- Check for migration errors
SELECT * FROM sys.dm_db_rda_migration_status
WHERE migration_state = 4; -- Error state

-- Resolve connectivity issues
SELECT * FROM sys.dm_db_rda_schema_update_status
WHERE last_error_number IS NOT NULL;
```

#### Multiple Instance Issues
```powershell
# Check port conflicts
netstat -an | findstr ":1433"
netstat -an | findstr ":1434"
netstat -an | findstr ":1435"

# Verify service accounts
Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -like "*SQL*"} | Select-Object Name, StartName
```

## Task 13: Cleanup and Resource Management

### Stretch Database Cleanup
```sql
-- Disable stretch and clean up
ALTER TABLE Orders SET (REMOTE_DATA_ARCHIVE = OFF_WITHOUT_DATA_RECOVERY);
ALTER DATABASE StretchTestDB SET REMOTE_DATA_ARCHIVE = OFF;
DROP DATABASE SCOPED CREDENTIAL StretchCredential;
DROP MASTER KEY;
```

### Azure Resources Cleanup
```bash
# Delete Azure resources
az group delete --name rg-stretch-database --yes --no-wait
az group delete --name rg-sql-multi-instance --yes --no-wait
```

## Verification Checklist

- ✅ Stretch Database enabled and configured
- ✅ Data migration working properly
- ✅ Multiple SQL Server instances installed
- ✅ Instance-specific ports configured
- ✅ Resource allocation optimized
- ✅ Cross-instance connectivity tested
- ✅ Monitoring and maintenance procedures established
- ✅ Security configurations implemented
- ✅ Backup strategies defined
- ✅ Troubleshooting procedures documented

---

**Next Steps**: Proceed to advanced SQL Server topics including Always On Availability Groups, failover clustering, and advanced security configurations.
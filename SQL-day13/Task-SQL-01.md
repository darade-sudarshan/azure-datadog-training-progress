# Task-SQL-01: Azure SQL Database and Server Creation

## Overview
This task covers creating Azure SQL Database and SQL Server, along with understanding various SQL deployment options available on Azure.

## Azure SQL Deployment Options

### 1. Azure SQL Database (Single Database)
- **Use Case**: Individual applications, microservices
- **Features**: Fully managed, serverless options, auto-scaling
- **Pricing**: Pay-per-use, reserved capacity options

### 2. Azure SQL Elastic Pool
- **Use Case**: Multiple databases with varying usage patterns
- **Features**: Shared resources, cost optimization
- **Pricing**: Pool-based pricing model

### 3. Azure SQL Managed Instance
- **Use Case**: Lift-and-shift scenarios, near 100% SQL Server compatibility
- **Features**: Instance-level features, cross-database queries
- **Pricing**: vCore-based model

### 4. SQL Server on Azure VMs
- **Use Case**: Full control over SQL Server, custom configurations
- **Features**: Complete SQL Server features, OS-level access
- **Pricing**: VM + SQL Server licensing

## Task 1: Create SQL Server and Database via Azure Portal

### Step 1: Create SQL Server
1. Navigate to Azure Portal → Create a resource
2. Search for "SQL Server" → Select "SQL Server (logical server)"
3. Configure basic settings:
   ```
   Server name: sql-server-training-001
   Resource group: rg-sql-training
   Location: East US
   Authentication: SQL authentication
   Server admin login: sqladmin
   Password: P@ssw0rd123!
   ```
4. Configure networking:
   - Allow Azure services: Yes
   - Add current client IP: Yes
5. Review and create

### Step 2: Create SQL Database
1. Navigate to the created SQL Server
2. Click "Create database"
3. Configure database settings:
   ```
   Database name: TrainingDB
   Compute tier: Provisioned
   Service tier: Standard (S0)
   Backup storage redundancy: Locally-redundant
   ```
4. Review and create

## Task 2: Create SQL Server and Database via Azure CLI

### Prerequisites
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"

# Create resource group
az group create --name rg-sql-training --location eastus
```

### Create SQL Server
```bash
az sql server create \
  --name sql-server-training-cli \
  --resource-group rg-sql-training \
  --location eastus \
  --admin-user sqladmin \
  --admin-password P@ssw0rd123!
```

### Configure Firewall Rules
```bash
# Allow Azure services
az sql server firewall-rule create \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Allow current IP
az sql server firewall-rule create \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --name AllowMyIP \
  --start-ip-address $(curl -s https://ipinfo.io/ip) \
  --end-ip-address $(curl -s https://ipinfo.io/ip)
```

### Create SQL Database
```bash
az sql db create \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --name TrainingDB \
  --service-objective S0 \
  --backup-storage-redundancy Local
```

## Task 3: Create SQL Server and Database via PowerShell

### Prerequisites
```powershell
# Install Azure PowerShell module
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Connect to Azure
Connect-AzAccount

# Set subscription context
Set-AzContext -SubscriptionId "your-subscription-id"
```

### Create Resource Group
```powershell
New-AzResourceGroup -Name "rg-sql-training-ps" -Location "East US"
```

### Create SQL Server
```powershell
$serverName = "sql-server-training-ps"
$resourceGroupName = "rg-sql-training-ps"
$location = "East US"
$adminLogin = "sqladmin"
$adminPassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

New-AzSqlServer -ResourceGroupName $resourceGroupName `
  -ServerName $serverName `
  -Location $location `
  -SqlAdministratorCredentials (New-Object System.Management.Automation.PSCredential($adminLogin, $adminPassword))
```

### Configure Firewall
```powershell
# Allow Azure services
New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
  -ServerName $serverName `
  -FirewallRuleName "AllowAzureServices" `
  -StartIpAddress "0.0.0.0" `
  -EndIpAddress "0.0.0.0"

# Allow current IP
$myIP = (Invoke-WebRequest -Uri "https://ipinfo.io/ip").Content.Trim()
New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
  -ServerName $serverName `
  -FirewallRuleName "AllowMyIP" `
  -StartIpAddress $myIP `
  -EndIpAddress $myIP
```

### Create SQL Database
```powershell
New-AzSqlDatabase -ResourceGroupName $resourceGroupName `
  -ServerName $serverName `
  -DatabaseName "TrainingDB" `
  -RequestedServiceObjectiveName "S0" `
  -BackupStorageRedundancy "Local"
```

## Task 4: Connect to SQL Database

### Using SQL Server Management Studio (SSMS)
1. Download and install SSMS
2. Connect using:
   ```
   Server: sql-server-training-001.database.windows.net
   Authentication: SQL Server Authentication
   Login: sqladmin
   Password: P@ssw0rd123!
   ```

### Using Azure Data Studio
1. Download and install Azure Data Studio
2. Create new connection with server details
3. Test connection and explore database

### Using sqlcmd
```bash
sqlcmd -S sql-server-training-001.database.windows.net -d TrainingDB -U sqladmin -P P@ssw0rd123!
```

## Task 5: Basic Database Operations

### Create Sample Table
```sql
CREATE TABLE Employees (
    EmployeeID int IDENTITY(1,1) PRIMARY KEY,
    FirstName nvarchar(50) NOT NULL,
    LastName nvarchar(50) NOT NULL,
    Email nvarchar(100) UNIQUE,
    Department nvarchar(50),
    HireDate date DEFAULT GETDATE()
);
```

### Insert Sample Data
```sql
INSERT INTO Employees (FirstName, LastName, Email, Department)
VALUES 
    ('John', 'Doe', 'john.doe@company.com', 'IT'),
    ('Jane', 'Smith', 'jane.smith@company.com', 'HR'),
    ('Mike', 'Johnson', 'mike.johnson@company.com', 'Finance');
```

### Query Data
```sql
SELECT * FROM Employees;
SELECT COUNT(*) as TotalEmployees FROM Employees;
SELECT Department, COUNT(*) as EmployeeCount 
FROM Employees 
GROUP BY Department;
```

## Task 6: Monitoring and Performance

### View Database Metrics
1. Navigate to SQL Database in Azure Portal
2. Check "Metrics" section for:
   - DTU percentage
   - CPU percentage
   - Data IO percentage
   - Log IO percentage

### Query Performance Insights
1. Enable Query Performance Insights
2. Review top consuming queries
3. Analyze query execution plans

## Task 7: Security Configuration

### Configure Advanced Threat Protection
```bash
az sql db threat-policy update \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --database TrainingDB \
  --state Enabled
```

### Enable Auditing
```bash
az sql db audit-policy update \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --database TrainingDB \
  --state Enabled \
  --storage-account mystorageaccount
```

## Task 8: Backup and Restore

### Point-in-Time Restore
```bash
az sql db restore \
  --dest-name TrainingDB-Restored \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --source-database TrainingDB \
  --time "2024-01-15T10:00:00"
```

### Export Database (BACPAC)
```bash
az sql db export \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --name TrainingDB \
  --storage-key-type StorageAccessKey \
  --storage-key "your-storage-key" \
  --storage-uri "https://mystorageaccount.blob.core.windows.net/backups/TrainingDB.bacpac" \
  --admin-user sqladmin \
  --admin-password P@ssw0rd123!
```

## Task 9: Scaling and Performance Tuning

### Scale Database
```bash
# Scale up to S1
az sql db update \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --name TrainingDB \
  --service-objective S1

# Scale to serverless
az sql db update \
  --resource-group rg-sql-training \
  --server sql-server-training-cli \
  --name TrainingDB \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 1 \
  --compute-model Serverless
```

## Task 10: Cleanup Resources

### Delete Resources
```bash
# Delete resource group (removes all resources)
az group delete --name rg-sql-training --yes --no-wait
```

## Best Practices

1. **Security**:
   - Use Azure AD authentication when possible
   - Enable Advanced Threat Protection
   - Configure firewall rules restrictively
   - Enable auditing and monitoring

2. **Performance**:
   - Choose appropriate service tier
   - Monitor DTU/vCore usage
   - Use Query Performance Insights
   - Implement proper indexing

3. **Cost Optimization**:
   - Use serverless for intermittent workloads
   - Consider elastic pools for multiple databases
   - Monitor and adjust service tiers
   - Use reserved capacity for predictable workloads

4. **Backup and Recovery**:
   - Understand automatic backup retention
   - Test restore procedures
   - Consider geo-replication for critical databases
   - Document recovery procedures

## Verification Steps

1. ✅ SQL Server created successfully
2. ✅ SQL Database created and accessible
3. ✅ Firewall rules configured properly
4. ✅ Connection established from client tools
5. ✅ Sample data inserted and queried
6. ✅ Monitoring and metrics reviewed
7. ✅ Security features enabled
8. ✅ Backup and restore tested

## Troubleshooting

### Common Issues:
1. **Connection timeout**: Check firewall rules and network connectivity
2. **Authentication failed**: Verify credentials and authentication method
3. **Database not accessible**: Ensure database is online and not paused
4. **Performance issues**: Check DTU usage and query performance

### Useful Commands:
```bash
# Check server status
az sql server show --name sql-server-training-cli --resource-group rg-sql-training

# List databases
az sql db list --server sql-server-training-cli --resource-group rg-sql-training

# Check firewall rules
az sql server firewall-rule list --server sql-server-training-cli --resource-group rg-sql-training
```

---

**Next Steps**: Proceed to Task-SQL-02 for advanced SQL database management and optimization techniques.
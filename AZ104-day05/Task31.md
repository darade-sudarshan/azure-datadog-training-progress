# Task 31: Azure Log Analytics Workspace

## Overview
Azure Log Analytics workspace is a centralized repository for collecting, analyzing, and acting on log data from various Azure resources, on-premises systems, and other cloud environments.

## Log Analytics Queries (KQL)

### Basic Query Structure
```kql
// Basic table query
Heartbeat
| where TimeGenerated > ago(1h)
| summarize count() by Computer
```

### Common Query Examples

#### VM Performance Queries
```kql
// CPU utilization
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| where TimeGenerated > ago(1h)
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)

// Memory usage
Perf
| where ObjectName == "Memory" and CounterName == "Available MBytes"
| where TimeGenerated > ago(1h)
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)

// Disk space
Perf
| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
| where TimeGenerated > ago(1h)
| summarize avg(CounterValue) by Computer, InstanceName
```

#### Security and Event Queries
```kql
// Failed login attempts
SecurityEvent
| where EventID == 4625
| where TimeGenerated > ago(24h)
| summarize count() by Account, Computer

// System events
Event
| where EventLevelName == "Error"
| where TimeGenerated > ago(1h)
| summarize count() by Source, EventID
```

#### Application Insights Queries
```kql
// Request performance
requests
| where timestamp > ago(1h)
| summarize avg(duration), count() by name
| order by avg_duration desc

// Exception tracking
exceptions
| where timestamp > ago(24h)
| summarize count() by type, outerMessage
```

## Alerts Configuration

### Metric Alerts
1. **CPU Alert**
   - Condition: Average CPU > 80%
   - Time window: 5 minutes
   - Frequency: 1 minute
   - Action: Email notification

2. **Memory Alert**
   - Condition: Available memory < 1GB
   - Time window: 5 minutes
   - Frequency: 1 minute

### Log Search Alerts
```kql
// Alert query for failed logins
SecurityEvent
| where EventID == 4625
| where TimeGenerated > ago(5m)
| summarize count() by Computer
| where count_ > 5
```

### Alert Rule Configuration
- **Alert rule name**: High Failed Login Attempts
- **Severity**: 2 - Warning
- **Threshold**: Greater than 0
- **Evaluation frequency**: 5 minutes
- **Time window**: 5 minutes

## Connecting VM to Log Analytics Workspace

### Method 1: Azure Portal
1. Navigate to Log Analytics workspace
2. Go to **Virtual machines** under workspace data sources
3. Select the VM to connect
4. Click **Connect**
5. Agent will be automatically installed

### Method 2: PowerShell
```powershell
# Install Log Analytics agent via PowerShell
$WorkspaceId = "your-workspace-id"
$WorkspaceKey = "your-workspace-key"

# Download and install agent
$AgentUri = "https://go.microsoft.com/fwlink/?LinkId=828603"
Invoke-WebRequest -Uri $AgentUri -OutFile "MMASetup-AMD64.exe"

# Install with workspace configuration
.\MMASetup-AMD64.exe /C:"setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID=$WorkspaceId OPINSIGHTS_WORKSPACE_KEY=$WorkspaceKey AcceptEndUserLicenseAgreement=1"
```

### Method 3: ARM Template
```json
{
  "type": "Microsoft.Compute/virtualMachines/extensions",
  "apiVersion": "2021-03-01",
  "name": "[concat(parameters('vmName'), '/MicrosoftMonitoringAgent')]",
  "properties": {
    "publisher": "Microsoft.EnterpriseCloud.Monitoring",
    "type": "MicrosoftMonitoringAgent",
    "typeHandlerVersion": "1.0",
    "settings": {
      "workspaceId": "[parameters('workspaceId')]"
    },
    "protectedSettings": {
      "workspaceKey": "[parameters('workspaceKey')]"
    }
  }
}
```

## Collecting IIS Logs from VM

### Enable IIS Log Collection
1. **Configure IIS Logging**
   - Open IIS Manager
   - Select website
   - Double-click **Logging**
   - Set log file format to **W3C**
   - Configure fields to log

2. **Log Analytics Configuration**
   ```kql
   // Navigate to workspace > Advanced settings > Data > IIS Logs
   // Enable IIS log collection
   // Specify log file path: C:\inetpub\logs\LogFiles\W3SVC1\
   ```

### IIS Log Query Examples
```kql
// Top requested pages
W3CIISLog
| where TimeGenerated > ago(1h)
| summarize count() by csUriStem
| order by count_ desc
| take 10

// Error responses
W3CIISLog
| where scStatus >= 400
| where TimeGenerated > ago(24h)
| summarize count() by scStatus, csUriStem

// Traffic by IP
W3CIISLog
| where TimeGenerated > ago(1h)
| summarize requests = count(), bytes = sum(scBytes) by cIP
| order by requests desc
```

### Custom IIS Log Fields
```xml
<!-- IIS applicationHost.config -->
<logFile>
  <add name="Date" />
  <add name="Time" />
  <add name="ClientIP" />
  <add name="UserName" />
  <add name="Method" />
  <add name="UriStem" />
  <add name="UriQuery" />
  <add name="HttpStatus" />
  <add name="BytesSent" />
  <add name="BytesReceived" />
  <add name="TimeTaken" />
  <add name="UserAgent" />
  <add name="Referer" />
</logFile>
```

## Sending Custom Logs

### Method 1: HTTP Data Collector API
```powershell
# PowerShell script to send custom logs
$CustomerId = "your-workspace-id"
$SharedKey = "your-workspace-key"
$LogType = "MyCustomLog"

$json = @"
[{
    "Computer": "$env:COMPUTERNAME",
    "Application": "MyApp",
    "Message": "Custom log entry",
    "Severity": "Information",
    "Timestamp": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')"
}]
"@

# Function to create authorization signature
function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    return "SharedKey ${customerId}:${encodedHash}"
}

# Send log data
$method = "POST"
$contentType = "application/json"
$resource = "/api/logs"
$rfc1123date = [DateTime]::UtcNow.ToString("r")
$contentLength = $json.Length
$signature = Build-Signature -customerId $CustomerId -sharedKey $SharedKey -date $rfc1123date -contentLength $contentLength -method $method -contentType $contentType -resource $resource

$uri = "https://" + $CustomerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"
$headers = @{
    "Authorization" = $signature
    "Log-Type" = $LogType
    "x-ms-date" = $rfc1123date
}

Invoke-RestMethod -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $json
```

### Method 2: Custom Log Files
1. **Configure Custom Log Collection**
   - Workspace > Advanced settings > Data > Custom Logs
   - Upload sample log file
   - Define record delimiter
   - Set collection path

2. **Sample Custom Log Format**
   ```
   2024-01-15 10:30:00,INFO,Application started successfully
   2024-01-15 10:30:15,WARNING,High memory usage detected
   2024-01-15 10:30:30,ERROR,Database connection failed
   ```

### Method 3: Fluentd Agent
```ruby
# fluentd configuration for custom logs
<source>
  @type tail
  path /var/log/myapp/*.log
  pos_file /var/log/fluentd/myapp.log.pos
  tag myapp.logs
  format json
</source>

<match myapp.logs>
  @type azure-loganalytics
  customer_id YOUR_WORKSPACE_ID
  shared_key YOUR_WORKSPACE_KEY
  log_type MyAppLogs
</match>
```

## VM Insights

### Overview
VM Insights provides comprehensive monitoring for Azure VMs, including performance metrics, dependency mapping, and health monitoring.

### Enabling VM Insights

#### Method 1: Azure Portal
1. Navigate to **Azure Monitor** > **Virtual Machines**
2. Select VM to monitor
3. Click **Enable** under Insights
4. Choose Log Analytics workspace
5. Enable dependency agent (optional)

#### Method 2: Azure Policy
```json
{
  "mode": "Indexed",
  "policyRule": {
    "if": {
      "field": "type",
      "equals": "Microsoft.Compute/virtualMachines"
    },
    "then": {
      "effect": "deployIfNotExists",
      "details": {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "MicrosoftMonitoringAgent"
      }
    }
  }
}
```

### VM Insights Features

#### Performance Monitoring
- **CPU utilization trends**
- **Memory usage patterns**
- **Disk I/O metrics**
- **Network traffic analysis**

#### Dependency Mapping
```kql
// Query for VM dependencies
VMConnection
| where TimeGenerated > ago(1h)
| where Computer == "MyVM"
| summarize by RemoteIp, ProcessName, Direction
```

#### Health Monitoring
- **Guest OS health**
- **Workload health**
- **Availability monitoring**
- **Performance health**

### VM Insights Queries

#### Top Processes by CPU
```kql
VMProcess
| where TimeGenerated > ago(1h)
| where Computer == "MyVM"
| summarize avg(CpuUtilizationPercentage) by ProcessName
| order by avg_CpuUtilizationPercentage desc
| take 10
```

#### Network Connections
```kql
VMConnection
| where TimeGenerated > ago(1h)
| where Computer == "MyVM"
| summarize ConnectionCount = count() by RemoteIp, Direction
| order by ConnectionCount desc
```

#### Memory Usage by Process
```kql
VMProcess
| where TimeGenerated > ago(1h)
| where Computer == "MyVM"
| summarize avg(WorkingSetSizeMB) by ProcessName
| order by avg_WorkingSetSizeMB desc
| take 10
```

### VM Insights Workbooks
- **Performance workbook**: CPU, memory, disk, network trends
- **Map workbook**: Dependency visualization
- **Health workbook**: Health status and diagnostics

### Best Practices

#### Data Retention
- Configure appropriate retention periods
- Use data export for long-term storage
- Implement data archival strategies

#### Cost Optimization
- Monitor data ingestion volumes
- Use sampling for high-volume logs
- Configure log collection selectively

#### Security
- Implement RBAC for workspace access
- Use managed identities for authentication
- Enable audit logging for workspace changes

#### Performance
- Optimize KQL queries for efficiency
- Use summarization for large datasets
- Implement proper indexing strategies

## Troubleshooting

### Common Issues
1. **Agent connectivity problems**
   - Check firewall rules
   - Verify workspace ID and key
   - Test network connectivity

2. **Missing log data**
   - Verify agent installation
   - Check log collection configuration
   - Review agent logs

3. **Query performance issues**
   - Optimize KQL queries
   - Use appropriate time ranges
   - Implement query caching

### Monitoring Agent Health
```kql
Heartbeat
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(5m)
```
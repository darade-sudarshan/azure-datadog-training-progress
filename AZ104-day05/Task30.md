# Task 30: Azure Monitor Service

## What is Azure Monitor?

Azure Monitor is a comprehensive monitoring solution that collects, analyzes, and responds to telemetry data from cloud and on-premises environments. It provides full-stack monitoring, intelligent analytics, and automated responses to help maintain application performance and availability.

## Key Components:
- **Metrics**: Numerical values collected at regular intervals
- **Logs**: Text-based data stored in Log Analytics workspaces
- **Alerts**: Proactive notifications based on conditions
- **Dashboards**: Visual representations of monitoring data
- **Insights**: Pre-built monitoring solutions for specific services

## Azure Monitor Architecture

### Data Sources:
- **Application data**: Application Insights telemetry
- **Guest OS data**: Performance counters, event logs
- **Azure resource data**: Resource logs and metrics
- **Azure subscription data**: Activity logs, service health
- **Azure tenant data**: Azure Active Directory logs

### Data Platforms:
- **Azure Monitor Metrics**: Time-series database
- **Azure Monitor Logs**: Log Analytics workspace
- **Application Insights**: Application performance monitoring

## Setting Up Azure Monitor

### Create Log Analytics Workspace:

#### Azure CLI:
```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
    --resource-group myRG \
    --workspace-name mylogworkspace \
    --location eastus \
    --sku PerGB2018
```

#### PowerShell:
```powershell
# Create Log Analytics workspace
New-AzOperationalInsightsWorkspace \
    -ResourceGroupName "myRG" \
    -Name "mylogworkspace" \
    -Location "East US" \
    -Sku "PerGB2018"
```

### Enable Monitoring for Resources:

#### Enable Diagnostic Settings:
```bash
# Enable diagnostic settings for storage account
az monitor diagnostic-settings create \
    --name mystoragesettings \
    --resource /subscriptions/.../storageAccounts/mystorageaccount \
    --workspace /subscriptions/.../workspaces/mylogworkspace \
    --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true}]' \
    --metrics '[{"category":"Transaction","enabled":true}]'
```

## Alerts in Azure Monitor

### What are Alerts?

Alerts proactively notify you when important conditions are found in your monitoring data. They allow you to identify and address issues before users notice them.

### Types of Alerts:

#### 1. Metric Alerts
- **Based on**: Numeric metric values
- **Evaluation**: Real-time monitoring
- **Use case**: CPU usage, memory consumption, response time

#### 2. Log Alerts
- **Based on**: Log Analytics queries
- **Evaluation**: Scheduled intervals
- **Use case**: Error patterns, security events, custom queries

#### 3. Activity Log Alerts
- **Based on**: Azure Activity Log events
- **Evaluation**: Real-time
- **Use case**: Resource changes, service health events

#### 4. Smart Detection Alerts
- **Based on**: Machine learning algorithms
- **Evaluation**: Automatic anomaly detection
- **Use case**: Application Insights anomalies

## Creating Alerts

### Metric Alert Example:

#### Azure CLI:
```bash
# Create metric alert for CPU usage
az monitor metrics alert create \
    --name "High CPU Alert" \
    --resource-group myRG \
    --scopes /subscriptions/.../virtualMachines/myvm \
    --condition "avg Percentage CPU > 80" \
    --description "Alert when CPU exceeds 80%" \
    --evaluation-frequency 1m \
    --window-size 5m \
    --severity 2 \
    --action-group /subscriptions/.../actionGroups/myactiongroup
```

#### PowerShell:
```powershell
# Create metric alert
$criteria = New-AzMetricAlertRuleV2Criteria \
    -MetricName "Percentage CPU" \
    -TimeAggregation Average \
    -Operator GreaterThan \
    -Threshold 80

Add-AzMetricAlertRuleV2 \
    -Name "High CPU Alert" \
    -ResourceGroupName "myRG" \
    -WindowSize 00:05:00 \
    -Frequency 00:01:00 \
    -TargetResourceId "/subscriptions/.../virtualMachines/myvm" \
    -Condition $criteria \
    -ActionGroupId "/subscriptions/.../actionGroups/myactiongroup" \
    -Severity 2
```

### Log Alert Example:

#### KQL Query for Log Alert:
```kusto
// Query for failed requests
requests
| where success == false
| where timestamp > ago(5m)
| summarize count() by bin(timestamp, 1m)
| where count_ > 10
```

#### Create Log Alert:
```bash
# Create log alert
az monitor scheduled-query create \
    --name "Failed Requests Alert" \
    --resource-group myRG \
    --scopes /subscriptions/.../components/myappinsights \
    --condition "count > 10" \
    --condition-query "requests | where success == false | where timestamp > ago(5m) | summarize count() by bin(timestamp, 1m)" \
    --description "Alert when failed requests exceed 10 per minute" \
    --evaluation-frequency 1m \
    --window-size 5m \
    --severity 1 \
    --action-group /subscriptions/.../actionGroups/myactiongroup
```

### Activity Log Alert:

#### Create Activity Log Alert:
```bash
# Create activity log alert for VM deletion
az monitor activity-log alert create \
    --name "VM Deletion Alert" \
    --resource-group myRG \
    --scope /subscriptions/subscription-id \
    --condition category=Administrative \
    --condition operationName=Microsoft.Compute/virtualMachines/delete \
    --description "Alert when VM is deleted" \
    --action-group /subscriptions/.../actionGroups/myactiongroup
```

## Activity Logs

### What are Activity Logs?

Activity logs provide insight into subscription-level events that occurred in Azure, including when resources are created, modified, or deleted.

### Activity Log Categories:
- **Administrative**: Resource management operations
- **Service Health**: Service health incidents
- **Resource Health**: Resource health events
- **Alert**: Alert activations
- **Autoscale**: Autoscale operations
- **Security**: Security Center alerts

### Accessing Activity Logs:

#### Azure CLI:
```bash
# Get activity logs
az monitor activity-log list \
    --resource-group myRG \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z

# Filter by operation
az monitor activity-log list \
    --resource-group myRG \
    --caller admin@contoso.com \
    --status Succeeded
```

#### PowerShell:
```powershell
# Get activity logs
Get-AzLog \
    -ResourceGroupName "myRG" \
    -StartTime (Get-Date).AddDays(-1) \
    -EndTime (Get-Date)

# Filter by resource
Get-AzLog \
    -ResourceId "/subscriptions/.../virtualMachines/myvm" \
    -StartTime (Get-Date).AddHours(-24)
```

### Export Activity Logs:

#### Create Diagnostic Setting for Activity Logs:
```bash
# Export activity logs to Log Analytics
az monitor diagnostic-settings subscription create \
    --name activitylogsettings \
    --location eastus \
    --workspace /subscriptions/.../workspaces/mylogworkspace \
    --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true}]'
```

### Query Activity Logs in Log Analytics:
```kusto
// Query administrative operations
AzureActivity
| where CategoryValue == "Administrative"
| where TimeGenerated > ago(24h)
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup
| order by TimeGenerated desc
```

## Alert Rules

### Alert Rule Components:

#### 1. Target Resource
- **Scope**: Resources to monitor
- **Resource type**: VM, Storage Account, App Service, etc.

#### 2. Condition
- **Signal**: Metric, log query, or activity log event
- **Logic**: Threshold, aggregation, frequency
- **Evaluation**: How often to check the condition

#### 3. Actions
- **Action Groups**: Define what happens when alert fires
- **Notifications**: Email, SMS, push notifications
- **Actions**: Webhooks, Logic Apps, Azure Functions

### Creating Action Groups:

#### Azure CLI:
```bash
# Create action group
az monitor action-group create \
    --name myactiongroup \
    --resource-group myRG \
    --short-name myag \
    --email-receiver name=admin email=admin@contoso.com \
    --sms-receiver name=oncall country-code=1 phone-number=5551234567 \
    --webhook-receiver name=webhook service-uri=https://example.com/webhook
```

#### PowerShell:
```powershell
# Create email receiver
$emailReceiver = New-AzActionGroupReceiver \
    -Name "admin" \
    -EmailReceiver \
    -EmailAddress "admin@contoso.com"

# Create action group
Set-AzActionGroup \
    -Name "myactiongroup" \
    -ResourceGroupName "myRG" \
    -ShortName "myag" \
    -Receiver $emailReceiver
```

### Complex Alert Rule Example:

#### Multi-condition Metric Alert:
```bash
# Create alert with multiple conditions
az monitor metrics alert create \
    --name "Complex VM Alert" \
    --resource-group myRG \
    --scopes /subscriptions/.../virtualMachines/myvm \
    --condition "avg Percentage CPU > 80" \
    --condition "avg Available Memory Bytes < 1000000000" \
    --description "Alert when CPU > 80% AND Memory < 1GB" \
    --evaluation-frequency 1m \
    --window-size 5m \
    --severity 1 \
    --action-group /subscriptions/.../actionGroups/myactiongroup
```

### Dynamic Thresholds:

#### Create Alert with Dynamic Threshold:
```bash
# Create dynamic threshold alert
az monitor metrics alert create \
    --name "Dynamic CPU Alert" \
    --resource-group myRG \
    --scopes /subscriptions/.../virtualMachines/myvm \
    --condition "avg Percentage CPU > dynamic medium 2 of 4" \
    --description "Alert using dynamic threshold" \
    --evaluation-frequency 1m \
    --window-size 5m \
    --action-group /subscriptions/.../actionGroups/myactiongroup
```

## Suppressing Alerts

### What is Alert Suppression?

Alert suppression prevents alerts from firing during planned maintenance, known issues, or when alerts are not actionable.

### Methods of Alert Suppression:

#### 1. Disable Alert Rule
```bash
# Disable alert rule
az monitor metrics alert update \
    --name "High CPU Alert" \
    --resource-group myRG \
    --enabled false

# Re-enable alert rule
az monitor metrics alert update \
    --name "High CPU Alert" \
    --resource-group myRG \
    --enabled true
```

#### 2. Action Rule Suppression

##### Create Suppression Rule:
```bash
# Create action rule for suppression
az monitor action-rule create \
    --name maintenancesuppression \
    --resource-group myRG \
    --location eastus \
    --status Enabled \
    --type Suppression \
    --scope /subscriptions/.../resourceGroups/myRG \
    --suppression-type Always \
    --description "Suppress alerts during maintenance"
```

##### Time-based Suppression:
```bash
# Create scheduled suppression
az monitor action-rule create \
    --name scheduledsuppression \
    --resource-group myRG \
    --location eastus \
    --status Enabled \
    --type Suppression \
    --scope /subscriptions/.../resourceGroups/myRG \
    --suppression-type Daily \
    --suppression-start-date 2024-01-15 \
    --suppression-end-date 2024-01-16 \
    --suppression-start-time 02:00:00 \
    --suppression-end-time 06:00:00 \
    --description "Suppress alerts during daily maintenance window"
```

#### 3. Conditional Suppression

##### PowerShell Example:
```powershell
# Create action rule with conditions
$scope = "/subscriptions/.../resourceGroups/myRG"
$condition = New-AzActionRuleCondition -Field "AlertRuleName" -Operator "Contains" -Value "CPU"

New-AzActionRule \
    -Name "CPUAlertSuppression" \
    -ResourceGroupName "myRG" \
    -Location "East US" \
    -Status "Enabled" \
    -Type "Suppression" \
    -Scope $scope \
    -Condition $condition \
    -SuppressionType "Always"
```

### Managing Alert Suppression:

#### List Action Rules:
```bash
# List all action rules
az monitor action-rule list --resource-group myRG

# Show specific action rule
az monitor action-rule show \
    --name maintenancesuppression \
    --resource-group myRG
```

#### Update Suppression Rule:
```bash
# Update action rule
az monitor action-rule update \
    --name maintenancesuppression \
    --resource-group myRG \
    --status Disabled
```

#### Delete Suppression Rule:
```bash
# Delete action rule
az monitor action-rule delete \
    --name maintenancesuppression \
    --resource-group myRG
```

## Advanced Alert Features

### Alert Processing Rules:

#### Create Processing Rule:
```json
{
  "properties": {
    "scopes": ["/subscriptions/.../resourceGroups/myRG"],
    "conditions": [
      {
        "field": "AlertRuleName",
        "operator": "Contains",
        "values": ["CPU"]
      }
    ],
    "actions": [
      {
        "actionType": "AddActionGroups",
        "actionGroupIds": ["/subscriptions/.../actionGroups/escalationgroup"]
      }
    ],
    "enabled": true,
    "description": "Add escalation group to CPU alerts"
  }
}
```

### Smart Groups:

Smart Groups automatically group related alerts using machine learning algorithms to reduce alert noise and improve incident management.

#### Features:
- **Automatic grouping** of related alerts
- **Correlation** across resources and time
- **Unified management** of grouped alerts
- **Reduced noise** in alert notifications

## Monitoring Best Practices

### Alert Design:
1. **Define clear thresholds** based on business impact
2. **Use appropriate severity levels** (0-4)
3. **Implement escalation paths** with action groups
4. **Test alert rules** before production deployment
5. **Regular review** and tuning of alert rules

### Alert Management:
1. **Use action rules** for systematic suppression
2. **Implement maintenance windows** for planned activities
3. **Monitor alert volume** and adjust thresholds
4. **Document alert procedures** and runbooks
5. **Regular cleanup** of obsolete alerts

### Performance Optimization:
1. **Optimize query performance** for log alerts
2. **Use appropriate evaluation frequency** to balance responsiveness and cost
3. **Leverage dynamic thresholds** for adaptive monitoring
4. **Implement smart detection** for anomaly detection

## Common Alert Scenarios

### Infrastructure Monitoring:
```bash
# VM availability alert
az monitor metrics alert create \
    --name "VM Availability" \
    --resource-group myRG \
    --scopes /subscriptions/.../virtualMachines/myvm \
    --condition "avg VmAvailabilityMetric < 1" \
    --evaluation-frequency 1m \
    --window-size 5m \
    --severity 0

# Storage account availability
az monitor metrics alert create \
    --name "Storage Availability" \
    --resource-group myRG \
    --scopes /subscriptions/.../storageAccounts/mystorageaccount \
    --condition "avg Availability < 99.9" \
    --evaluation-frequency 5m \
    --window-size 15m \
    --severity 1
```

### Application Monitoring:
```bash
# Application response time
az monitor scheduled-query create \
    --name "Slow Response Time" \
    --resource-group myRG \
    --scopes /subscriptions/.../components/myappinsights \
    --condition "avg(duration) > 5000" \
    --condition-query "requests | where timestamp > ago(5m) | summarize avg(duration)" \
    --evaluation-frequency 1m \
    --window-size 5m \
    --severity 2
```

### Security Monitoring:
```bash
# Failed login attempts
az monitor activity-log alert create \
    --name "Failed Login Alert" \
    --resource-group myRG \
    --scope /subscriptions/subscription-id \
    --condition category=Security \
    --condition operationName=Microsoft.Authorization/policies/audit/action \
    --action-group /subscriptions/.../actionGroups/securityteam
```
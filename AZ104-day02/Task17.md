# Azure Network Watcher: Complete Network Monitoring and Diagnostics

This guide covers Azure Network Watcher and its comprehensive features for network monitoring, diagnostics, and troubleshooting.

## Understanding Azure Network Watcher

### Azure Network Watcher
- **Definition**: Regional service providing network monitoring, diagnostic, and analytics tools
- **Purpose**: Monitor, diagnose, and gain insights into network performance and health
- **Scope**: Works across IaaS resources including VMs, VNets, Application Gateways, Load Balancers
- **Integration**: Built-in Azure service with portal, CLI, PowerShell, and REST API support

### Key Capabilities
- **Network Topology**: Visual representation of network resources and connections
- **Connection Monitor**: Continuous monitoring of connectivity between resources
- **IP Flow Verify**: Test if traffic is allowed or denied to/from a VM
- **Next Hop**: Determine the next hop for traffic from a VM
- **Security Group View**: View effective security rules for a VM
- **VPN Diagnostics**: Troubleshoot VPN Gateway connections
- **NSG Flow Logs**: Capture information about IP traffic flowing through NSGs
- **Traffic Analytics**: Analyze NSG flow logs for insights and patterns

### Network Watcher Features Overview

| Feature | Purpose | Use Case |
|---------|---------|----------|
| Topology | Network visualization | Architecture documentation |
| Connection Monitor | Connectivity monitoring | Proactive monitoring |
| IP Flow Verify | Traffic rule testing | Security troubleshooting |
| Next Hop | Routing analysis | Route troubleshooting |
| Security Group View | Effective rules display | Security audit |
| Packet Capture | Network traffic analysis | Deep troubleshooting |
| VPN Diagnostics | VPN troubleshooting | Connectivity issues |
| NSG Flow Logs | Traffic logging | Compliance and analysis |
| Traffic Analytics | Flow log analysis | Network insights |

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Virtual networks and VMs for testing
- Network Watcher enabled in target regions

---

## Setting Up Network Watcher

### 1. Enable Network Watcher

#### Azure CLI
```bash
# Create resource group
az group create \
  --name sa1_test_eic_SudarshanDarade \
  --location southeastasia

# Enable Network Watcher in region
az network watcher configure \
  --resource-group sa1_test_eic_SudarshanDarade \
  --locations southeastasia \
  --enabled true

# Verify Network Watcher status
az network watcher list \
  --output table
```

#### Azure Portal
1. **Navigate to Network Watcher**:
   - Search for "Network Watcher" in Azure portal
   - Select "Network Watcher" service

2. **Enable Network Watcher**:
   - Click "Overview" in left menu
   - Select your subscription
   - Find "Southeast Asia" region
   - Click "Enable" if not already enabled

3. **Verify Status**:
   - Check that status shows "Enabled" for the region

### 2. Create Test Environment

```bash
# Create virtual network
az network vnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vnet-test \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Create additional subnet
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-test \
  --name subnet-app \
  --address-prefix 10.0.2.0/24

# Create NSG
az network nsg create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name nsg-test \
  --location southeastasia

# Create test VMs
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-web \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-test \
  --subnet subnet-web \
  --nsg nsg-test \
  --size Standard_B1s

az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-app \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --vnet-name vnet-test \
  --subnet subnet-app \
  --nsg nsg-test \
  --size Standard_B1s
```

---

## Network Topology

### 1. View Network Topology

#### Azure CLI
```bash
# Get network topology
az network watcher show-topology \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output json > network-topology.json

# View topology in table format
az network watcher show-topology \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "resources[].{Name:name, Type:type, Location:location}" \
  --output table
```

#### Azure Portal
1. **Access Topology**:
   - Go to Network Watcher → Monitoring → Topology
   - Select subscription and resource group
   - Choose "sa1_test_eic_SudarshanDarade"

2. **View Network Diagram**:
   - Interactive visual representation appears
   - Click on resources for details
   - Use zoom and pan controls
   - Export diagram as needed

### 2. Topology Visualization

```bash
# Get detailed topology with relationships
az network watcher show-topology \
  --resource-group sa1_test_eic_SudarshanDarade \
  --query "resources[].{Name:name, Type:type, Associations:associations[].name}" \
  --output table
```

---

## IP Flow Verify

### 1. Test Traffic Flow

#### Azure CLI
```bash
# Test inbound traffic to VM
az network watcher test-ip-flow \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --direction Inbound \
  --protocol TCP \
  --local 10.0.1.4:80 \
  --remote 203.0.113.1:12345

# Test outbound traffic from VM
az network watcher test-ip-flow \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --direction Outbound \
  --protocol TCP \
  --local 10.0.1.4:443 \
  --remote 8.8.8.8:443

# Test inter-subnet communication
az network watcher test-ip-flow \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --direction Outbound \
  --protocol TCP \
  --local 10.0.1.4:22 \
  --remote 10.0.2.4:22
```

#### Azure Portal
1. **Access IP Flow Verify**:
   - Go to Network Watcher → Network diagnostic tools → IP flow verify

2. **Configure Test Parameters**:
   - **Subscription**: Select your subscription
   - **Resource group**: sa1_test_eic_SudarshanDarade
   - **Virtual machine**: vm-web
   - **Network interface**: vm-webVMNic
   - **Protocol**: TCP/UDP
   - **Direction**: Inbound/Outbound
   - **Local IP address**: 10.0.1.4
   - **Local port**: 80
   - **Remote IP address**: 203.0.113.1
   - **Remote port**: 12345

3. **Run Test**:
   - Click "Check" button
   - Review results showing Allow/Deny with rule name

### 2. Batch IP Flow Testing

```bash
# Test multiple scenarios
SCENARIOS=(
  "Inbound TCP 10.0.1.4:80 203.0.113.1:12345"
  "Inbound TCP 10.0.1.4:443 203.0.113.1:12345"
  "Inbound TCP 10.0.1.4:22 203.0.113.1:12345"
  "Outbound TCP 10.0.1.4:443 8.8.8.8:443"
  "Outbound UDP 10.0.1.4:53 8.8.8.8:53"
)

for scenario in "${SCENARIOS[@]}"; do
  read direction protocol local remote <<< "$scenario"
  echo "Testing: $scenario"
  az network watcher test-ip-flow \
    --resource-group sa1_test_eic_SudarshanDarade \
    --vm vm-web \
    --direction $direction \
    --protocol $protocol \
    --local $local \
    --remote $remote \
    --query "{Access:access, RuleName:ruleName}" \
    --output table
done
```

---

## Next Hop Analysis

### 1. Determine Next Hop

#### Azure CLI
```bash
# Check next hop for internet traffic
az network watcher show-next-hop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --source-ip 10.0.1.4 \
  --dest-ip 8.8.8.8

# Check next hop for internal traffic
az network watcher show-next-hop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --source-ip 10.0.1.4 \
  --dest-ip 10.0.2.4

# Check next hop for on-premises traffic (if VPN exists)
az network watcher show-next-hop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --source-ip 10.0.1.4 \
  --dest-ip 192.168.1.1
```

#### Azure Portal
1. **Access Next Hop**:
   - Go to Network Watcher → Network diagnostic tools → Next hop

2. **Configure Parameters**:
   - **Subscription**: Select your subscription
   - **Resource group**: sa1_test_eic_SudarshanDarade
   - **Virtual machine**: vm-web
   - **Network interface**: vm-webVMNic
   - **Source IP address**: 10.0.1.4
   - **Destination IP address**: 8.8.8.8

3. **Analyze Results**:
   - Click "Next hop" button
   - Review next hop type and IP address
   - Check route table ID if applicable

### 2. Route Analysis

```bash
# Get effective routes for VM
az network nic show-effective-route-table \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-webVMNic \
  --output table

# Analyze specific route
az network nic show-effective-route-table \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-webVMNic \
  --query "[?addressPrefix[0]=='0.0.0.0/0']" \
  --output table
```

---

## Security Group View

### 1. View Effective Security Rules

#### Azure CLI
```bash
# Get effective security rules for VM
az network nic list-effective-nsg \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-webVMNic

# View specific rule details
az network nic list-effective-nsg \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-webVMNic \
  --query "value[0].securityRules[?direction=='Inbound']" \
  --output table
```

#### Azure Portal
1. **Access Security Group View**:
   - Go to Network Watcher → Network diagnostic tools → Security group view

2. **Select Target**:
   - **Subscription**: Select your subscription
   - **Resource group**: sa1_test_eic_SudarshanDarade
   - **Virtual machine**: vm-web

3. **View Security Rules**:
   - Click "View" button
   - Review effective security rules
   - Check both inbound and outbound rules
   - See rule priorities and sources

### 2. Security Rule Analysis

```bash
# Analyze inbound rules
az network nic list-effective-nsg \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-webVMNic \
  --query "value[0].securityRules[?direction=='Inbound'].{Priority:priority, Name:name, Access:access, Protocol:protocol, SourcePort:sourcePortRange, DestPort:destinationPortRange}" \
  --output table

# Analyze outbound rules
az network nic list-effective-nsg \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-webVMNic \
  --query "value[0].securityRules[?direction=='Outbound'].{Priority:priority, Name:name, Access:access, Protocol:protocol, SourcePort:sourcePortRange, DestPort:destinationPortRange}" \
  --output table
```

---

## Connection Monitor

### 1. Create Connection Monitor

#### Azure CLI
```bash
# Create connection monitor between VMs
az network watcher connection-monitor create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name connection-monitor-web-app \
  --source-resource vm-web \
  --dest-resource vm-app \
  --dest-port 80 \
  --monitoring-interval 30

# Create connection monitor to external endpoint
az network watcher connection-monitor create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name connection-monitor-web-internet \
  --source-resource vm-web \
  --dest-address 8.8.8.8 \
  --dest-port 53 \
  --monitoring-interval 60
```

#### Azure Portal
1. **Create Connection Monitor**:
   - Go to Network Watcher → Monitoring → Connection monitor
   - Click "+ Create"

2. **Basic Configuration**:
   - **Name**: connection-monitor-web-app
   - **Subscription**: Select your subscription
   - **Region**: Southeast Asia
   - **Workspace configuration**: Create new or use existing

3. **Add Test Group**:
   - Click "Add test group"
   - **Test group name**: web-to-app-test
   - **Sources**: Add vm-web
   - **Destinations**: Add vm-app or external endpoint
   - **Test configurations**: HTTP/TCP/ICMP
   - **Protocol**: TCP, **Port**: 80
   - **Test frequency**: 30 seconds

4. **Review and Create**:
   - Review configuration
   - Click "Create"

### 2. Monitor Connection Status

```bash
# List connection monitors
az network watcher connection-monitor list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Get connection monitor status
az network watcher connection-monitor show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name connection-monitor-web-app

# Query connection monitor results
az network watcher connection-monitor query \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name connection-monitor-web-app
```

### 3. Advanced Connection Monitoring

```bash
# Create multi-endpoint connection monitor
cat > connection-monitor-config.json << 'EOF'
{
  "endpoints": [
    {
      "name": "vm-web-endpoint",
      "resourceId": "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/virtualMachines/vm-web"
    },
    {
      "name": "vm-app-endpoint", 
      "resourceId": "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/virtualMachines/vm-app"
    },
    {
      "name": "external-endpoint",
      "address": "www.google.com"
    }
  ],
  "testConfigurations": [
    {
      "name": "http-test",
      "protocol": "Http",
      "httpConfiguration": {
        "port": 80,
        "method": "Get",
        "path": "/",
        "requestHeaders": [],
        "validStatusCodeRanges": ["200-299"]
      },
      "testFrequencySec": 30
    }
  ],
  "testGroups": [
    {
      "name": "web-to-app-test",
      "sources": ["vm-web-endpoint"],
      "destinations": ["vm-app-endpoint"],
      "testConfigurations": ["http-test"]
    }
  ]
}
EOF

# Create advanced connection monitor
az network watcher connection-monitor create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name advanced-connection-monitor \
  --config-file connection-monitor-config.json
```

---

## Packet Capture

### 1. Create Packet Capture

#### Azure CLI
```bash
# Create storage account for packet capture
az storage account create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name stpacketcapture$(date +%s) \
  --sku Standard_LRS \
  --location southeastasia

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --account-name stpacketcapture* \
  --query "[0].value" -o tsv)

# Create packet capture
az network watcher packet-capture create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --name packet-capture-web \
  --storage-account stpacketcapture* \
  --storage-path https://stpacketcapture*.blob.core.windows.net/captures \
  --time-limit 300 \
  --bytes-to-capture-per-packet 0 \
  --total-bytes-per-session 1073741824
```

#### Azure Portal
1. **Start Packet Capture**:
   - Go to Network Watcher → Network diagnostic tools → Packet capture
   - Click "+ Add"

2. **Configure Capture**:
   - **Subscription**: Select your subscription
   - **Resource group**: sa1_test_eic_SudarshanDarade
   - **Target virtual machine**: vm-web
   - **Packet capture name**: packet-capture-web
   - **Capture location**: Storage account
   - **Storage account**: Select or create storage account
   - **Maximum bytes per packet**: 0 (unlimited)
   - **Maximum bytes per session**: 1073741824 (1GB)
   - **Time limit**: 300 seconds

3. **Add Filters** (Optional):
   - **Protocol**: TCP/UDP/Any
   - **Local IP address**: 10.0.1.4
   - **Local port**: 80
   - **Remote IP address**: Any
   - **Remote port**: Any

4. **Start Capture**:
   - Click "OK" to start
   - Monitor status in packet capture list

### 2. Packet Capture with Filters

```bash
# Create packet capture with filters
az network watcher packet-capture create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --name packet-capture-filtered \
  --storage-account stpacketcapture* \
  --storage-path https://stpacketcapture*.blob.core.windows.net/captures \
  --filters '[
    {
      "protocol": "TCP",
      "localIPAddress": "10.0.1.4",
      "localPort": "80",
      "remoteIPAddress": "*",
      "remotePort": "*"
    }
  ]' \
  --time-limit 600
```

### 3. Manage Packet Captures

```bash
# List packet captures
az network watcher packet-capture list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Get packet capture status
az network watcher packet-capture show-status \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --name packet-capture-web

# Stop packet capture
az network watcher packet-capture stop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --name packet-capture-web

# Delete packet capture
az network watcher packet-capture delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --name packet-capture-web
```

---

## NSG Flow Logs

### 1. Enable NSG Flow Logs

#### Azure CLI
```bash
# Create storage account for flow logs
az storage account create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name stflowlogs$(date +%s) \
  --sku Standard_LRS \
  --location southeastasia

# Enable NSG flow logs
az network watcher flow-log create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test \
  --nsg nsg-test \
  --storage-account stflowlogs* \
  --enabled true \
  --retention 30 \
  --format JSON \
  --log-version 2
```

#### Azure Portal
1. **Access NSG Flow Logs**:
   - Go to Network Watcher → Logs → Flow logs
   - Click "+ Create"

2. **Select NSG**:
   - **Subscription**: Select your subscription
   - **Resource group**: sa1_test_eic_SudarshanDarade
   - **Network security group**: nsg-test
   - Click "Next: Configuration"

3. **Configure Flow Logs**:
   - **Flow logs status**: Enabled
   - **Flow logs version**: Version 2
   - **Storage account**: Select or create storage account
   - **Retention (days)**: 30
   - **Traffic Analytics status**: Enabled (optional)
   - **Log Analytics workspace**: Select workspace
   - **Traffic Analytics processing interval**: 10 minutes

4. **Review and Create**:
   - Review settings
   - Click "Create"

### 2. Configure Advanced Flow Logs

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --workspace-name network-analytics \
  --location southeastasia

# Enable flow logs with Traffic Analytics
az network watcher flow-log create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-advanced \
  --nsg nsg-test \
  --storage-account stflowlogs* \
  --enabled true \
  --retention 90 \
  --format JSON \
  --log-version 2 \
  --traffic-analytics true \
  --workspace /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/network-analytics
```

### 3. Manage Flow Logs

```bash
# List flow logs
az network watcher flow-log list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Show flow log configuration
az network watcher flow-log show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test

# Update flow log settings
az network watcher flow-log update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test \
  --retention 60 \
  --enabled true

# Disable flow logs
az network watcher flow-log update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test \
  --enabled false
```

---

## VPN Diagnostics

### 1. Create VPN Gateway for Testing

```bash
# Create gateway subnet
az network vnet subnet create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vnet-name vnet-test \
  --name GatewaySubnet \
  --address-prefix 10.0.100.0/27

# Create public IP for VPN gateway
az network public-ip create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name pip-vpn-gateway \
  --sku Standard \
  --allocation-method Static

# Create VPN gateway
az network vnet-gateway create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vpn-gateway-test \
  --public-ip-address pip-vpn-gateway \
  --vnet vnet-test \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku VpnGw1 \
  --no-wait
```

### 2. VPN Diagnostics

```bash
# Start VPN diagnostics
az network vnet-gateway vpn-connection packet-capture start \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vpn-connection-test

# Get VPN gateway diagnostics
az network vnet-gateway show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vpn-gateway-test \
  --query "{Name:name, ProvisioningState:provisioningState, GatewayType:gatewayType}"

# Check VPN connection status
az network vpn-connection show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vpn-connection-test \
  --query "{Name:name, ConnectionStatus:connectionStatus, ProvisioningState:provisioningState}"
```

---

## Traffic Analytics

### 1. Configure Traffic Analytics

```bash
# Enable Traffic Analytics on existing flow log
az network watcher flow-log update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test \
  --traffic-analytics true \
  --workspace /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.OperationalInsights/workspaces/network-analytics \
  --interval 10
```

### 2. Query Traffic Analytics Data

```bash
# Sample KQL queries for Traffic Analytics
cat > traffic-analytics-queries.kql << 'EOF'
// Top talkers by bytes
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| summarize TotalBytes = sum(OutboundBytes_d + InboundBytes_d) by SrcIP_s
| top 10 by TotalBytes desc

// Traffic by protocol
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| summarize Count = count() by L4Protocol_s
| render piechart

// Denied flows
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog" and FlowStatus_s == "D"
| summarize Count = count() by SrcIP_s, DestIP_s, DestPort_d
| top 20 by Count desc

// Geographic traffic distribution
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| summarize Flows = count() by Country_s
| render columnchart
EOF
```

---

## Connectivity Troubleshooting

### 1. Test Connectivity

#### Azure CLI
```bash
# Test connectivity between VMs
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource vm-web \
  --dest-resource vm-app \
  --dest-port 80

# Test connectivity to external endpoint
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource vm-web \
  --dest-address www.google.com \
  --dest-port 443

# Test connectivity with protocol specification
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource vm-web \
  --dest-address 8.8.8.8 \
  --dest-port 53 \
  --protocol UDP
```

#### Azure Portal
1. **Access Connection Troubleshoot**:
   - Go to Network Watcher → Network diagnostic tools → Connection troubleshoot

2. **Configure Source**:
   - **Subscription**: Select your subscription
   - **Resource group**: sa1_test_eic_SudarshanDarade
   - **Source type**: Virtual machine
   - **Virtual machine**: vm-web

3. **Configure Destination**:
   - **Destination type**: Virtual machine / URI / IP address
   - **Virtual machine**: vm-app (or specify IP/URI)
   - **Protocol**: TCP/UDP/ICMP
   - **Destination port**: 80

4. **Run Test**:
   - Click "Check" button
   - Review connectivity results
   - Analyze hop-by-hop details
   - Check for issues and recommendations

### 2. Troubleshoot Connectivity Issues

```bash
# Comprehensive connectivity test
az network watcher test-connectivity \
  --resource-group sa1_test_eic_SudarshanDarade \
  --source-resource vm-web \
  --dest-resource vm-app \
  --dest-port 22 \
  --query "{ConnectionStatus:connectionStatus, AvgLatencyInMs:avgLatencyInMs, Hops:hops[].{Address:address, Type:type, Issues:issues}}" \
  --output json
```

---

## Network Performance Monitoring

### 1. Performance Metrics

```bash
# Get network performance metrics
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/networkInterfaces/vm-webVMNic \
  --metric "BytesReceivedRate" "BytesSentRate" \
  --interval PT1M \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z

# Monitor connection success rate
az monitor metrics list \
  --resource /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/connectionMonitors/connection-monitor-web-app \
  --metric "ProbesFailedPercent" \
  --interval PT5M
```

### 2. Network Latency Analysis

```bash
# Create latency monitoring
az network watcher connection-monitor create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name latency-monitor \
  --source-resource vm-web \
  --dest-address 8.8.8.8 \
  --dest-port 53 \
  --monitoring-interval 30 \
  --protocol Icmp
```

---

## Automation and Scripting

### 1. Automated Network Health Check

```bash
#!/bin/bash
# Network health check script

RESOURCE_GROUP="sa1_test_eic_SudarshanDarade"
VM_NAME="vm-web"

echo "=== Network Health Check Report ==="
echo "Date: $(date)"
echo "Resource Group: $RESOURCE_GROUP"
echo "VM: $VM_NAME"
echo

# Check VM status
echo "1. VM Status:"
az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --query "powerState" -o tsv
echo

# Test internet connectivity
echo "2. Internet Connectivity:"
az network watcher test-connectivity \
  --resource-group $RESOURCE_GROUP \
  --source-resource $VM_NAME \
  --dest-address 8.8.8.8 \
  --dest-port 53 \
  --query "connectionStatus" -o tsv
echo

# Check effective security rules
echo "3. Security Rules Summary:"
az network nic list-effective-nsg \
  --resource-group $RESOURCE_GROUP \
  --name ${VM_NAME}VMNic \
  --query "value[0].securityRules[?access=='Allow' && direction=='Inbound'].{Priority:priority, Port:destinationPortRange}" \
  --output table
echo

# Check next hop for internet traffic
echo "4. Internet Route:"
VM_IP=$(az vm show -d --resource-group $RESOURCE_GROUP --name $VM_NAME --query privateIps -o tsv)
az network watcher show-next-hop \
  --resource-group $RESOURCE_GROUP \
  --vm $VM_NAME \
  --source-ip $VM_IP \
  --dest-ip 8.8.8.8 \
  --query "{NextHopType:nextHopType, NextHopIpAddress:nextHopIpAddress}" \
  --output table
```

### 2. Flow Log Analysis Script

```bash
#!/bin/bash
# Flow log analysis script

STORAGE_ACCOUNT="stflowlogs*"
RESOURCE_GROUP="sa1_test_eic_SudarshanDarade"

# Download recent flow logs
az storage blob download-batch \
  --destination ./flow-logs \
  --source insights-logs-networksecuritygroupflowevent \
  --account-name $STORAGE_ACCOUNT \
  --pattern "*/PT1H.json"

# Analyze flow logs (requires jq)
echo "Top source IPs by connection count:"
find ./flow-logs -name "*.json" -exec cat {} \; | \
  jq -r '.records[].properties.flows[].flows[].flowTuples[]' | \
  cut -d',' -f3 | sort | uniq -c | sort -nr | head -10
```

---

## Best Practices

### 1. Monitoring Strategy

```bash
# Set up comprehensive monitoring
# 1. Enable flow logs for all critical NSGs
# 2. Configure Traffic Analytics for insights
# 3. Set up connection monitors for critical paths
# 4. Create alerts for connectivity failures

# Example alert creation
az monitor metrics alert create \
  --name "Connection Monitor Alert" \
  --resource-group sa1_test_eic_SudarshanDarade \
  --scopes /subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Network/connectionMonitors/connection-monitor-web-app \
  --condition "avg ProbesFailedPercent > 10" \
  --description "Alert when connection success rate drops below 90%" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 2
```

### 2. Cost Optimization

```bash
# Optimize Network Watcher costs
# 1. Set appropriate retention periods for flow logs
# 2. Use sampling for high-volume environments
# 3. Clean up unused packet captures
# 4. Monitor storage costs for flow logs

# Update flow log retention
az network watcher flow-log update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test \
  --retention 7  # Reduce retention for cost savings
```

---

## Troubleshooting Common Issues

### 1. Network Watcher Not Available

```bash
# Check Network Watcher availability
az network watcher list --query "[].{Name:name, Location:location, ProvisioningState:provisioningState}" --output table

# Enable Network Watcher if not available
az network watcher configure --locations southeastasia --enabled true
```

### 2. Flow Logs Not Working

```bash
# Verify flow log configuration
az network watcher flow-log show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test

# Check storage account permissions
az storage account show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name stflowlogs* \
  --query "{Name:name, ProvisioningState:provisioningState, AccessTier:accessTier}"
```

### 3. Connection Monitor Issues

```bash
# Check connection monitor status
az network watcher connection-monitor show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name connection-monitor-web-app \
  --query "{Name:name, ProvisioningState:provisioningState, MonitoringStatus:monitoringStatus}"

# Verify source VM has Network Watcher extension
az vm extension list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm-name vm-web \
  --query "[?name=='NetworkWatcherAgentLinux']" \
  --output table
```

---

## Cleanup

```bash
# Stop and delete connection monitors
az network watcher connection-monitor delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name connection-monitor-web-app

# Disable flow logs
az network watcher flow-log delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name flowlog-nsg-test

# Delete packet captures
az network watcher packet-capture delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --vm vm-web \
  --name packet-capture-web

# Delete resource group
az group delete \
  --name sa1_test_eic_SudarshanDarade \
  --yes --no-wait
```

---

## Summary

This guide covered:
- Understanding Azure Network Watcher and its comprehensive features
- Network topology visualization and documentation
- IP flow verification for security rule testing
- Next hop analysis for routing troubleshooting
- Security group view for effective rule analysis
- Connection monitoring for proactive network health
- Packet capture for deep network analysis
- NSG flow logs and Traffic Analytics for insights
- VPN diagnostics for hybrid connectivity
- Connectivity troubleshooting and performance monitoring
- Automation scripts and best practices
- Cost optimization and troubleshooting techniques

Azure Network Watcher provides essential tools for maintaining network health, security, and performance across Azure infrastructure with comprehensive monitoring and diagnostic capabilities.
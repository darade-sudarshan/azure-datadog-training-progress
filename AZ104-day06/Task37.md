# Task 37: Azure Bicep - Modern Infrastructure as Code

## Overview
Azure Bicep is a Domain Specific Language (DSL) that provides a more readable and maintainable way to define Azure infrastructure compared to ARM templates. Bicep compiles to ARM templates but offers simplified syntax, strong typing, and better developer experience.

## What is Azure Bicep?

Bicep provides:
- **Simplified syntax** - More concise than JSON ARM templates
- **Type safety** - Strong typing with IntelliSense support
- **Modularity** - Reusable modules for common patterns
- **Automatic dependency management** - No need to manually specify dependencies
- **Day-0 to Day-N support** - Manage entire resource lifecycle

## Method 1: Using Azure Portal (GUI)

### Access Bicep Templates via Portal

1. **Navigate to Template Deployment**
   - Go to Azure Portal → Search "Deploy a custom template"
   - Click **Deploy a custom template**
   - Choose **Build your own template in the editor**

2. **Upload Bicep Template**
   - Click **Load file** to upload .bicep file
   - Or paste Bicep code directly
   - Portal automatically converts to ARM template
   - Configure parameters in the GUI

3. **Deploy Template**
   - Fill in required parameters
   - Select subscription and resource group
   - Review and create deployment

## Bicep Data Types

### Basic Data Types

```bicep
// String parameters
@description('Storage account name')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'mystorageaccount'

@description('Azure region')
param location string = resourceGroup().location

// Integer parameters
@description('Number of VMs')
@minValue(1)
@maxValue(10)
param vmCount int = 2

@description('Disk size in GB')
@minValue(32)
@maxValue(1024)
param diskSizeGB int = 128

// Boolean parameters
@description('Enable backup')
param enableBackup bool = true

@description('Is production environment')
param isProduction bool = false

// Array parameters
@description('Allowed locations')
param allowedLocations array = [
  'eastus'
  'westus'
  'centralus'
]

@description('VM sizes')
param vmSizes array = [
  'Standard_B2s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
]

// Object parameters
@description('Network configuration')
param networkConfig object = {
  vnetName: 'myVNet'
  addressPrefix: '10.0.0.0/16'
  subnets: [
    {
      name: 'web-subnet'
      addressPrefix: '10.0.1.0/24'
    }
    {
      name: 'app-subnet'
      addressPrefix: '10.0.2.0/24'
    }
  ]
}

// Secure parameters
@description('Administrator password')
@secure()
param adminPassword string

@description('SQL connection string')
@secure()
param sqlConnectionString string
```

### Parameter Decorators

```bicep
// Description decorator
@description('The name of the storage account')
param storageAccountName string

// Allowed values
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

// String length constraints
@minLength(3)
@maxLength(24)
param accountName string

// Numeric constraints
@minValue(1)
@maxValue(100)
param instanceCount int = 2

// Secure parameter
@secure()
param adminPassword string

// Metadata decorator
@metadata({
  description: 'Environment for deployment'
  examples: ['dev', 'test', 'prod']
})
param environment string

// Multiple decorators
@description('VM size for the deployment')
@allowed([
  'Standard_B1s'
  'Standard_B2s'
  'Standard_D2s_v3'
])
param vmSize string = 'Standard_B2s'
```

## Bicep Functions

### String Functions

```bicep
// String manipulation
var vmName = concat('vm-', environment)
var resourceName = '${projectName}-${environment}-vm'
var upperCaseName = toUpper(storageAccountName)
var lowerCaseName = toLower(resourceGroupName)
var substringResult = substring(storageAccountName, 0, 10)
var replacedString = replace(templateString, 'old', 'new')

// String validation
var isValidEmail = contains(emailAddress, '@')
var startsWithPrefix = startsWith(resourceName, 'prod-')
var endsWithSuffix = endsWith(resourceName, '-vm')
var stringLength = length(storageAccountName)
var emptyString = empty(optionalParameter)

// String formatting
var formattedName = format('{0}-{1}-{2}', projectName, environment, 'vm')
var paddedString = padLeft('123', 5, '0') // Results in '00123'
var trimmedString = trim('  hello world  ')
```

### Array Functions

```bicep
// Array operations
var arrayLength = length(vmSizes)
var firstElement = first(allowedLocations)
var lastElement = last(allowedLocations)
var containsValue = contains(allowedLocations, 'eastus')
var emptyArray = empty(vmSizes)

// Array manipulation
var combinedArray = concat(array1, array2)
var uniqueValues = union(array1, array2)
var commonValues = intersection(array1, array2)
var arraySlice = skip(vmSizes, 1)
var arrayTake = take(vmSizes, 2)

// Array indexing
var firstVmSize = vmSizes[0]
var lastVmSize = vmSizes[length(vmSizes) - 1]
```

### Resource Functions

```bicep
// Resource references
var resourceGroupName = resourceGroup().name
var resourceGroupId = resourceGroup().id
var resourceGroupLocation = resourceGroup().location
var subscriptionId = subscription().subscriptionId
var tenantId = subscription().tenantId
var deploymentName = deployment().name

// Unique string generation
var uniqueString = uniqueString(resourceGroup().id)
var guidValue = guid(resourceGroup().id, deployment().name)

// Resource ID construction
var storageAccountId = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
```

### Logical Functions

```bicep
// Conditional expressions
var vmSize = environment == 'prod' ? 'Standard_D4s_v3' : 'Standard_B2s'
var storageType = isProduction ? 'Premium_LRS' : 'Standard_LRS'
var replicationCount = environment == 'prod' ? 3 : 1

// If function
var backupEnabled = if(environment == 'prod', true, false)
var monitoringLevel = if(isProduction, 'detailed', 'basic')

// Boolean operations
var shouldDeploy = enableBackup && isProduction
var canSkip = !enableBackup || environment == 'dev'

// Null coalescing
var defaultValue = coalesce(userInput, 'default-value')
var effectiveLocation = coalesce(location, resourceGroup().location)
```

### Numeric Functions

```bicep
// Math operations
var maxValue = max(10, 20, 30)
var minValue = min(10, 20, 30)
var addResult = add(5, 10)
var subResult = sub(20, 5)
var mulResult = mul(4, 5)
var divResult = div(20, 4)
var modResult = mod(10, 3)

// Conversion functions
var intValue = int('123')
var stringValue = string(123)
var boolValue = bool('true')

// Range function
var numberRange = range(0, vmCount)
```

### Date/Time Functions

```bicep
// Current timestamp
var currentTime = utcNow()
var formattedTime = utcNow('yyyy-MM-dd')
var timestampFormat = utcNow('yyyyMMddHHmmss')

// Date arithmetic
var futureDate = dateTimeAdd(utcNow(), 'P1D') // Add 1 day
var pastDate = dateTimeAdd(utcNow(), '-P7D') // Subtract 7 days
```

## Bicep Variables

```bicep
// Simple variables
var storageAccountName = '${projectName}${environment}${uniqueString(resourceGroup().id)}'
var vnetName = '${projectName}-${environment}-vnet'
var keyVaultName = '${projectName}-${environment}-kv'

// Resource tags
var tags = {
  Environment: environment
  Project: projectName
  CreatedBy: 'Bicep'
  CreatedDate: utcNow('yyyy-MM-dd')
  CostCenter: 'IT'
}

// Complex variables
var networkSecurityGroupRules = [
  {
    name: 'AllowHTTP'
    properties: {
      priority: 1000
      access: 'Allow'
      direction: 'Inbound'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'AllowHTTPS'
    properties: {
      priority: 1001
      access: 'Allow'
      direction: 'Inbound'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'AllowSSH'
    properties: {
      priority: 1002
      access: 'Allow'
      direction: 'Inbound'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
]

// Conditional variables
var vmSize = environment == 'prod' ? 'Standard_D4s_v3' : 'Standard_B2s'
var storageAccountType = isProduction ? 'Standard_GRS' : 'Standard_LRS'
var backupRetentionDays = environment == 'prod' ? 30 : 7

// Array variables
var subnets = [
  {
    name: 'web-subnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'app-subnet'
    addressPrefix: '10.0.2.0/24'
  }
  {
    name: 'db-subnet'
    addressPrefix: '10.0.3.0/24'
  }
]
```

## Bicep Resources

### Basic Resource Definitions

```bicep
// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  tags: tags
}

// Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
  tags: tags
}

// Network Security Group
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${projectName}-${environment}-nsg'
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
  tags: tags
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
  }
  tags: tags
}
```

### Resource Dependencies

```bicep
// Explicit dependency
resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
  tags: tags
}

// Implicit dependency (automatic)
resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id  // Implicit dependency
        }
      ]
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
  tags: tags
}
```

### Conditional Resources

```bicep
// Deploy only in production
resource backupVault 'Microsoft.RecoveryServices/vaults@2021-01-01' = if (environment == 'prod') {
  name: '${projectName}-backup-vault'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
  tags: tags
}

// Deploy based on parameter
resource applicationGateway 'Microsoft.Network/applicationGateways@2021-02-01' = if (enableApplicationGateway) {
  name: '${projectName}-appgw'
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
  tags: tags
}

// Conditional with complex logic
resource monitoring 'Microsoft.Insights/components@2020-02-02' = if (enableMonitoring && (environment == 'prod' || environment == 'test')) {
  name: '${projectName}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: tags
}
```

### Resource Loops

```bicep
// Simple loop with range
resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, vmCount): {
  name: '${vmName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: '${vmName}-${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
  tags: tags
}]

// Loop with array
resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in subnets: {
  name: '${subnet.name}-nsg'
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
  tags: tags
}]

// Loop with index
resource storageAccounts 'Microsoft.Storage/storageAccounts@2021-04-01' = [for (config, index) in storageConfigs: {
  name: '${config.name}${index}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: config.skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: config.accessTier
    supportsHttpsTrafficOnly: true
  }
  tags: union(tags, config.tags)
}]

// Conditional loop
resource prodVirtualMachines 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, vmCount): if (environment == 'prod') {
  name: '${vmName}-prod-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
  }
  tags: tags
}]
```

## Bicep Modules

### Creating a Storage Module (modules/storage.bicep)

```bicep
// Parameters
@description('Storage account name')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Storage account location')
param location string = resourceGroup().location

@description('Storage account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Access tier')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Resource tags')
param tags object = {}

@description('Enable HTTPS traffic only')
param httpsOnly bool = true

// Variables
var storageAccountNameCleaned = toLower(replace(storageAccountName, '-', ''))

// Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountNameCleaned
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: httpsOnly
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  tags: tags
}

// Blob service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
```

### Creating a Network Module (modules/network.bicep)

```bicep
// Parameters
@description('Virtual network name')
param vnetName string

@description('Location for resources')
param location string = resourceGroup().location

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet configurations')
param subnets array = [
  {
    name: 'web-subnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'app-subnet'
    addressPrefix: '10.0.2.0/24'
  }
]

@description('Resource tags')
param tags object = {}

// Resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
  tags: tags
}

// Outputs
output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
output subnetIds array = [for i in range(0, length(subnets)): virtualNetwork.properties.subnets[i].id]
output webSubnetId string = virtualNetwork.properties.subnets[0].id
output appSubnetId string = virtualNetwork.properties.subnets[1].id
```

### Creating a VM Module (modules/vm.bicep)

```bicep
// Parameters
@description('Virtual machine name')
param vmName string

@description('Location for resources')
param location string = resourceGroup().location

@description('VM size')
param vmSize string = 'Standard_B2s'

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('Subnet ID for VM')
param subnetId string

@description('Resource tags')
param tags object = {}

// Variables
var nicName = '${vmName}-nic'
var osDiskName = '${vmName}-osdisk'

// Resources
resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  tags: tags
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name: osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
  tags: tags
}

// Outputs
output vmId string = virtualMachine.id
output vmName string = virtualMachine.name
output privateIPAddress string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
```

### Using Modules in Main Template (main.bicep)

```bicep
// Parameters
@description('Project name prefix')
@minLength(2)
@maxLength(10)
param projectName string

@description('Environment name')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Administrator username')
param adminUsername string

@description('Administrator password')
@secure()
param adminPassword string

@description('Number of VMs to deploy')
@minValue(1)
@maxValue(5)
param vmCount int = 2

@description('Enable monitoring')
param enableMonitoring bool = false

// Variables
var tags = {
  Environment: environment
  Project: projectName
  CreatedBy: 'Bicep'
  CreatedDate: utcNow('yyyy-MM-dd')
}

var vmSize = environment == 'prod' ? 'Standard_D4s_v3' : 'Standard_B2s'
var storageAccountType = environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

// Storage Module
module storageModule 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    storageAccountName: '${projectName}${environment}${uniqueString(resourceGroup().id)}'
    location: location
    storageAccountType: storageAccountType
    accessTier: 'Hot'
    tags: tags
  }
}

// Network Module
module networkModule 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    vnetName: '${projectName}-${environment}-vnet'
    location: location
    vnetAddressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'web-subnet'
        addressPrefix: '10.0.1.0/24'
      }
      {
        name: 'app-subnet'
        addressPrefix: '10.0.2.0/24'
      }
      {
        name: 'db-subnet'
        addressPrefix: '10.0.3.0/24'
      }
    ]
    tags: tags
  }
}

// VM Modules
module vmModule 'modules/vm.bicep' = [for i in range(0, vmCount): {
  name: 'vm${i}Deployment'
  params: {
    vmName: '${projectName}-vm-${i}'
    location: location
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: networkModule.outputs.webSubnetId
    tags: tags
  }
}]

// Conditional monitoring module
module monitoringModule 'modules/monitoring.bicep' = if (enableMonitoring) {
  name: 'monitoringDeployment'
  params: {
    workspaceName: '${projectName}-${environment}-law'
    location: location
    tags: tags
  }
}

// Outputs
output resourceGroupName string = resourceGroup().name
output storageAccountName string = storageModule.outputs.storageAccountName
output vnetName string = networkModule.outputs.vnetName
output vmNames array = [for i in range(0, vmCount): vmModule[i].outputs.vmName]
output monitoringEnabled bool = enableMonitoring
```

### Module with Conditional Deployment

```bicep
// Deploy backup module only in production
module backupModule 'modules/backup.bicep' = if (environment == 'prod') {
  name: 'backupDeployment'
  params: {
    vaultName: '${projectName}-backup-vault'
    location: location
    tags: tags
  }
}

// Deploy multiple environments
module devModule 'modules/environment.bicep' = if (environment == 'dev') {
  name: 'devEnvironment'
  params: {
    environmentName: 'dev'
    vmSize: 'Standard_B2s'
    storageType: 'Standard_LRS'
  }
}

module prodModule 'modules/environment.bicep' = if (environment == 'prod') {
  name: 'prodEnvironment'
  params: {
    environmentName: 'prod'
    vmSize: 'Standard_D4s_v3'
    storageType: 'Standard_GRS'
  }
}
```

## Bicep Outputs

```bicep
// Simple outputs
output resourceGroupName string = resourceGroup().name
output storageAccountId string = storageAccount.id
output virtualNetworkName string = virtualNetwork.name
output deploymentTimestamp string = utcNow()

// Complex outputs
output networkConfiguration object = {
  vnetId: virtualNetwork.id
  vnetName: virtualNetwork.name
  addressSpace: virtualNetwork.properties.addressSpace.addressPrefixes[0]
  subnets: [for i in range(0, length(subnets)): {
    name: virtualNetwork.properties.subnets[i].name
    id: virtualNetwork.properties.subnets[i].id
    addressPrefix: virtualNetwork.properties.subnets[i].properties.addressPrefix
  }]
}

// Array outputs
output vmIds array = [for i in range(0, vmCount): virtualMachines[i].id]
output vmNames array = [for i in range(0, vmCount): virtualMachines[i].name]
output subnetIds array = [for i in range(0, length(subnets)): virtualNetwork.properties.subnets[i].id]

// Conditional outputs
output backupVaultId string = environment == 'prod' ? backupVault.id : ''
output monitoringWorkspaceId string = enableMonitoring ? monitoringModule.outputs.workspaceId : ''

// Module outputs
output storageEndpoint string = storageModule.outputs.primaryBlobEndpoint
output networkSubnets array = networkModule.outputs.subnetIds
output vmPrivateIPs array = [for i in range(0, vmCount): vmModule[i].outputs.privateIPAddress]
```

## Method 2: Using Azure CLI and PowerShell

### Deploy Bicep via Azure CLI

```bash
# Install Bicep
az bicep install

# Upgrade Bicep
az bicep upgrade

# Create resource group
az group create --name myResourceGroup --location "East US"

# Deploy Bicep template
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters projectName=myproject environment=dev adminUsername=azureuser

# Deploy with parameter file
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @main.parameters.json

# Validate Bicep template
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @main.parameters.json

# What-if deployment
az deployment group what-if \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @main.parameters.json

# Build Bicep to ARM template
az bicep build --file main.bicep

# Decompile ARM to Bicep
az bicep decompile --file template.json
```

### Deploy Bicep via PowerShell

```powershell
# Deploy Bicep template
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -projectName "myproject" `
  -environment "dev" `
  -adminUsername "azureuser"

# Deploy with parameter file
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "main.parameters.json"

# Test deployment
Test-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "main.parameters.json"

# What-if deployment
Get-AzResourceGroupDeploymentWhatIfResult `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "main.parameters.json"
```

## Parameter Files

### Bicep Parameter File (.bicepparam)

```bicep
using 'main.bicep'

param projectName = 'myproject'
param environment = 'dev'
param location = 'East US'
param adminUsername = 'azureuser'
param vmCount = 2
param enableMonitoring = false
```

### JSON Parameter File

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "projectName": {
      "value": "myproject"
    },
    "environment": {
      "value": "dev"
    },
    "location": {
      "value": "East US"
    },
    "adminUsername": {
      "value": "azureuser"
    },
    "vmCount": {
      "value": 2
    },
    "enableMonitoring": {
      "value": false
    }
  }
}
```

## Best Practices

### Code Organization
1. **Use modules** for reusable components
2. **Consistent naming** conventions with variables
3. **Parameter validation** with decorators
4. **Resource tagging** strategy
5. **Version control** for templates and modules

### Security
1. **Secure parameters** for sensitive data
2. **Key Vault references** for secrets
3. **Managed identities** for authentication
4. **Network security** configurations
5. **RBAC assignments** in templates

### Performance
1. **Parallel deployments** with modules
2. **Conditional deployment** for optional resources
3. **Resource dependencies** optimization
4. **Template modularity** for maintainability
5. **Deployment validation** before execution

## Troubleshooting

### Common Issues
1. **Syntax errors** - Use Bicep extension for VS Code
2. **Parameter validation** - Check decorator constraints
3. **Resource dependencies** - Verify implicit/explicit dependencies
4. **Module references** - Ensure correct module paths
5. **Naming conflicts** - Use unique naming patterns

### Debugging Techniques
1. **Template validation** - Use az deployment validate
2. **What-if analysis** - Preview changes before deployment
3. **Deployment logs** - Review operation details
4. **Incremental deployment** - Deploy modules separately
5. **Test environments** - Validate in non-production first

## Conclusion

Azure Bicep provides a modern, developer-friendly approach to Infrastructure as Code:

**Key Benefits:**
- **Simplified syntax** compared to ARM templates
- **Strong typing** and IntelliSense support
- **Automatic dependency management**
- **Native modularity** for reusable components
- **Seamless ARM template compilation**

**Best Use Cases:**
- **New infrastructure projects**
- **Modular architecture patterns**
- **Developer-focused teams**
- **Complex multi-environment deployments**
- **Infrastructure automation pipelines**

By mastering Bicep data types, functions, parameters, resources, and modules, you can create maintainable, scalable infrastructure deployments that support modern DevOps practices.

---

*This task provides comprehensive coverage of Azure Bicep including all data types, functions, parameters, resources, modules, and real-world implementation examples.*
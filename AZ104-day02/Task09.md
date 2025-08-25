# Azure VM Images: Generalized vs Specialized Images

This guide covers creating, managing, and deploying both generalized and specialized VM images in Azure.

## Understanding VM Image Types

### Generalized Images
- **Definition**: Images with system-specific information removed (SID, computer name, user accounts)
- **Sysprep Process**: Windows images are sysprepped, Linux images have machine-specific data removed
- **Reusability**: Can be used to create multiple unique VMs
- **Deployment**: Each VM gets unique identity and configuration
- **Use Cases**: Base images for scale sets, templates, multiple deployments
- **Azure Compute Gallery**: Supports versioning and replication

### Specialized Images
- **Definition**: Images that retain original VM's identity and configuration
- **No Sysprep**: Preserves computer name, user accounts, and system settings
- **Reusability**: Limited - creates VMs with identical configuration
- **Deployment**: VMs inherit original system identity
- **Use Cases**: Backup/restore, disaster recovery, exact system replication
- **Limitations**: Cannot be used in scale sets or shared galleries

### Comparison Table

| Feature | Generalized | Specialized |
|---------|-------------|-------------|
| System Identity | Removed | Preserved |
| Sysprep Required | Yes (Windows) | No |
| Multiple Deployments | Yes | Limited |
| Scale Sets Support | Yes | No |
| Shared Gallery | Yes | No |
| Use Case | Templates | Backup/Clone |

---

## Manual VM Image Creation via Azure Portal

### Creating Generalized Images via Portal

#### 1. Prepare Source VM via Portal
1. Navigate to **Virtual machines**
2. Select your source VM
3. **For Windows VMs:**
   - Click **Connect** > **RDP**
   - Download RDP file and connect
   - Open Command Prompt as Administrator
   - Run: `C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown`
   - Wait for VM to shutdown

4. **For Linux VMs:**
   - Click **Connect** > **SSH**
   - Connect via SSH
   - Run: `sudo waagent -deprovision+user -force`
   - Exit SSH session

#### 2. Create Image via Portal
1. Navigate to **Virtual machines**
2. Select the prepared VM
3. Click **Capture** in the toolbar
4. **Create an image** page:
   - **Resource group**: Select existing or create new
   - **Share image to Azure compute gallery**: Choose option
   - **Instance details**:
     - Name: `img-generalized-portal`
     - Region: `Southeast Asia`
   - **Target Azure compute gallery**: Create new or select existing
   - **Target VM image definition**: Create new
     - **VM image definition name**: `windows-server-2022-portal`
     - **Publisher**: `MyCompany`
     - **Offer**: `WindowsServer`
     - **SKU**: `2022-Datacenter`
   - **Version number**: `1.0.0`
   - **Replication**:
     - **Default replica count**: `2`
     - **Target regions**: Add `East Asia`
5. Click **Review + create** > **Create**

#### 3. Deploy VM from Portal Image
1. Navigate to **Virtual machines** > **Create**
2. **Basics tab**:
   - **Image**: Click **See all images**
   - Go to **My Images** tab
   - Select your created image
   - Configure VM settings normally
3. Complete VM creation process

### Creating Specialized Images via Portal

#### 1. Prepare Source VM (No Sysprep/Deprovision)
1. Navigate to **Virtual machines**
2. Select source VM
3. Click **Stop** (do not run sysprep or deprovision)
4. Wait for VM to stop completely

#### 2. Create Specialized Image
1. Select the stopped VM
2. Click **Capture**
3. **Create an image** page:
   - **Resource group**: Select resource group
   - **Share image to Azure compute gallery**: **No, capture only a managed image**
   - **Instance details**:
     - **Name**: `img-specialized-portal`
     - **Region**: `Southeast Asia`
   - **Automatically delete this virtual machine after creating the image**: Choose as needed
4. Click **Review + create** > **Create**

### Azure Compute Gallery via Portal

#### 1. Create Compute Gallery
1. Navigate to **Azure compute galleries**
2. Click **Create**
3. **Basics tab**:
   - **Resource group**: `sa1_test_eic_SudarshanDarade`
   - **Name**: `gallery_vm_images_portal`
   - **Region**: `Southeast Asia`
   - **Description**: `VM images gallery for portal demo`
4. Click **Review + create** > **Create**

#### 2. Create VM Image Definition
1. Navigate to your created gallery
2. Click **Add** > **VM image definition**
3. **Basics tab**:
   - **VM image definition name**: `ubuntu-22-04-lts-portal`
   - **Publisher**: `MyCompany`
   - **Offer**: `Ubuntu`
   - **SKU**: `22.04-LTS`
   - **OS type**: `Linux`
   - **OS state**: `Generalized`
   - **Generation**: `V2`
4. **Publishing options**:
   - **Exclude from latest**: `No`
   - **End of life date**: Set future date
5. Click **Review + create** > **Create**

#### 3. Create Image Version
1. Navigate to your image definition
2. Click **Add version**
3. **Basics tab**:
   - **Version number**: `1.0.0`
   - **Source**: Select your managed image
4. **Replication tab**:
   - **Default replica count**: `2`
   - **Target regions**: Add regions as needed
5. Click **Review + create** > **Create**

#### 4. Deploy from Gallery via Portal
1. Navigate to **Virtual machines** > **Create**
2. **Basics tab**:
   - **Image**: Click **See all images**
   - Go to **Shared Images** tab
   - Select your gallery image
3. Complete VM creation normally

### PowerShell Portal Automation

```powershell
# PowerShell script to automate portal-like operations

# Create Compute Gallery
New-AzGallery -ResourceGroupName "sa1_test_eic_SudarshanDarade" -Name "gallery_vm_images_portal" -Location "Southeast Asia" -Description "Portal created gallery"

# Create Image Definition
$imageDefinition = @{
    ResourceGroupName = "sa1_test_eic_SudarshanDarade"
    GalleryName = "gallery_vm_images_portal"
    Name = "windows-server-2022-portal"
    Publisher = "MyCompany"
    Offer = "WindowsServer"
    Sku = "2022-Datacenter"
    OsType = "Windows"
    OsState = "Generalized"
    Location = "Southeast Asia"
}
New-AzGalleryImageDefinition @imageDefinition

# Create Image Version from existing managed image
$imageVersion = @{
    ResourceGroupName = "sa1_test_eic_SudarshanDarade"
    GalleryName = "gallery_vm_images_portal"
    GalleryImageDefinitionName = "windows-server-2022-portal"
    Name = "1.0.0"
    Location = "Southeast Asia"
    SourceImageId = "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/images/img-windows-generalized"
    ReplicaCount = 2
    TargetRegion = @(
        @{Name="Southeast Asia"; ReplicaCount=2}
        @{Name="East Asia"; ReplicaCount=1}
    )
}
New-AzGalleryImageVersion @imageVersion
```

---

## Prerequisites

- Active Microsoft Azure account
- Azure CLI installed
- Source VM for image creation
- Appropriate permissions for image management

---

## Creating Generalized Images

### 1. Prepare Windows VM for Generalization

#### Connect to Windows VM

```bash
# Get VM public IP
VM_IP=$(az vm show -d -g sa1_test_eic_SudarshanDarade -n vm-windows-source --query publicIps -o tsv)

# RDP to the VM (use Remote Desktop client)
echo "Connect to: $VM_IP"
```

#### Sysprep Windows VM

```powershell
# Run on Windows VM via RDP
# Open Command Prompt as Administrator
cd C:\Windows\System32\Sysprep

# Run Sysprep with generalization
sysprep.exe /generalize /oobe /shutdown
```

#### Create Generalized Windows Image

```bash
# Deallocate the VM after sysprep shutdown
az vm deallocate \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-windows-source

# Mark VM as generalized
az vm generalize \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-windows-source

# Create image from generalized VM
az image create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-windows-generalized \
  --source vm-windows-source
```

### 2. Prepare Linux VM for Generalization

#### Connect and Prepare Linux VM

```bash
# SSH into Linux VM
ssh azureuser@<vm-ip>

# Remove machine-specific files
sudo waagent -deprovision+user -force

# Exit SSH session
exit
```

#### Create Generalized Linux Image

```bash
# Deallocate the VM
az vm deallocate \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-linux-source

# Mark VM as generalized
az vm generalize \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-linux-source

# Create image from generalized VM
az image create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-linux-generalized \
  --source vm-linux-source
```

### 3. Deploy VMs from Generalized Images

#### Deploy Windows VM from Generalized Image

```bash
# Create VM from generalized Windows image
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-from-generalized-windows \
  --image img-windows-generalized \
  --admin-username azureuser \
  --admin-password 'P@ssw0rd123!' \
  --size Standard_B2s
```

#### Deploy Linux VM from Generalized Image

```bash
# Create VM from generalized Linux image
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-from-generalized-linux \
  --image img-linux-generalized \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --size Standard_B2s
```

---

## Creating Specialized Images

### 1. Create Specialized Windows Image

#### Prepare Source VM (No Sysprep)

```bash
# Stop the VM (do not run sysprep)
az vm stop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-windows-source-specialized

# Deallocate the VM
az vm deallocate \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-windows-source-specialized

# Create specialized image (do not generalize)
az image create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-windows-specialized \
  --source vm-windows-source-specialized
```

#### Deploy from Specialized Windows Image

```bash
# Create VM from specialized image
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-from-specialized-windows \
  --image img-windows-specialized \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password 'P@ssw0rd123!'
```

### 2. Create Specialized Linux Image

#### Prepare Source VM (No Deprovision)

```bash
# Stop the VM (do not run waagent deprovision)
az vm stop \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-linux-source-specialized

# Deallocate the VM
az vm deallocate \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-linux-source-specialized

# Create specialized image
az image create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-linux-specialized \
  --source vm-linux-source-specialized
```

#### Deploy from Specialized Linux Image

```bash
# Create VM from specialized image
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-from-specialized-linux \
  --image img-linux-specialized \
  --size Standard_B2s
```

---

## Azure Compute Gallery (Shared Image Gallery)

### 1. Create Compute Gallery

```bash
# Create Azure Compute Gallery
az sig create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --location southeastasia
```

### 2. Create Image Definition

```bash
# Create image definition for Windows
az sig image-definition create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition windows-server-2022 \
  --publisher MyCompany \
  --offer WindowsServer \
  --sku 2022-Datacenter \
  --os-type Windows \
  --os-state Generalized

# Create image definition for Linux
az sig image-definition create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --publisher MyCompany \
  --offer Ubuntu \
  --sku 22.04-LTS \
  --os-type Linux \
  --os-state Generalized
```

### 3. Create Image Version

```bash
# Create image version from generalized Windows image
az sig image-version create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition windows-server-2022 \
  --gallery-image-version 1.0.0 \
  --managed-image img-windows-generalized \
  --replica-count 2 \
  --target-regions southeastasia eastasia

# Create image version from generalized Linux image
az sig image-version create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --gallery-image-version 1.0.0 \
  --managed-image img-linux-generalized \
  --replica-count 2 \
  --target-regions southeastasia eastasia
```

### 4. Deploy from Gallery Image

```bash
# Deploy VM from gallery image
az vm create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-from-gallery \
  --image "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/galleries/gallery_vm_images/images/ubuntu-22-04-lts/versions/1.0.0" \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/azure-key.pub \
  --size Standard_B2s
```

---

## Image Management Operations

### 1. List and View Images

```bash
# List all images in resource group
az image list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --output table

# Get image details
az image show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-linux-generalized \
  --query "{Name:name, OsType:storageProfile.osDisk.osType, OsState:storageProfile.osDisk.osState, SizeGB:storageProfile.osDisk.diskSizeGb}"

# List gallery images
az sig image-definition list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --output table
```

### 2. Update Image Versions

```bash
# Create new version of existing image
az sig image-version create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --gallery-image-version 1.1.0 \
  --managed-image img-linux-generalized-updated \
  --replica-count 2 \
  --target-regions southeastasia eastasia 
```

### 3. Share Images Across Subscriptions

```bash
# Share gallery with another subscription
az sig share enable-community \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images

# Or share with specific subscriptions/tenants
az role assignment create \
  --assignee <user-or-service-principal> \
  --role "Reader" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/sa1_test_eic_SudarshanDarade/providers/Microsoft.Compute/galleries/gallery_vm_images"
```

---

## Automated Image Creation

### 1. Automated Generalized Image Script

```bash
#!/bin/bash
# Automated generalized image creation script

RESOURCE_GROUP="sa1_test_eic_SudarshanDarade"
SOURCE_VM="vm-source"
IMAGE_NAME="img-automated-$(date +%Y%m%d)"

echo "Creating generalized image from $SOURCE_VM"

# For Linux VMs - deprovision first
echo "Deprovisioning Linux VM..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $SOURCE_VM \
  --command-id RunShellScript \
  --scripts "sudo waagent -deprovision+user -force"

# Deallocate VM
echo "Deallocating VM..."
az vm deallocate \
  --resource-group $RESOURCE_GROUP \
  --name $SOURCE_VM

# Generalize VM
echo "Generalizing VM..."
az vm generalize \
  --resource-group $RESOURCE_GROUP \
  --name $SOURCE_VM

# Create image
echo "Creating image..."
az image create \
  --resource-group $RESOURCE_GROUP \
  --name $IMAGE_NAME \
  --source $SOURCE_VM

echo "Image $IMAGE_NAME created successfully"
```

### 2. PowerShell Automation for Windows

```powershell
# PowerShell script for automated Windows image creation
param(
    [string]$ResourceGroup = "sa1_test_eic_SudarshanDarade",
    [string]$SourceVM = "vm-windows-source",
    [string]$ImageName = "img-windows-$(Get-Date -Format 'yyyyMMdd')"
)

Write-Host "Creating generalized Windows image from $SourceVM"

# Run sysprep on the VM
Write-Host "Running sysprep..."
az vm run-command invoke `
  --resource-group $ResourceGroup `
  --name $SourceVM `
  --command-id RunPowerShellScript `
  --scripts "C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown"

# Wait for VM to shutdown
Start-Sleep -Seconds 120

# Deallocate VM
Write-Host "Deallocating VM..."
az vm deallocate --resource-group $ResourceGroup --name $SourceVM

# Generalize VM
Write-Host "Generalizing VM..."
az vm generalize --resource-group $ResourceGroup --name $SourceVM

# Create image
Write-Host "Creating image..."
az image create `
  --resource-group $ResourceGroup `
  --name $ImageName `
  --source $SourceVM

Write-Host "Image $ImageName created successfully"
```

---

## Image Versioning and Lifecycle

### 1. Version Management

```bash
# Create multiple versions
az sig image-version create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --gallery-image-version 2.0.0 \
  --managed-image img-linux-updated \
  --end-of-life-date 2025-12-31T23:59:59Z

# List all versions
az sig image-version list \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --output table
```

### 2. Image Replication

```bash
# Update replication settings
az sig image-version update \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --gallery-image-version 1.0.0 \
  --target-regions southeastasia=2 eastasia=1 centralus=1
```

---

## Best Practices

### 1. Image Preparation Checklist

**Windows Generalization:**
- Install all required software and updates
- Configure applications and settings
- Remove temporary files and logs
- Run Windows Update
- Run sysprep with /generalize /oobe /shutdown

**Linux Generalization:**
- Install required packages and updates
- Configure applications
- Clear bash history and logs
- Remove SSH host keys
- Run waagent -deprovision+user -force

### 2. Security Considerations

```bash
# Remove sensitive data before image creation
# For Linux:
sudo rm -rf /var/log/*
sudo rm -rf /tmp/*
sudo rm -rf ~/.bash_history
sudo rm -rf /etc/ssh/ssh_host_*

# For Windows (PowerShell):
# Clear-EventLog -LogName Application, System, Security
# Remove-Item -Path "$env:TEMP\*" -Recurse -Force
```

### 3. Image Optimization

```bash
# Optimize image size by removing unnecessary files
# Linux optimization script
sudo apt-get clean
sudo apt-get autoremove -y
sudo rm -rf /var/cache/apt/archives/*
sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY
```

---

## Monitoring and Troubleshooting

### 1. Image Status Monitoring

```bash
# Check image creation status
az image show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-linux-generalized \
  --query "provisioningState"

# Monitor gallery image version status
az sig image-version show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --gallery-image-version 1.0.0 \
  --query "provisioningState"
```

### 2. Common Issues and Solutions

**Sysprep Failures:**
- Check Windows logs in Event Viewer
- Ensure no pending reboots
- Verify all applications support sysprep

**Linux Deprovision Issues:**
- Check waagent logs: `/var/log/waagent.log`
- Ensure waagent service is running
- Verify network connectivity

### 3. Diagnostic Commands

```bash
# Check VM generalization status
az vm get-instance-view \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name vm-source \
  --query "osProfile"

# Verify image properties
az image show \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-linux-generalized \
  --query "storageProfile.osDisk.osState"
```

---

## Cleanup

```bash
# Delete images
az image delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name img-linux-generalized

# Delete gallery image version
az sig image-version delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images \
  --gallery-image-definition ubuntu-22-04-lts \
  --gallery-image-version 1.0.0

# Delete entire gallery
az sig delete \
  --resource-group sa1_test_eic_SudarshanDarade \
  --gallery-name gallery_vm_images
```

---

## Summary

This guide covered:
- Understanding differences between generalized and specialized images
- Creating generalized images for Windows and Linux VMs
- Creating specialized images for exact system replication
- Using Azure Compute Gallery for image versioning and sharing
- Automated image creation and management
- Best practices for image preparation and security
- Troubleshooting common image creation issues

Generalized images are recommended for production deployments and scale sets, while specialized images are useful for backup and disaster recovery scenarios.
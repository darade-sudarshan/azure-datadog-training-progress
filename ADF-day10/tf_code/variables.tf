variable "business_division" {
  description = "Business Division of project"
  type        = string
  default     = "DevOps"
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "sa1_test_eic_SudarshanDarade"

}
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "664b6097-19f2-42a3-be95-a4a6b4069f6b"

}
variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = "0adb040b-ca22-4ca6-9447-ab7b049a22ff"

}

variable "Role" {
  description = "Role of the instance"
  type        = list(string)
  default     = ["master", "agent", "sonar"]
}
variable "location" {
  description = "Azure Region"
  type        = string
  default     = ""

}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "public_subnet_prefixes" {
  description = "Subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_prefixes" {
  description = "Subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "DB_subnet_prefixes" {
  description = "Database subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]

}
variable "bastion_subnet_prefixes" {
  description = "Bastion subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = [""]

}
variable "dns_servers_address" {
  description = "DNS servers address for the Virtual Network"
  type        = list(string)
  default     = [""]

}

variable "network_interfaces" {
  description = "Network interfaces configuration"
  type = map(object({
    subnet_type = string
  }))
  default = {}
}

variable "LinuxNSGRules" {
  description = "List of security rules for the Linux NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}


variable "WinNSGRules" {
  description = "List of security rules for the Windows NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
# Linux VM Variables
variable "linux_vm_size" {
  description = "Size of the Linux Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}
variable "linux_username" {
  description = "Admin username for the Linux VM"
  type        = string
  default     = ""
}
variable "linux_password" {
  description = "Admin password for the Linux VM"
  type        = string
  sensitive   = true
  default     = ""
}
variable "linux_hostname" {
  description = "Hostname for the Linux VM"
  type        = string
  default     = "linux"
}
variable "linux_disk_size_gb" {
  description = "Size of the Linux OS disk in GB"
  type        = number
  default     = 30
}

# Windows VM Variables
variable "windows_vm_size" {
  description = "Size of the Windows Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}
variable "windows_username" {
  description = "Admin username for the Windows VM"
  type        = string
  default     = ""
}
variable "windows_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
  default     = ""
}
variable "windows_hostname" {
  description = "Hostname for the Windows VM"
  type        = string
  default     = "windows"
}
variable "windows_disk_size_gb" {
  description = "Size of the Windows OS disk in GB"
  type        = number
  default     = 127
}
variable "custom_data" {
  description = "Custom data for the VM"
  type        = string
  default     = ""
}
variable "user_data" {
  description = "User data for the VM"
  type        = string
  default     = ""
}

variable "network_interface_ids" {
  description = "List of Network Interface IDs to attach to the VM"
  type        = list(string)
  default     = []

}
variable "zones" {
  description = "Availability zones for the VM"
  type        = list(string)
  default     = []

}
variable "os_type" {
  description = "Operating System type for the VM"
  type        = string
  default     = "Linux" # Options: "Linux", "Windows"
}

# VMSS Variables
variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = ""
}

variable "instance_count" {
  description = "Number of instances in the scale set"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "Admin password for Windows VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "admin_ssh_key" {
  description = "SSH public key for Linux VM"
  type        = string
  default     = null
}

variable "upgrade_mode" {
  description = "Upgrade mode for the scale set"
  type        = string
  default     = "Manual"
}

variable "source_image_reference" {
  description = "Source image reference for the VMSS"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_caching" {
  description = "Caching type for OS disk"
  type        = string
  default     = "ReadWrite"
}

variable "enable_public_ip" {
  description = "Enable public IP for VMSS instances"
  type        = bool
  default     = false
}

variable "windows_source_image_reference" {
  description = "Source image reference for Windows VMSS"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
variable "acr_sku" {
  description = "SKU for the Azure Container Registry"
  type        = string
  default     = "Basic"

}
variable "acr_admin_enabled" {
  description = "Enable admin user for Azure Container Registry"
  type        = bool
  default     = true

}
# Storage Account Variables
variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = ""
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

# Azure Data Factory Variables
variable "adf_name" {
  description = "Name of the Azure Data Factory"
  type        = string
  default     = ""
}

# Databricks Variables
variable "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
  default     = "databricks-workspace-001"
}

variable "databricks_sku" {
  description = "SKU for the Databricks workspace"
  type        = string
  default     = "standard"
}

# Database Variables
variable "db_server_name" {
  description = "Name of the SQL Server"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = ""
}

variable "db_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = ""
}

variable "db_admin_password" {
  description = "Administrator password for SQL Server"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_sku_name" {
  description = "Database SKU name"
  type        = string
  default     = ""
}
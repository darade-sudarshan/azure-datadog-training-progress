variable "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the Databricks workspace"
  type        = string
}

variable "sku" {
  description = "SKU for the Databricks workspace"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium", "trial"], var.sku)
    error_message = "SKU must be one of: standard, premium, trial."
  }
}

variable "enable_custom_vnet" {
  description = "Enable custom VNet injection"
  type        = bool
  default     = false
}

variable "no_public_ip" {
  description = "Disable public IP for cluster nodes"
  type        = bool
  default     = false
}

variable "virtual_network_id" {
  description = "ID of the virtual network for VNet injection"
  type        = string
  default     = null
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = null
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = null
}

variable "private_subnet_nsg_association_id" {
  description = "ID of the private subnet NSG association"
  type        = string
  default     = null
}

variable "public_subnet_nsg_association_id" {
  description = "ID of the public subnet NSG association"
  type        = string
  default     = null
}

variable "enable_customer_managed_key" {
  description = "Enable customer managed key encryption"
  type        = bool
  default     = false
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
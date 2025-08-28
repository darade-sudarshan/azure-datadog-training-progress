
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
variable "location" {
  description = "Azure Region"
  type        = string
  default     = ""
  
}
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = ""
}

variable "bastion_subnet_id" {
  description = "Subnet ID for the Azure Bastion Host"
  type        = string
  default     = ""
  
}
variable "bastion_sku" {
  description = "SKU for the Azure Bastion Host"
  type        = string
  default     = ""
  
}
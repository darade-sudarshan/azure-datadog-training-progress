
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
variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "public_subnet_prefixes" {
  description = "Subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24"]
}
variable "private_subnet_prefixes" {
  description = "Subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = ["10.0.3.0/24","10.0.4.0/24"]
}
variable "DB_subnet_prefixes" {
  description = "Database subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = ["10.0.151.0/24","10.0.152.0/24"]
  
}
variable "bastion_subnet_prefixes" {
  description = "Bastion subnet prefixes for the Virtual Network"
  type        = list(string)
  default     = []
}

variable "create_bastion" {
  description = "Whether to create bastion subnet"
  type        = bool
  default     = false
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

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet"
}
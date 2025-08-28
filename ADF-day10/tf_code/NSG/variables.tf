
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

variable "LinuxNSGRules" {
  description = "List of security rules for the Linux NSG"
  type        = list(object({
    name                        = string
    priority                    = number
    direction                   = string
    access                      = string
    protocol                    = string
    source_port_range           = string
    destination_port_range      = string
    source_address_prefix       = string
    destination_address_prefix  = string
  }))
  default     = []
}

variable "WinNSGRules" {
  description = "List of security rules for the Windows NSG"
  type        = list(object({
    name                        = string
    priority                    = number
    direction                   = string
    access                      = string
    protocol                    = string
    source_port_range           = string
    destination_port_range      = string
    source_address_prefix       = string
    destination_address_prefix  = string
  }))
  default     = []
}
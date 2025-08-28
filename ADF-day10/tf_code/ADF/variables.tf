variable "data_factory_name" {
  description = "Name of the Azure Data Factory"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the Data Factory"
  type        = string
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = true
}

variable "storage_linked_services" {
  description = "Map of storage linked services"
  type = map(object({
    connection_string = string
  }))
  default = {}
}

variable "blob_datasets" {
  description = "Map of blob datasets"
  type = map(object({
    linked_service_name = string
    path                = string
    filename            = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
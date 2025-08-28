# Azure Storage Account Module

This Terraform module creates an Azure Storage Account with optional blob containers.

## Usage

```hcl
module "storage_account" {
  source = "./STORAGE_ACCOUNT"
  
  storage_account_name   = "mystorageaccount"
  resource_group_name    = "my-rg"
  location              = "East US"
  account_tier          = "Standard"
  account_replication_type = "LRS"
  
  containers = {
    "data" = {
      access_type = "private"
    }
    "logs" = {
      access_type = "blob"
    }
  }
  
  tags = {
    Environment = "dev"
    Project     = "myproject"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| storage_account_name | Name of the storage account | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| location | Azure region | string | n/a | yes |
| account_tier | Storage account tier | string | "Standard" | no |
| account_replication_type | Replication type | string | "LRS" | no |
| containers | Map of containers to create | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | ID of the storage account |
| storage_account_name | Name of the storage account |
| primary_blob_endpoint | Primary blob endpoint |
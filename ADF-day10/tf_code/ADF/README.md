# Azure Data Factory Module

This Terraform module creates an Azure Data Factory with optional linked services and datasets.

## Usage

```hcl
module "data_factory" {
  source = "./ADF"
  
  data_factory_name   = "my-data-factory"
  resource_group_name = "my-rg"
  location           = "East US"
  
  storage_linked_services = {
    "storage-link" = {
      connection_string = "DefaultEndpointsProtocol=https;AccountName=..."
    }
  }
  
  blob_datasets = {
    "input-dataset" = {
      linked_service_name = "storage-link"
      path               = "input"
      filename           = "data.csv"
    }
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| data_factory_name | Name of the Data Factory | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| location | Azure region | string | n/a | yes |
| enable_managed_identity | Enable managed identity | bool | true | no |
| storage_linked_services | Map of storage linked services | map(object) | {} | no |
| blob_datasets | Map of blob datasets | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| data_factory_id | ID of the Data Factory |
| data_factory_name | Name of the Data Factory |
| identity_principal_id | Principal ID of managed identity |
# Azure Databricks Module

This Terraform module creates an Azure Databricks workspace with optional VNet injection and customer-managed key encryption.

## Usage

```hcl
module "databricks" {
  source = "./DATABRICKS"
  
  databricks_workspace_name = "my-databricks-workspace"
  resource_group_name       = "my-rg"
  location                 = "East US"
  sku                      = "premium"
  
  # Optional VNet injection
  enable_custom_vnet                    = true
  virtual_network_id                    = "/subscriptions/.../virtualNetworks/my-vnet"
  private_subnet_name                   = "databricks-private"
  public_subnet_name                    = "databricks-public"
  private_subnet_nsg_association_id     = "/subscriptions/.../networkSecurityGroups/..."
  public_subnet_nsg_association_id      = "/subscriptions/.../networkSecurityGroups/..."
  no_public_ip                         = true
  
  tags = {
    Environment = "dev"
    Project     = "analytics"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| databricks_workspace_name | Name of the Databricks workspace | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| location | Azure region | string | n/a | yes |
| sku | Databricks SKU (standard/premium/trial) | string | "standard" | no |
| enable_custom_vnet | Enable VNet injection | bool | false | no |
| virtual_network_id | VNet ID for injection | string | null | no |
| no_public_ip | Disable public IP for clusters | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| databricks_workspace_id | ID of the Databricks workspace |
| databricks_workspace_url | URL of the Databricks workspace |
| managed_resource_group_id | ID of the managed resource group |
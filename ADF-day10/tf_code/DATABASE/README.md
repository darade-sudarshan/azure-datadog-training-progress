# Azure SQL Database Module

This Terraform module creates an Azure SQL Server and Database with optional firewall rules.

## Usage

```hcl
module "sql_database" {
  source = "./DATABASE"
  
  sql_server_name     = "my-sql-server"
  database_name       = "my-database"
  resource_group_name = "my-rg"
  location           = "East US"
  admin_username     = "sqladmin"
  admin_password     = "P@ssw0rd123!"
  
  sku_name    = "S1"
  max_size_gb = 10
  
  firewall_rules = {
    "office" = {
      start_ip = "203.0.113.0"
      end_ip   = "203.0.113.255"
    }
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| sql_server_name | Name of the SQL Server | string | n/a | yes |
| database_name | Name of the SQL Database | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| location | Azure region | string | n/a | yes |
| admin_username | Administrator username | string | n/a | yes |
| admin_password | Administrator password | string | n/a | yes |
| sku_name | Database SKU | string | "S0" | no |
| max_size_gb | Maximum database size in GB | number | 2 | no |
| firewall_rules | Map of firewall rules | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| sql_server_id | ID of the SQL Server |
| sql_server_fqdn | Fully qualified domain name |
| database_id | ID of the SQL Database |
| connection_string | Database connection string |
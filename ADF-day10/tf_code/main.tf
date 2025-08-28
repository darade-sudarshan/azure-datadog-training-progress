
module "VNET" {
  for_each = local.vnets

  source                  = "./VNET"
  location                = var.location
  resource_group_name     = var.resource_group_name
  vnet_name               = each.key
  address_space           = each.value.address_space
  dns_servers_address     = var.dns_servers_address
  public_subnet_prefixes  = each.value.public_subnet_prefixes
  private_subnet_prefixes = each.value.private_subnet_prefixes
  DB_subnet_prefixes      = each.value.DB_subnet_prefixes
  bastion_subnet_prefixes = each.value.bastion_subnet_prefixes
  create_bastion          = each.value.create_bastion
  network_interfaces      = each.value.network_interfaces
}
module "NSG" {
  source              = "./NSG"
  resource_group_name = var.resource_group_name
  location            = var.location
  LinuxNSGRules       = local.default_linux_nsg_rules
  WinNSGRules         = local.default_Win_nsg_rules

}
module "BASTION" {
  source              = "./BASTION"
  depends_on          = [module.VNET]
  resource_group_name = var.resource_group_name
  location            = var.location
  bastion_subnet_id   = module.VNET["dev-vnet"].bastion_subnet_id
  bastion_sku         = "Basic" # or "Standard" based on your requirement
}
module "STORAGE_ACCOUNT" {
  source              = "./STORAGE_ACCOUNT"
  resource_group_name = var.resource_group_name
  storage_account_name = var.storage_account_name
  location            = var.location
  account_tier        = var.storage_account_tier
}
module "ADF" {
  source              = "./ADF"
  resource_group_name = var.resource_group_name
  data_factory_name  = var.adf_name
  location            = var.location
 
}
module "DATABRICKS" {
  source              = "./DATABRICKS"
  resource_group_name = var.resource_group_name
  location            = var.location
  databricks_workspace_name = var.databricks_workspace_name
  sku                 = var.databricks_sku
}
module "DATABASE" {
  source              = "./DATABASE"
  resource_group_name = var.resource_group_name
  location            = var.location
  sql_server_name = var.db_server_name
  database_name             = var.db_name
  admin_username      = var.db_admin_username
  admin_password      = var.db_admin_password
  sku_name            = var.db_sku_name
}


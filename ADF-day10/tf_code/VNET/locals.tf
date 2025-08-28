# Define Local Values in Terraform
locals {
  owners      = var.business_division
  environment = var.environment
  name        = "${var.business_division}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
  resource_group_name = "sa1_test_eic_SudarshanDarade"
  tags = {
    "Business Owner"    = "Chirag.Gandhi@einfochips.com"
    "Business Unit"     = "einfochips"
    "End Date RG"       = "30-Dec-2025"
    "Environment Type"  = "Test"
    "Project Name"      = "Training and Learning purpose"
    "RG Create"         = "25-Oct-2024"
    "RG Owner"          = "Sudarshan.Darade@einfochips.com"
    "Sub Business Unit" = "PES - IA"
    "Task #"            = "SCTASK0638064"
  }
  
  subnet_map = {
    "private01" = azurerm_subnet.private_subnet01.id
    "private02" = azurerm_subnet.private_subnet02.id
    "public01"  = azurerm_subnet.public_subnet01.id
    "public02"  = azurerm_subnet.public_subnet02.id
  }
  
  network_interfaces = {
    for k, v in var.network_interfaces : k => {
      subnet_id = local.subnet_map[v.subnet_type]
    }
  }
}


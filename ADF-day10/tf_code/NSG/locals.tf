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
}


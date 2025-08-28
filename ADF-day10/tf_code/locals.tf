# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Define Local Values in Terraform
locals {
  owners      = var.business_division
  environment = var.environment
  name        = "${var.business_division}-${var.environment}-${random_string.suffix.result}"
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

locals {
  vnets = {
    "dev-vnet" = {
      address_space           = ["10.0.0.0/16"]
      public_subnet_prefixes  = ["10.0.1.0/24", "10.0.2.0/24"]
      private_subnet_prefixes = ["10.0.3.0/24", "10.0.4.0/24"]
      DB_subnet_prefixes      = ["10.0.151.0/24", "10.0.152.0/24"]
      bastion_subnet_prefixes = ["10.0.250.0/26"]
      create_bastion          = true
      network_interfaces = {
        "Linux_NIC_private" = { subnet_type = "private01" }
        "Linux_NIC_public"  = { subnet_type = "public01" }
      }
    }
  }
}
locals {
  # nginx_script = base64encode(file("${path.module}/scripts/install_nginx.sh"))

  VM-instances = {
    Linux_VM_01 = {
      hostname     = "${var.linux_hostname}-01"
      size         = var.linux_vm_size
      username     = var.linux_username
      password     = var.linux_password
      disk_size_gb = var.linux_disk_size_gb
      # user_data    = local.nginx_script
      nsg_id       = module.NSG.LinuxNSG_id
      network_interface_ids = [
        module.VNET["dev-vnet"].Linux_NIC_private_id
      ]
    }
    #     Windows_VM = {
    #       hostname     = var.windows_hostname
    #       size         = var.windows_vm_size
    #       username     = var.windows_username
    #       password     = var.windows_password
    #       disk_size_gb = var.windows_disk_size_gb
    #       network_interface_ids = [
    #         module.VNET["staging-vnet"].Windows_NIC_private_id,
    #         module.VNET["staging-vnet"].Windows_NIC_public_id
    #       ]
    #     }
  }
}
locals {
  default_linux_nsg_rules = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
      destination_address_prefix = "*"
    }
  ]

  default_Win_nsg_rules = [
    {
      name                       = "RDP"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
      destination_address_prefix = "*"
    }
  ]
}
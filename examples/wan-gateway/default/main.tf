terraform {
  required_version = ">= 1.6.6, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.7, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, <4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  #subscription_id     = "your-subscription-id" # Or set as environment variable ARM_SUBSCRIPTION_ID
  storage_use_azuread = true
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = ["wangw"] # Unique suffix for naming module
}


module "wan-gateway" {
    source = "../../../modules/wan-gateway"

    wan_gateway_name     = module.naming.linux_virtual_machine.name
    location             = "eastus"
    resource_group_name  = "EUS-WAN"
    wan_subnet_id        = "your-wan-subnet-id"
    wan_gateway_ip       = "10.1.1.5"
    wan_vm_size          = "Standard_B2pts_v2"
    admin_user           = "azureadmin"
    public_key           = "your-public-key"
}
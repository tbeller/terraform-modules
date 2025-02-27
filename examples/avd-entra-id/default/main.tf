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
  #subscription_id     = "your-subscription-id" # Or set as environment variable
  storage_use_azuread = true
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = ["avd-eus"] # Unique suffix for naming module
}

module "avd_entra_id" {
  source = "../../../modules/avd-entra-id"

  resource_group_name    = module.naming.resource_group.name
  location               = "eastus"
  address_space_start_ip = "10.0.0.0"
  address_space_size     = 16
  subnets = {
    private_endpoints = {
      size                       = 28
      has_nat_gateway            = false
      has_network_security_group = true
    }
    virtual_machines = {
      size                       = 24
      has_nat_gateway            = true
      has_network_security_group = false
    }
  }
  session_host_count                = 2
  session_host_vm_size              = "Standard_B2s"
  session_host_local_admin_username = "azureadmin"
  session_host_local_admin_password = "secureP@ssw0rd"
  user_group_id                     = "d7bfd5d0-ac3e-4bf5-87b7-92e1db0d893e"
  tags = {
    environment = "dev"
    project     = "avd"
  }
  workspace_description                          = "AVD Workspace"
  workspace_name                                 = module.naming.virtual_desktop_workspace.name
  workspace_friendly_name                        = "AVD Workspace"
  hostpool_name                                  = module.naming.virtual_desktop_host_pool.name
  hostpool_type                                  = "Pooled"
  hostpool_load_balancer_type                    = "DepthFirst"
  hostpool_custom_rdp_properties                 = "audiocapturemode:i:1;audiomode:i:0;enablerdsaadauth:i:1;redirectlocation:i:1;"
  hostpool_maximum_sessions_allowed              = 10
  hostpool_start_vm_on_connect                   = true
  application_group_default_desktop_display_name = "Default Desktop"
  application_group_description                  = "AVD DAG"
  application_group_friendly_name                = "Desktop Application Group"
  application_group_name                         = module.naming.virtual_desktop_application_group.name
  application_group_type                         = "Desktop"
  nsg_name                                       = module.naming.network_security_group.name
  nat_gateway_name                               = module.naming.nat_gateway.name
  nat_gateway_pip_name                           = module.naming.public_ip.name
  vnet_name                                      = module.naming.virtual_network.name
  session_host_name                              = module.naming.virtual_machine.name
  storage_account_name                           = module.naming.storage_account.name_unique
}

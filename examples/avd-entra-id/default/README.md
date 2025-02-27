# Simple example for deployment of Azure Virtual Desktop with Entra ID
This example demonstrates how to deploy an Azure Virtual Desktop (AVD) environment with Entra ID authentication using the `avd-entra-id` Terraform module.


```hcl
terraform {
  required_version = ">= 1.6.6, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
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
  user_group_id                     = "GUID-of-the-user-group"
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
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Usage

Ensure you have Terraform installed and the Azure CLI authenticated to your Azure subscription.

Navigate to the directory containing this configuration and run:

```
terraform init
terraform apply
```
## Versioning
This module follows [Semantic Versioning](https://semver.org/).
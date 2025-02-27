resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

module "avm_workspace" {
  source                                        = "Azure/avm-res-desktopvirtualization-workspace/azurerm"
  version                                       = "0.2.0"
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_desktop_workspace_location            = var.location
  virtual_desktop_workspace_description         = var.workspace_description
  virtual_desktop_workspace_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_workspace_name                = var.workspace_name
  virtual_desktop_workspace_friendly_name       = var.workspace_friendly_name
  tags                                          = var.tags
}

module "avm_hostpool" {
  source                                             = "Azure/avm-res-desktopvirtualization-hostpool/azurerm"
  version                                            = "0.3.0"
  virtual_desktop_host_pool_location                 = azurerm_resource_group.this.location
  virtual_desktop_host_pool_name                     = var.hostpool_name
  virtual_desktop_host_pool_type                     = var.hostpool_type
  virtual_desktop_host_pool_resource_group_name      = azurerm_resource_group.this.name
  virtual_desktop_host_pool_load_balancer_type       = var.hostpool_load_balancer_type
  virtual_desktop_host_pool_custom_rdp_properties    = var.hostpool_custom_rdp_properties
  virtual_desktop_host_pool_maximum_sessions_allowed = var.hostpool_maximum_sessions_allowed
  virtual_desktop_host_pool_start_vm_on_connect      = var.hostpool_start_vm_on_connect
  resource_group_name                                = azurerm_resource_group.this.name
}

module "avm_application_group" {
  source                                                         = "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm"
  version                                                        = "0.2.0"
  virtual_desktop_application_group_default_desktop_display_name = var.application_group_default_desktop_display_name
  virtual_desktop_application_group_description                  = var.application_group_description
  virtual_desktop_application_group_friendly_name                = var.application_group_friendly_name
  virtual_desktop_application_group_host_pool_id                 = module.avm_hostpool.resource.id
  virtual_desktop_application_group_location                     = azurerm_resource_group.this.location
  virtual_desktop_application_group_resource_group_name          = azurerm_resource_group.this.name
  virtual_desktop_application_group_name                         = var.application_group_name
  virtual_desktop_application_group_type                         = var.application_group_type
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  application_group_id = module.avm_application_group.resource.id
  workspace_id         = module.avm_workspace.resource.id
}

# Caluculate the CIDR for the subnets
locals {
  virtual_network_address_space = "${var.address_space_start_ip}/${var.address_space_size}"
  subnet_keys                   = keys(var.subnets)
  subnet_new_bits               = [for subnet in values(var.subnets) : subnet.size - var.address_space_size]
  cidr_subnets                  = cidrsubnets(local.virtual_network_address_space, local.subnet_new_bits...)

  subnets = { for key, value in var.subnets : key => {
    name             = key
    address_prefixes = [local.cidr_subnets[index(local.subnet_keys, key)]]
    network_security_group = value.has_network_security_group ? {
      id = module.avm_nsg.resource_id
    } : null
    nat_gateway = value.has_nat_gateway ? {
      id = module.avm_nat_gateway.resource_id
    } : null
    }
  }
}

module "avm_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  resource_group_name = azurerm_resource_group.this.name
  name                = var.nsg_name
  location            = azurerm_resource_group.this.location

  security_rules = {
    no_internet = {
      access                     = "Deny"
      direction                  = "Outbound"
      name                       = "block-internet-traffic"
      priority                   = 100
      protocol                   = "*"
      destination_address_prefix = "Internet"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
  tags = var.tags
}

module "avm_nat_gateway" {
  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "0.2.1"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name                = var.nat_gateway_name
  public_ips = {
    default = {
      name = var.nat_gateway_pip_name
    }
  }
  tags = var.tags
}


module "avm_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  resource_group_name = azurerm_resource_group.this.name
  subnets             = local.subnets
  address_space       = [local.virtual_network_address_space]
  location            = var.location
  name                = var.vnet_name
  tags                = var.tags
}


module "avd_session_host" {
  source                            = "./avd-session-host"
  session_host_count                = var.session_host_count
  name                              = var.session_host_name
  subnet_id                         = module.avm_vnet.subnets["virtual_machines"].resource_id
  vm_size                           = var.session_host_vm_size
  local_admin_username              = var.session_host_local_admin_username
  local_admin_password              = var.session_host_local_admin_password
  registration_info_token           = module.avm_hostpool.registrationinfo_token
  resource_group_name               = azurerm_resource_group.this.name
  location                          = var.location
  hostpool_name                     = module.avm_hostpool.resource.name
  tags                              = var.tags
  storage_account_name              = module.avm_storage_account.resource.name
  storage_account_connection_string = module.avm_storage_account.resource.primary_connection_string
}

data "azurerm_role_definition" "role" {
  name = "Desktop Virtualization User"
}

resource "azurerm_role_assignment" "role" {
  scope              = module.avm_application_group.resource.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = var.user_group_id
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link" {
  name                  = "${module.avm_vnet.resource.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = module.avm_vnet.resource.id
}

module "avm_storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.5.0"

  account_replication_type  = "LRS"
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  location                  = var.location
  name                      = replace(var.storage_account_name, "-", "")
  resource_group_name       = azurerm_resource_group.this.name
  shared_access_key_enabled = true
  tags                      = var.tags

  private_endpoints_manage_dns_zone_group = true
  private_endpoints = {
    blob = {
      name                          = "pe-blob-${var.storage_account_name}"
      subnet_resource_id            = module.avm_vnet.subnets["private_endpoints"].resource_id
      subresource_name              = "blob"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      private_service_connection_name = "psc-blob-${var.storage_account_name}"
      network_interface_name          = "nic-pe-blob-${var.storage_account_name}"
      tags                            = var.tags
    }
  }
}

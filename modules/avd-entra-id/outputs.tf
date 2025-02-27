output "resource_group" {
    description = "The Azure Resource Group"
    value       = azurerm_resource_group.this
}

output "workspace" {
    description = "The Azure Virtual Machine workspace resource"
    value       = module.avm_workspace.resource
}

output "hostpool" {
    description = "The Azure Virtual Machine host pool resource"
    value       = module.avm_hostpool.resource
}

output "application_group" {
    description = "The Azure Virtual Machine application group resource"
    value       = module.avm_application_group.resource
}

output "subnets" {
    description = "The subnets within the virtual network"
    value       = module.avm_vnet.subnets
}

output "nsg" {
    description = "The Network Security Group resource"
    value       = module.avm_nsg.resource
}

output "nat_gateway" {
    description = "The NAT Gateway resource"
    value       = module.avm_nat_gateway.resource
}

output "storage_account" {
    description = "The Storage Account resource"
    value       = module.avm_storage_account.resource
}

output "private_dns_zone" {
    description = "The Private DNS Zone resource"
    value       = azurerm_private_dns_zone.this
}

output "private_dns_zone_virtual_network_link" {
    description = "The Private DNS Zone Virtual Network Link resource"
    value       = azurerm_private_dns_zone_virtual_network_link.private_link
}

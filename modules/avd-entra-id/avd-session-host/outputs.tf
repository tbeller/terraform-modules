output "network_interfaces" {
    description = "The network interfaces"
    value       = azurerm_network_interface.avd_vm_nic
}

output "virtual_machines" {
    description = "The virtual machines"
    value       = azurerm_windows_virtual_machine.avd_vm
}

output "entra_login_extensions" {
    description = "The Entra login extensions"
    value       = azurerm_virtual_machine_extension.entra_login
}

output "dsc_extensions" {
    description = "The DSC extensions"
    value       = azurerm_virtual_machine_extension.vmext_dsc
}

output "fslogix_setup_extensions" {
    description = "The FSLogix setup extensions"
    value       = azurerm_virtual_machine_extension.fslogix_setup
}

output "rbac_user_logins" {
    description = "The RBAC user login role assignments"
    value       = azurerm_role_assignment.rbac_user_login
}

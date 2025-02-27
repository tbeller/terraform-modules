resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.session_host_count
  name                = "${var.name}-${count.index + 1}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.session_host_count
  name                  = "${var.name}-${count.index + 1}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.avd_vm_nic[count.index].id]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  os_disk {
    name                 = "${lower(var.name)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-avd"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# resource "azurerm_virtual_machine_extension" "domain_join" {
#   count                      = var.count
#   name                       = "${var.name}-${count.index + 1}-domainJoin"
#   virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
#   publisher                  = "Microsoft.Compute"
#   type                       = "JsonADDomainExtension"
#   type_handler_version       = "1.3"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#       "Name": "${var.domain_name}",
#       "OUPath": "${var.ou_path}",
#       "User": "${var.domain_user_upn}@${var.domain_name}",
#       "Restart": "true",
#       "Options": "3"
#     }
# SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#       "Password": "${var.domain_password}"
#     }
# PROTECTED_SETTINGS

#   lifecycle {
#     ignore_changes = [settings, protected_settings]
#   }
# }

resource "azurerm_virtual_machine_extension" "entra_login" {
  count                      = var.session_host_count
  name                       = "${var.name}-${count.index + 1}-entraLogin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  tags = var.tags

}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.session_host_count
  name                       = "${var.name}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${var.hostpool_name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${var.registration_info_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.entra_login
  ]
  tags = var.tags
}

resource "azurerm_role_assignment" "rbac_user_login" {
  count                = var.session_host_count
  principal_id         = "d7bfd5d0-ac3e-4bf5-87b7-92e1db0d893e"
  scope                = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  role_definition_name = "Virtual Machine User Login"
}

data "template_file" "fslogix_settings" {
  template = file("${path.module}/fslogix_settings.ps1")
  vars = {
    storage_account_name = var.storage_account_name
    storage_account_connection_string = var.storage_account_connection_string
  }
}

resource "azurerm_virtual_machine_extension" "fslogix_setup" {
  count                      = var.session_host_count
  name                       = "${var.name}${count.index + 1}-fslogixSetup"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.fslogix_settings.rendered)}')) | Out-File -filepath fslogix_settings.ps1\" && powershell -ExecutionPolicy Unrestricted -File fslogix_settings.ps1"
  }
  SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.vmext_dsc
  ]

  tags = var.tags
}

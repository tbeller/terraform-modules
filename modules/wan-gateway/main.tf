resource "azurerm_public_ip" "wan_pip" {
  name                = "${var.wan_gateway_name}-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "vm_nic" {
  name                  = "${var.wan_gateway_name}-nic"
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.wan_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.wan_gateway_ip
    public_ip_address_id          = azurerm_public_ip.wan_pip.id
  }
  dns_servers = ["8.8.8.8", "8.8.4.4"]
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.wan_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.wan_vm_size #"Standard_B2pts_v2"
  admin_username      = var.admin_user  #"azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-arm64"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.public_key # Move to Azure Key Vault / store private key in vault
  }



}

resource "null_resource" "ansible_provision" {
  depends_on = [azurerm_linux_virtual_machine.vm]

  provisioner "local-exec" { #Need to also replace the admin username
    command = "sed -i -E \"s/\\b[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\b/${azurerm_public_ip.wan_pip.ip_address}/\" ${path.module}/ansible/inventory.ini"
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook ${path.module}/ansible/wan-gateway.yml -i ${path.module}/ansible/inventory.ini"
  }
}

output "wan_gateway_ip_address" {
    value = azurerm_public_ip.wan_pip.ip_address
}
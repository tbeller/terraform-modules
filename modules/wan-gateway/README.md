# Terraform Module: WAN Gateway

This Terraform module provisions a WAN gateway in Azure. It deploys a Linux virtual machine with a static public IP and network interface, configured with IP forwarding and additional network settings. Post-deployment, Ansible playbooks are executed to configure WireGuard, iptables, and enable IP forwarding. Configure wg0.conf with your WireGuard settings before running the module.

## Usage

```hcl
module "wan_gateway" {
  source              = "path/to/modules/wan-gateway"
  wan_gateway_name    = "my-wan-gateway"
  location            = "eastus"
  resource_group_name = "your-resource-group"
  wan_subnet_id       = "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"
  wan_gateway_ip      = "10.1.1.5"
  wan_vm_size         = "Standard_B2pts_v2"
  admin_user          = "azureadmin"
  public_key          = "ssh-rsa ..."
}
```

## Inputs

| Name              | Type   | Description                                                                                  |
|-------------------|--------|----------------------------------------------------------------------------------------------|
| `wan_gateway_name`    | string | The name of the WAN gateway.                                                               |
| `location`            | string | The Azure region where the resources will be created.                                     |
| `resource_group_name` | string | The name of the resource group.                                                            |
| `wan_subnet_id`       | string | The ID of the subnet in which the WAN gateway will be deployed.                            |
| `wan_gateway_ip`      | string | The static private IP address for the WAN gateway.                                         |
| `wan_vm_size`         | string | The size of the virtual machine for the WAN gateway.                                       |
| `admin_user`          | string | The admin username for the Linux virtual machine.                                          |
| `public_key`          | string | The public SSH key for the admin user.                                                     |

## Outputs

| Name                     | Description                                  |
|--------------------------|----------------------------------------------|
| `wan_gateway_ip_address` | The public IP address assigned to the WAN gateway. |

## How It Works

1. **Infrastructure Provisioning**  
   The module creates:
   - An Azure public IP with a static allocation.
   - A network interface with IP forwarding enabled, attached to the specified subnet.
   - A Linux virtual machine using the created network interface.
   
2. **Post-Provisioning Configuration**  
   A `null_resource` is used to:
   - Update the Ansible inventory with the assigned public IP.
   - Execute Ansible playbooks to update the VM, install and configure WireGuard, set up iptables rules, and enable persistent IP forwarding.

## Versioning

This module follows [Semantic Versioning](https://semver.org/).

## License

This module is licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.
# Terraform Module: AVD with Entra ID

This Terraform module sets up an Azure Virtual Desktop (AVD) environment with Entra ID authentication. It includes all the necessary resources for deploying AVD and ensures seamless integration with Entra ID for secure user access. It deploys FSLogix profiles to a blob Storage Account with a private endpoint.

## Usage

```hcl
module "avd-entra-id" {
  source = "../modules/avd-entra-id"
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `resource_group_name` | `string` | `n/a` | The name of the resource group |
| `location` | `string` | `n/a` | The location/region where the resources will be created |
| `suffix` | `string` | `n/a` | A suffix for the resources |
| `address_space_start_ip` | `string` | `n/a` | The address space that is used the virtual network |
| `address_space_size` | `number` | `n/a` | The address space that is used the virtual network |
| `subnets` | `map(object({` | `n/a` | No description |
| `session_host_count` | `number` | `n/a` | The number of session hosts to create |
| `session_host_vm_size` | `string` | `n/a` | The size of the session host VMs |
| `session_host_local_admin_username` | `string` | `n/a` | The local admin username for the session hosts |
| `session_host_local_admin_password` | `string` | `n/a` | The local admin password for the session hosts |
| `user_group_id` | `string` | `n/a` | The ID of the user group |
| `tags` | `map(string)` | `n/a` | A map of tags to add to all resources |
| `workspace_description` | `string` | `n/a` | The description of the workspace |
| `workspace_name` | `string` | `n/a` | The name of the workspace |
| `workspace_friendly_name` | `string` | `n/a` | The friendly name of the workspace |
| `hostpool_name` | `string` | `n/a` | The name of the host pool |
| `hostpool_type` | `string` | `n/a` | The type of the host pool |
| `hostpool_load_balancer_type` | `string` | `n/a` | The load balancer type of the host pool |
| `hostpool_custom_rdp_properties` | `string` | `n/a` | The custom RDP properties of the host pool |
| `hostpool_maximum_sessions_allowed` | `number` | `n/a` | The maximum sessions allowed for the host pool |
| `hostpool_start_vm_on_connect` | `bool` | `n/a` | Whether to start VM on connect for the host pool |
| `application_group_default_desktop_display_name` | `string` | `n/a` | The default desktop display name of the application group |
| `application_group_description` | `string` | `n/a` | The description of the application group |
| `application_group_friendly_name` | `string` | `n/a` | The friendly name of the application group |
| `application_group_name` | `string` | `n/a` | The name of the application group |
| `application_group_type` | `string` | `n/a` | The type of the application group |
| `nsg_name` | `string` | `n/a` | The name of the network security group |
| `nat_gateway_name` | `string` | `n/a` | The name of the NAT gateway |
| `nat_gateway_pip_name` | `string` | `n/a` | The name of the public IP for the NAT gateway |
| `vnet_name` | `string` | `n/a` | The name of the virtual network |
| `session_host_name` | `string` | `n/a` | The name of the session host |
| `storage_account_name` | `string` | `n/a` | The name of the storage account |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group` | The Azure Resource Group |
| `workspace` | The Azure Virtual Machine workspace resource |
| `hostpool` | The Azure Virtual Machine host pool resource |
| `application_group` | The Azure Virtual Machine application group resource |
| `subnets` | The subnets within the virtual network |
| `nsg` | The Network Security Group resource |
| `nat_gateway` | The NAT Gateway resource |
| `storage_account` | The Storage Account resource |
| `private_dns_zone` | The Private DNS Zone resource |
| `private_dns_zone_virtual_network_link` | The Private DNS Zone Virtual Network Link resource |

## Versioning
This module follows [Semantic Versioning](https://semver.org/).

## License
This module is licensed under the MIT License.

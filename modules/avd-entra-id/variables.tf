variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created"
}

variable "address_space_start_ip" {
  type        = string
  description = "The address space that is used the virtual network"
}

variable "address_space_size" {
  type        = number
  description = "The address space that is used the virtual network"
}

variable "subnets" {
  type = map(object({
    size                       = number
    has_nat_gateway            = bool
    has_network_security_group = bool
  }))
  description = "The subnets"
}

variable "session_host_count" {
  type        = number
  description = "The number of session hosts to create"
}

variable "session_host_vm_size" {
  type        = string
  description = "The size of the session host VMs"
}

variable "session_host_local_admin_username" {
  type        = string
  description = "The local admin username for the session hosts"
}

variable "session_host_local_admin_password" {
  type        = string
  description = "The local admin password for the session hosts"
  sensitive   = true
}

variable "user_group_id" {
  type        = string
  description = "The ID of the user group"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}

variable "workspace_description" {
  type        = string
  description = "The description of the workspace"
}

variable "workspace_name" {
  type        = string
  description = "The name of the workspace"
}

variable "workspace_friendly_name" {
  type        = string
  description = "The friendly name of the workspace"
}

variable "hostpool_name" {
  type        = string
  description = "The name of the host pool"
}

variable "hostpool_type" {
  type        = string
  description = "The type of the host pool"
}

variable "hostpool_load_balancer_type" {
  type        = string
  description = "The load balancer type of the host pool"
}

variable "hostpool_custom_rdp_properties" {
  type        = string
  description = "The custom RDP properties of the host pool"
}

variable "hostpool_maximum_sessions_allowed" {
  type        = number
  description = "The maximum sessions allowed for the host pool"
}

variable "hostpool_start_vm_on_connect" {
  type        = bool
  description = "Whether to start VM on connect for the host pool"
}

variable "application_group_default_desktop_display_name" {
  type        = string
  description = "The default desktop display name of the application group"
}

variable "application_group_description" {
  type        = string
  description = "The description of the application group"
}

variable "application_group_friendly_name" {
  type        = string
  description = "The friendly name of the application group"
}

variable "application_group_name" {
  type        = string
  description = "The name of the application group"
}

variable "application_group_type" {
  type        = string
  description = "The type of the application group"
}

variable "nsg_name" {
  type        = string
  description = "The name of the network security group"
}

variable "nat_gateway_name" {
  type        = string
  description = "The name of the NAT gateway"
}

variable "nat_gateway_pip_name" {
  type        = string
  description = "The name of the public IP for the NAT gateway"
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "session_host_name" {
  type        = string
  description = "The name of the session host"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
}
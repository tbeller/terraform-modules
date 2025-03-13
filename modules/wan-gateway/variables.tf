variable "wan_gateway_name" {
    description = "The name of the WAN gateway."
    type        = string
}

variable "location" {
    description = "The location where the resources will be created."
    type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group."
    type        = string
}

variable "wan_subnet_id" {
    description = "The ID of the subnet for the WAN gateway."
    type        = string
}

variable "wan_gateway_ip" {
    description = "The static private IP address for the WAN gateway."
    type        = string
}

variable "wan_vm_size" {
    description = "The size of the virtual machine for the WAN gateway."
    type        = string
}

variable "admin_user" {
    description = "The admin username for the virtual machine."
    type        = string
}

variable "public_key" {
    description = "The public SSH key for the admin user."
    type        = string
}
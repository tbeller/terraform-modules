variable "session_host_count" {
    description = "The number of session hosts to create."
    type        = number
}

variable "resource_group_name" {
    description = "The name of the resource group in which to create the session hosts."
    type        = string
}

variable "location" {
    description = "The location where the resource will be created."
    type        = string
}

variable "name" {
    description = "The base name for the session hosts and network interfaces."
    type        = string
}

variable "subnet_id" {
    description = "The ID of the subnet to which the network interface will be attached."
    type        = string
}

variable "vm_size" {
    description = "The size of the session host."
    type        = string
}

variable "local_admin_username" {
    description = "The local administrator username for the session hosts."
    type        = string
}

variable "local_admin_password" {
    description = "The local administrator password for the session hosts."
    type        = string
    sensitive   = true
}

variable "hostpool_name" {
    description = "The name of the host pool to which the session hosts will be added."
    type        = string
}

variable "registration_info_token" {
    description = "The registration info token for the DSC extension."
    type        = string
    sensitive   = true
}

variable "tags" {
    description = "A mapping of tags to assign to the resource."
    type        = map(string)
}

variable "storage_account_name" {
    description = "The name of the storage account."
    type        = string
}

variable "storage_account_connection_string" {
    description = "The connection string for the storage account."
    type        = string
    sensitive   = true
}
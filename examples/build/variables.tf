# General
# -------

# Tagging
variable "tags" {
  description = <<EOD
  Tag information to be assigned to resources created. 
  Module resources are named using product, region and environment values"
EOD
  type = object({
    product           = string
    cost_center       = string
    environment       = string
    region            = string
    owner             = string
    technical_contact = string
  })

  default = {
    product           = "cloudauto"
    portfolio         = "core"
    environment       = "devtest"
    region            = "westus"
    cost_center       = "001245"
    owner             = "Diehlabs"
    technical_contact = "devops@diehlabs.com"
    azdo_repo         = "<repo-name>"
  }
}

variable "vm_admin_user" {
  default     = "vmss_user"
  type        = string
  description = "Virtual machine user name"
}

variable "create_vmss_custom" {
  default     = false
  type        = bool
  description = <<EOD
  Set to true in order to provision an Linux VM scale set with some specific options.
  Will require var create_resource_group set true to create a resource group 
  and provide it to the VMSS module. 
EOD
}
variable "create_resource_group" {
  default     = false
  type        = bool
  description = "Indicates to create an enabling tech resource group."
}

variable "unique_id" {
  description = "A unique identifier for use in resource names."
  type        = string
  default     = null
}
# variable "create_identity" {
#   default     = false
#   type        = bool
#   description = "Indicates to create an azurerm_user_assigned_identity."
# }

# Network

variable "subnet_name" {
  type        = string
  description = "The name of the subnet"
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet"
}

variable "network_resource_group_name" {
  type        = string
  description = "The name of the vnet"
}

# VM scalet set
variable "vm_node_count" {
  default     = 1
  type        = number
  description = "The number of instances to create for VM scale set environment."
}

variable "vm_user" {
  default     = "vmss_user"
  type        = string
  description = "Virtual machine user name"
}

variable "create_public_key" {
  default     = true
  type        = bool
  description = "Indicates to create an tls_private_key."
}

variable "vm_public_key" {
  default     = null
  type        = string
  description = "Virtual machine public key for authentication (2048-bit ssh-rsa)"
}

variable "vm_userdata_script" {
  default = null
  type    = string
}

variable "extensions" {
  description = "list of extensions"
  type        = map(any)
  default     = {}
}

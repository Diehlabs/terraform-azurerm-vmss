# General
# -------

# Provider
# --------
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
}

variable "extra_tags" {
  description = "Optional extra tags to be assigned to resources."
  type        = map(string)
  default     = {}
}

variable "resource_group" {
  description = <<EOD
  (Optional) the resource group object to create resources in.
  One will be created if none is provided.
EOD
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = null
    location = null
  }
}
variable "unique_id" {
  description = "A unique identifier for use in resource names."
  type        = string
  default     = null
}

variable "zones" {
  default     = []
  type        = list(string)
  description = "Azure zones to use for applicable resources"
}

variable "create_marketplace_agreement" {
  default     = false
  type        = bool
  description = <<EOD
  "To create the acknowledge for legal terms of the image. 
  Needs to be enable just the first time you deployed your VM scale set
  Later you need to disabled to avoid existing agreement errors"
EOD  
}
variable "load_balancer_type" {
  default     = "none"
  type        = string
  description = "Expected value of 'application_gateway' or 'load_balancer'"
  validation {
    condition = (
      var.load_balancer_type == "application_gateway" ||
      var.load_balancer_type == "load_balancer" ||
      var.load_balancer_type == "none"
    )

    error_message = "The load_balancer_type value must be 'application_gateway' or 'load_balancer' or 'none' (for no load balancer) ."
  }
}

# Load balancer
# -------------
variable "load_balancer_backend_id" {
  type        = string
  description = "The backend address pool ID of the load balancer or application gateway"
  default     = null
}


# Vm
# --
variable "vm_node_count" {
  default     = 1
  type        = number
  description = "The number of instances to create for VMSS environment."
}

variable "vm_userdata_script" {
  description = <<EOD
  "(Optional) Specifies custom data to supply to the machine. 
    On Linux-based systems, this can be used as a cloud-init script. 
    On other systems, this will be copied as a file on disk. 
    Internally, Terraform will base64 encode this value before sending it to the API. 
    The maximum length of the binary array is 65535 bytes."
  EOD

  default = null
  type    = string
}

variable "vm_subnet_id" {
  type        = string
  description = "Network subnet id for vm"
}

variable "vm_admin_user" {
  default     = null
  type        = string
  description = "Virtual machine user name"
}

variable "vm_public_key" {
  default     = null
  type        = string
  description = "Virtual machine ssh public key"
}

# Optional variables not currently specified in root module
variable "vm_overprovision" {
  default = false
  type    = bool
}

variable "vm_sku" {
  default     = "Standard_D4_v3"
  type        = string
  description = "Azure virtual machine sku"
}
#setting to 'automatic' based on Control ID: Azure_VirtualMachineScaleSet_SI_Enable_Auto_OS_Upgrade & Azure_VirtualMachineScaleSet_SI_Latest_Model_Applied
variable "vm_upgrade_mode" {
  default     = "Automatic"
  type        = string
  description = "Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling. Defaults to Manual."
}

variable "vm_zone_balance" {
  default     = true
  type        = bool
  description = "Should the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones? Defaults to false. Changing this forces a new resource to be created."
}

variable "vm_os_disk_caching" {
  default     = "ReadWrite"
  type        = string
  description = "The type of Caching which should be used for this Data Disk. Possible values are None, ReadOnly and ReadWrite."
}

variable "vm_os_disk_storage_account_type" {
  default     = "StandardSSD_LRS"
  type        = string
  description = "The Type of Storage Account which should back this Data Disk. Possible values include Standard_LRS, StandardSSD_LRS, Premium_LRS and UltraSSD_LRS."
}

variable "vm_os_disk_disk_size_gb" {
  default     = 100
  type        = number
  description = "The size of the Data Disk which should be created."
}

variable "identity_id" {
  default     = null
  type        = string
  description = "identity id string which should be assigned to the Linux Virtual Machine Scale Set"
}
variable "extensions" {
  description = "list of extensions"
  type        = map(any)
  default     = {}
}

variable "disable_automatic_rollback" {
  description = "Automatic rollback in case of failure"
  type        = bool
  default     = false
}

variable "enable_automatic_os_upgrade" {
  description = "Automatic OS patches can be applied by Azure to your scaleset"
  type        = bool
  default     = false
}

variable "custom_image" {
  description = "VM Image"
  type = object({
    image_name              = string
    purchase_plan_name      = string
    purchase_plan_product   = string
    purchase_plan_publisher = string
  })
  default = null
}

variable "shared_image_gallery" {
  type = object({
    gallery_name        = string
    resource_group_name = string
  })
  default = null
}
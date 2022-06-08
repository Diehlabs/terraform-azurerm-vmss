data "azurerm_client_config" "current" {}

# Azure linux virtual machine scale 
# -------------------------------
# Very basic scale set
# Module will generate (using tags values provided to name the generated resources):
# - resource group
# - azurerm_user_assigned_identity
# - VM scale set (see module variables for properties default)
# - ApplicationHealthLinux extension
module "vmss" {
  source = "../.."
  providers = {
    azurerm.axle = azurerm.axle
  }
  # VM
  unique_id     = var.unique_id
  vm_admin_user = var.vm_admin_user
  vm_public_key = local.vm_public_key
  vm_subnet_id  = data.azurerm_subnet.vmss_subnet.id
  vm_node_count = var.vm_node_count
  # we found that markpet place agreement needs to be created one time, 
  # for subsecuent terraform applies it generated conflicts with the existing one
  # create_marketplace_agreement = true 
  tags = local.tags
}

# A custom linux vm scale set example
# -------------------------------
# requires variables set to true:  
# var.create_vmss_custom 
# var.create_resource_group 

# uncomment azurerm_user_assigned_identity.generated at dependencies.tf

# Parent modules will generate (using tags values provided to name the generated resources)
# and pass to child Linux VMSS module as variables:
# - an azure resource group
# - azurerm_user_assigned_identity
# - vm_userdata_script a script to be used at cloudinit
#
# Module will generate (using tags values provided to nam the generated resources):
# - VM scale set (see module variables for properties default)
# - ApplicationHealthLinux extension
module "vmss_custom" {
  count  = var.create_vmss_custom == true ? 1 : 0 // this is for testing, not required for configuration
  source = "../.."
  providers = {
    azurerm.axle = azurerm.axle
  }

  vm_node_count = 2
  # requires var.create_resource_group set to true
  resource_group     = local.resource_group_info
  vm_userdata_script = local.vm_userdata_script

  # work in progress
  # identity_id        = local.identity_generated

  # any other VM scale set property can go here, like:
  # vm_os_disk_disk_size_gb = 200
  # vm_overprovision = true

  # VM
  unique_id     = "custom"
  vm_admin_user = var.vm_admin_user
  vm_public_key = local.vm_public_key
  vm_subnet_id  = data.azurerm_subnet.vmss_subnet.id

  # we found that markpet place agreement needs to be created one time,   
  # for subsecuent terraform applies it generated conflicts with the existing one
  # create_marketplace_agreement = true
  tags = local.tags

  depends_on = [
    module.enablingtech_rg
  ]
}

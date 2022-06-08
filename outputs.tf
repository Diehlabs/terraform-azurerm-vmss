output "linux_virtual_machine_scale_set_name" {
  description = "The name of the Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "linux_virtual_machine_scale_set_id" {
  description = "The resource ID of the Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "linux_virtual_machine_scale_set_identity_id" {
  description = "The identity ID of the linux Virtual Machine Scale Set. (expecting one identity was provided as parameter or provisioned by the module) "
  value       = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].identity_ids
}

output "linux_virtual_machine_scale_set_identity_type" {
  description = "The identity type of the linux Virtual Machine Scale Set. (expecting one identity was provided as parameter or provisioned by the module) "
  value       = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].type
}

output "linux_virtual_machine_scale_set_resource_group_name" {
  description = "The resource group of the Linux Virtual Machine Scale Set."
  value       = var.resource_group.name == null ? module.resource_group.rg.name : var.resource_group.name
}

# output "admin_ssh_key_public" {
#   description = "The generated public key data in PEM format"
#   value       = azurerm_linux_virtual_machine_scale_set.vmss.admin_ssh_key_public
# }

# output "admin_ssh_key_private" {
#   description = "The generated private key data in PEM format"
#   sensitive   = true
#   value       = azurerm_linux_virtual_machine_scale_set.vmss.admin_ssh_key_private
# }

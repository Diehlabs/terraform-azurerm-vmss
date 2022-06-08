output "linux_virtual_machine_scale_set_name" {
  description = "The name of the Linux Virtual Machine Scale Set."
  value       = module.vmss.linux_virtual_machine_scale_set_name
}

output "linux_virtual_machine_scale_set_id" {
  description = "The resource ID of the Linux Virtual Machine Scale Set."
  value       = module.vmss.linux_virtual_machine_scale_set_id
}

output "linux_virtual_machine_scale_set_identity_type" {
  description = "the identity type of the Linux Virtual Machine Scale Set. (expecting one identity was provided as parameter or provisioned by the module)"
  value       = module.vmss.linux_virtual_machine_scale_set_identity_type
}

output "linux_virtual_machine_scale_set_identity_id" {
  description = "the identity ID of the Linux Virtual Machine Scale Set. (expecting one identity was provided as parameter or provisioned by the module)"
  value       = module.vmss.linux_virtual_machine_scale_set_identity_id
}


output "linux_virtual_machine_scale_set_resource_group_name" {
  description = "The resource group of the Linux Virtual Machine Scale Set."
  value       = module.vmss.linux_virtual_machine_scale_set_resource_group_name
}


# output "admin_ssh_key_public" {
#   description = "The generated public key data in PEM format"
#   value       = module.vmss.admin_ssh_key_public
# }

# output "admin_ssh_key_private" {
#   description = "The generated private key data in PEM format"
#   sensitive   = true
#   value       = module.vmss.admin_ssh_key_private
# }

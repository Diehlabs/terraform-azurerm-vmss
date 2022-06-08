locals {
  tags = var.tags

  tags_extra = {}

  userdata_script    = base64encode("env")
  vm_userdata_script = var.vm_userdata_script == null ? local.userdata_script : var.vm_userdata_script

  base_resource_group_name = replace(lower("${var.tags.product}-${var.tags.region}-${var.tags.environment}-rg"), " ", "-")
  resource_group_name      = var.unique_id == null ? local.base_resource_group_name : "${local.base_resource_group_name}-custom"

  # work in progress 
  # identity_name      = replace(lower("${var.tags.region}-${var.tags.environment}-${var.tags.product}-vmss-userIdentity-generated"), " ", "-")
  # identity_generated = azurerm_user_assigned_identity.generated.id 
  # identity_generated = var.create_identity == true ? azurerm_user_assigned_identity.generated[0].id : null

  vm_public_key = var.create_public_key == true ? tls_private_key.vmss_ssh[0].public_key_openssh : var.vm_public_key

  resource_group_info = var.create_resource_group == true ? (
    {
      name     = module.enablingtech_rg[0].rg.name
      location = module.enablingtech_rg[0].rg.location
    }
    ) : (
    {
      name     = null
      location = null
    }
  )
}
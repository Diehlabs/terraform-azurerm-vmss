resource "azurerm_user_assigned_identity" "vmss-identity" {
  count               = var.identity_id == null ? 1 : 0
  location            = module.resource_group.rg.location
  resource_group_name = module.resource_group.rg.name
  name                = local.identity_name
  tags                = var.tags
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = local.vmss_name
  location            = module.resource_group.rg.location
  resource_group_name = module.resource_group.rg.name

  overprovision                   = var.vm_overprovision
  instances                       = var.vm_node_count
  sku                             = var.vm_sku
  admin_username                  = var.vm_admin_user
  upgrade_mode                    = var.vm_upgrade_mode
  zone_balance                    = local.zone_balance
  zones                           = local.zones
  tags                            = var.tags
  disable_password_authentication = true
  custom_data                     = var.vm_userdata_script

  #SRD Control ID: Azure_VirtualMachineScaleSet_SI_Enable_Auto_OS_Upgrade
  automatic_os_upgrade_policy {
    disable_automatic_rollback  = var.disable_automatic_rollback
    enable_automatic_os_upgrade = var.enable_automatic_os_upgrade
  }
  identity {
    type         = "UserAssigned"
    identity_ids = local.identity_to_use
  }

  os_disk {
    caching              = var.vm_os_disk_caching
    storage_account_type = var.vm_os_disk_storage_account_type
    disk_size_gb         = var.vm_os_disk_disk_size_gb
  }
  network_interface {
    name    = "${local.vmss_name}-nic"
    primary = true

    ip_configuration {
      name      = "${local.vmss_name}-ip"
      primary   = true
      subnet_id = var.vm_subnet_id

      # load balancing options
      load_balancer_backend_address_pool_ids       = var.load_balancer_type == "load_balancer" ? [var.load_balancer_backend_id] : null
      application_gateway_backend_address_pool_ids = var.load_balancer_type == "application_gateway" ? [var.load_balancer_backend_id] : null
    }
  }

  dynamic "admin_ssh_key" {
    for_each = var.vm_admin_user == null || var.vm_public_key == null ? [] : [1]
    content {
      username   = var.vm_admin_user
      public_key = var.vm_public_key
    }
  }

  source_image_id = data.azurerm_shared_image_version.azdo_agent.id
  plan {
    name      = var.custom_image == null ? local.templates.ubuntu_azdo_agent.purchase_plan_name : var.custom_image.purchase_plan_name
    product   = var.custom_image == null ? local.templates.ubuntu_azdo_agent.purchase_plan_product : var.custom_image.purchase_plan_product
    publisher = var.custom_image == null ? local.templates.ubuntu_azdo_agent.purchase_plan_publisher : var.custom_image.purchase_plan_publisher
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "extensions" {
  for_each                     = local.extensions
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  name                         = each.key
  publisher                    = each.value.publisher
  type_handler_version         = each.value.type_handler_version
  type                         = each.value.type
  auto_upgrade_minor_version   = lookup(each.value, "auto_upgrade_minor_version", true)
  settings                     = lookup(each.value, "settings", null)
  automatic_upgrade_enabled    = lookup(each.value, "automatic_upgrade_enabled", false)
  force_update_tag             = lookup(each.value, "force_update_tag", null)
  protected_settings           = lookup(each.value, "protected_settings", null)
  provision_after_extensions   = lookup(each.value, "provision_after_extensions", [])
}

data "azurerm_shared_image_version" "azdo_agent" {
  provider            = azurerm.axle
  name                = "latest"
  image_name          = var.custom_image == null ? local.templates.ubuntu_azdo_agent.image_name : var.custom_image.image_name
  gallery_name        = var.shared_image_gallery == null ? local.sig.gallery_name : var.shared_image_gallery.gallery_name
  resource_group_name = var.shared_image_gallery == null ? local.sig.resource_group_name : var.shared_image_gallery.resource_group_name

}
################################################
# This is to acknowledge legal terms of the image
# Removing this block will result in the error below:
# Before the subscription can be used, you need to accept the legal terms of the image. To read and accept legal terms, use the Azure CLI commands described at https://go.microsoft.com/fwlink/?linkid=2110637
################################################
resource "azurerm_marketplace_agreement" "azdo_agent" {
  count     = var.create_marketplace_agreement == true ? 1 : 0
  publisher = var.custom_image == null ? local.templates.ubuntu_azdo_agent.purchase_plan_publisher : var.custom_image.purchase_plan_publisher
  offer     = var.custom_image == null ? local.templates.ubuntu_azdo_agent.purchase_plan_product : var.custom_image.purchase_plan_product
  plan      = var.custom_image == null ? local.templates.ubuntu_azdo_agent.purchase_plan_name : var.custom_image.purchase_plan_name
}

locals {
  tags = merge(var.extra_tags, var.tags)

  base_resource_group_name = "${var.tags.product}-${var.tags.region}-${var.tags.environment}-rg"

  resource_group_name = var.resource_group.name == null ? (
    var.unique_id == null ? (
      replace(lower(local.base_resource_group_name), " ", "-")
      ) : (
      replace(lower("${local.base_resource_group_name}-${var.unique_id}"), " ", "-")
    )
    ) : (
    var.resource_group.name
  )

  vmss_base_name = replace(lower("${var.tags.product}-${var.tags.region}-${var.tags.environment}-vmss"), " ", "-")
  vmss_name      = var.unique_id == null ? local.vmss_base_name : "${local.vmss_base_name}-${var.unique_id}"

  // to make optional availability zones options
  zones_provided = length(var.zones) > 0 ? true : false
  zone_balance   = local.zones_provided ? var.vm_zone_balance : false
  zones          = local.zones_provided ? var.zones : null

  identity_name   = replace(lower("${var.tags.region}-${var.tags.environment}-${var.tags.product}-vmss-userIdentity"), " ", "-")
  identity_to_use = var.identity_id == null ? [azurerm_user_assigned_identity.vmss-identity[0].id] : [var.identity_id]

  extensions = merge(
    var.extensions,
    #SRD Control ID: Azure_VirtualMachineScaleSet_Audit_Enable_Diagnostics
    #https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/diagnostics-linux-v3?toc=/azure/azure-monitor/toc.json
    #this needs a storage account
    # {
    #     diagnostics = {
    #       name                       = "${local.vmss_name}-linuxDiagnostic"
    #       publisher                  = "Microsoft.Azure.Diagnostics"
    #       type                       = "LinuxDiagnostic"
    #       auto_upgrade_minor_version = true
    #       type_handler_version       = "1.0"
    #       settings                   = <<SETTINGS
    #         {
    #     "ladCfg": {
    #         "diagnosticMonitorConfiguration": {},
    #     }
    #   }
    #     SETTINGS
    #       protected_settings         = <<SETTINGS
    #   {
    #       "storageAccountName": "${var.storage_account_name}",
    #       "storageAccountSasToken": "${data.azurerm_storage_account_sas.linux_oms.sas}",
    #   }
    #   SETTINGS
    #   }
    # },
    #SRD Control ID: Azure_VirtualMachineScaleSet_DP_Enable_Disk_Encryption
    #this needs a keyvault
    # {
    #   encrpytion = {
    #     name                       = "${local.vmss_name}-encryption"
    #     publisher                  = "Microsoft.Azure.Security"
    #     type                       = "AzureDiskEncryptionForLinux"
    #     auto_upgrade_minor_version = true
    #     type_handler_version       = "1.1"
    #     # settings = jsonencode({
    #     # "AADClientID"            = "[aadClientID]",
    #     # "DiskFormatQuery"        = "[diskFormatQuery]",
    #     # "EncryptionOperation"    = "[encryptionOperation]",
    #     # "KeyEncryptionAlgorithm" = "[keyEncryptionAlgorithm]",
    #     # "KeyEncryptionKeyURL"    = "[keyEncryptionKeyURL]",
    #     # "KeyVaultURL"            = "[keyVaultURL]",
    #     # "SequenceVersion"        = "sequenceVersion]",
    #     # "VolumeType"             = "[volumeType]"
    #     # })
    # } },
    #SRD Control ID: Azure_VirtualMachineScaleSet_SI_Enable_Auto_OS_Upgrade. Health check is required for automatic OS image upgrade
    {
      healthcheck = {
        name                       = "${local.vmss_name}-health"
        publisher                  = "Microsoft.ManagedServices"
        type                       = "ApplicationHealthLinux"
        auto_upgrade_minor_version = true
        type_handler_version       = "1.0"
        settings = jsonencode({
          "protocol" : "http",
          "port" : 80,
          "requestPath" : "/_health_check"
        })
    } }
  )

  sig = {
    gallery_name        = "<sig-name>"
    resource_group_name = "eastus2-hub-vm-sig-rg"
  }

  vm_userdata_script = base64encode("env")

  templates = {
    ubuntu_azdo_agent = {
      image_name              = "non_standard_azdo_agent"
      purchase_plan_name      = "cis-ubuntu2004-l1"
      purchase_plan_product   = "cis-ubuntu-linux-2004-l1"
      purchase_plan_publisher = "center-for-internet-security-inc"
    }
  }

}

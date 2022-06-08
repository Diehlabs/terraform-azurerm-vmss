terraform {
  //required_version = "~> 1.0.0"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">=2.95.0"
      configuration_aliases = [azurerm.axle]
    }
  }
}

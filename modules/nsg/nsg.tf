variable "name" {}
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_network_security_group" "nsg" {
    name                        = var.name
    location                    = var.location
    resource_group_name         = var.resource_group_name
}  
variable "rule_name" {}
variable "priority" {}
variable "direction"{}
variable "access" {}
variable "protocol" {}
variable "source_port_ranges" {}
variable "destination_port_ranges" {}
variable "source_address_prefix" {}
variable "destination_address_prefix" {}
variable "resource_group_name" {}
variable "network_security_group_name" {}

resource "azurerm_network_security_rule" "nsg_rule" {
    name                        = var.rule_name
    priority                    = var.priority
    direction                   = var.direction
    access                      = var.access
    protocol                    = var.protocol
    source_port_ranges          = var.source_port_ranges 
    destination_port_ranges     = var.destination_port_ranges
    source_address_prefix       = var.source_address_prefix
    destination_address_prefix  = var.destination_address_prefix
    resource_group_name         = var.resource_group_name
    network_security_group_name = var.network_security_group_name
}
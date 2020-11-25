variable "nic_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "ip_config_name" {}
variable "subnet_id" {}
variable "private_ip_address_allocation" {}
variable "vm_name" {}
variable "size" {}
variable "admin_username" {}
variable "admin_password" {}
variable "network_interface_ids" {}
variable "caching" {}
variable "storage_account_type" {}
variable "publisher" {}
variable "offer" {}
variable "sku" {}
variable "image_version" {}

resource "azurerm_network_interface" "nic" {
    name                                = var.nic_name
    location                            = var.location
    resource_group_name                 = var.resource_group_name

    ip_configuration {
        name                            = var.ip_config_name
        subnet_id                       = var.subnet_id
        private_ip_address_allocation   = var.private_ip_address_allocation
    }
}

resource "azurerm_linux_virtual_machine" "linux" {
    name                                = var.vm_name
    location                            = var.location
    resource_group_name                 = var.resource_group_name
    size                                = var.size
    admin_username                      = var.admin_username
    admin_password                      = var.admin_password
    network_interface_ids               = var.network_interface_ids
    disable_password_authentication     = false

    os_disk {
        caching                         = var.caching
        storage_account_type            = var.storage_account_type
    }

    source_image_reference {
        publisher                       = var.publisher
        offer                           = var.offer
        sku                             = var.sku
        version                         = var.image_version
    }
}


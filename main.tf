## Main Terraform code created to run on Version 13.5, latest version as of 11/2020
## Functions with AzureRM Version 2.37.0, latest version as of 11/2020
## Dated 11/23/2020
## Creates Vnet, Subnet and Virtual Machine using backend remote state.
## Hard-coding is avoided, Modules are used. 

provider "azurerm" {
    version = "=2.37.0"
    features {}
}

# Import existing storage account where state file will be stored
data "azurerm_storage_account" "storage" {
    name                                = var.storage_account_name
    resource_group_name                 = var.storage_rg
}

# Import existing Key Vault
data "azurerm_key_vault" "vault" {
    name                                = var.vault
    resource_group_name                 = var.storage_rg
}

# Linux admin password import
data "azurerm_key_vault_secret" "vault_secret" {
    name                                = "lnx-fingerprint"
    key_vault_id                        = data.azurerm_key_vault.vault.id 
}

# Configure backend remote state
terraform {
  backend "azurerm" {
    resource_group_name                 = "remote-state"
    storage_account_name                = "forstore"
    container_name                      = "tfstate"
    key                                 = "vm.tfstate"        
  }
}

# Create Resource Group for vnet,subnet,nsg and virtual machine 
module "deploy_resource_group" {
    source                              = "./modules/resource-group"
    name                                = "${var.project_prefix}-rg"
    location                            = var.location    
}

# Create Virtual Network in US West 2
module "deploy_vnet" {
    source                              = "./modules/vnet"
    name                                = "${var.project_prefix}-vnet"
    location                            = var.location
    resource_group_name                 = module.deploy_resource_group.name 
    address_space                       = ["192.168.0.0/24"]
}

# Create Subnet in vm-project-vnet
module "deploy_subnet" {
    source                              = "./modules/subnet"
    name                                = "${var.project_prefix}-subnet"
    resource_group_name                 = module.deploy_resource_group.name 
    virtual_network_name                = module.deploy_vnet.name 
    address_prefixes                    = ["192.168.0.0/26"]
}

# Create network security group
module "deploy_nsg" {
    source                              = "./modules/nsg"
    name                                = "${var.project_prefix}-nsg"
    location                            = var.location
    resource_group_name                 = module.deploy_resource_group.name
}

# Allow SSH rule
module "deploy_nsg_rule" {
    source                              = "./modules/nsg-rules"
    rule_name                           = "Allow SSH"
    priority                            = "100"
    direction                           = "Inbound"
    access                              = "Allow"
    protocol                            = "Tcp"
    source_port_ranges                  = ["22"]
    destination_port_ranges             = ["22"]
    source_address_prefix               = "*"
    destination_address_prefix          = "*"
    resource_group_name                 = module.deploy_resource_group.name
    network_security_group_name         = module.deploy_nsg.name
}

# Create a linux virtual machine
module "deploy_linux_vm" {
    source                              = "./modules/linux-vm"
    nic_name                            = "${var.project_prefix}-nic"
    location                            = var.location
    resource_group_name                 = module.deploy_resource_group.name 
    ip_config_name                      = "${var.project_prefix}-ip"
    subnet_id                           = module.deploy_subnet.id 
    private_ip_address_allocation       = "Dynamic"
    vm_name                             = "${var.project_prefix}-lnx"
    size                                = "Standard_B1s"
    admin_username                      = "lnxadmin"
    admin_password                      = data.azurerm_key_vault_secret.vault_secret.value
    network_interface_ids               = [module.deploy_linux_vm.nic_id]
    caching                             = "ReadWrite"
    storage_account_type                = "Standard_LRS"
    publisher                           = "Canonical"
    offer                               = "UbuntuServer"
    sku                                 = "16.04-LTS"
    image_version                       = "latest"  
}
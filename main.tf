## Main Terraform code created to run on Version 13.5, latest version as of 11/2020
## Functions with AzureRM Version 2.37.0, latest version as of 11/2020
## Dated 11/23/2020
## Creates Vnet, Subnet and Virtual Machine using backend remote state.
## Hard-coding is avoided, Modules are used. 

provider "azurerm" {
    version = "=2.37.0"
    features {}
}

# Import storage account where state file will be stored
data "azurerm_storage_account" "storage" {
    name                    = var.storage_account_name
    resource_group_name     = var.storage_rg
}

# Configure backend remote state
terraform {
  backend "azurerm" {
    resource_group_name     = "remote-state"
    storage_account_name    = "hakanstorage1"
    container_name          = "tfstate"
    key                     = "vm.tfstate"        
  }
}

module "deploy_resource_group" {
    source                  = "./modules/resource-group"
    name                    = "${var.project_prefix}-rg"
    location                = var.location    
}

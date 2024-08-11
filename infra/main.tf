terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "backend"
      storage_account_name = "backendthni7"
      container_name       = "backend"
      key                  = "tests/azure_task/basic.tfstate"
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
}

data  "external" "git_origin" {
  program = [ "bash", "-c", "echo \"{ \\\"Origin\\\": \\\"$(git config --get remote.origin.url)\\\"}\"" ]
}
locals {
  default_tags = {
      GitRepo = replace(replace(data.external.git_origin.result.Origin, "/(http.*@)/", ""), "%20", " ")
  }
}

module "linuxserver_1" {
  source              = "./modules/vm"
  name                = "primary"
  deletion_protection = true
  tags                = local.default_tags
}

module "linuxserver_2" {
  source              = "./modules/vm"
  name                = "secondary"
  deletion_protection = true
  tags                = local.default_tags
}
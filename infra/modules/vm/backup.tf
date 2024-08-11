resource "random_string" "random" {
  length           = 5
  special          = false
  
}

resource "azurerm_recovery_services_vault" "vm" {
  name                = "${random_string.random.result}-r-v-${terraform.workspace}"
  location            = azurerm_resource_group.azure_task.location
  resource_group_name = azurerm_resource_group.azure_task.name
  sku                 = "Standard"
}


resource "azurerm_backup_policy_vm" "vm" {
  name                = "${random_string.random.result}-r-v-p-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.azure_task.name
  recovery_vault_name = azurerm_recovery_services_vault.vm.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 10
  }
}

resource "azurerm_backup_protected_vm" "vm1" {
  resource_group_name = azurerm_resource_group.azure_task.name
  recovery_vault_name = azurerm_recovery_services_vault.vm.name
  source_vm_id        = azurerm_linux_virtual_machine.primary.id
  backup_policy_id    = azurerm_backup_policy_vm.vm.id
}
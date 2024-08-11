resource "azurerm_resource_group" "azure_task_primary" {
  name     = "azure_task_primary_${terraform.workspace}"
  location = "UK South"
}

resource "azurerm_linux_virtual_machine" "primary" {
  name                = "primary-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.azure_task_primary.name
  location            = azurerm_resource_group.azure_task_primary.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.primary.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.vm.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = var.tags
}


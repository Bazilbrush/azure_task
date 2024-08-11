resource "azurerm_virtual_network" "vm" {
  name                = "${var.name}-network_${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure_task.location
  resource_group_name = azurerm_resource_group.azure_task.name
}

resource "azurerm_subnet" "vm" {
  name                 = "${var.name}-internal_${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.azure_task.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.name}-nic_${terraform.workspace}"
  location            = azurerm_resource_group.azure_task.location
  resource_group_name = azurerm_resource_group.azure_task.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}
resource "azurerm_public_ip" "vm" {
  name                         = "${var.name}-pip_${terraform.workspace}"
  location                     = azurerm_resource_group.azure_task.location
  resource_group_name          = azurerm_resource_group.azure_task.name
  allocation_method            = "Dynamic"
}
resource "azurerm_network_security_group" "vm" {
  name                = "${var.name}_vm_${terraform.workspace}"
  location            = azurerm_resource_group.azure_task.location
  resource_group_name = azurerm_resource_group.azure_task.name
  tags = var.tags

}
resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_network_security_rule" "allow_http_https_out" {
  name                        = "allow_http_https_out"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_task.name
  network_security_group_name = azurerm_network_security_group.vm.name
}
resource "azurerm_network_security_rule" "allow_dns_out" {
  name                        = "allow_dns_out"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_ranges     = ["53"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_task.name
  network_security_group_name = azurerm_network_security_group.vm.name
}
resource "azurerm_network_security_rule" "allow_ssh_jack" {
  name                        = "allow_ssh_jack"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "81.77.68.70/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_task.name
  network_security_group_name = azurerm_network_security_group.vm.name
}
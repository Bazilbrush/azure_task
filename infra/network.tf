resource "azurerm_virtual_network" "primary" {
  name                = "primary-network_${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure_task_primary.location
  resource_group_name = azurerm_resource_group.azure_task_primary.name
}

resource "azurerm_subnet" "primary" {
  name                 = "internal-primary_${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.azure_task_primary.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "primary" {
  name                = "primary-nic_${terraform.workspace}"
  location            = azurerm_resource_group.azure_task_primary.location
  resource_group_name = azurerm_resource_group.azure_task_primary.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.primary.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.primary.id
  }
}
resource "azurerm_public_ip" "primary" {
  name                         = "primary-pip_${terraform.workspace}"
  location                     = azurerm_resource_group.azure_task_primary.location
  resource_group_name          = azurerm_resource_group.azure_task_primary.name
  allocation_method            = "Dynamic"
}
resource "azurerm_network_security_group" "primary" {
  name                = "primary_vm_${terraform.workspace}"
  location            = azurerm_resource_group.azure_task_primary.location
  resource_group_name = azurerm_resource_group.azure_task_primary.name
  tags = local.default_tags

}
resource "azurerm_subnet_network_security_group_association" "primary" {
  subnet_id                 = azurerm_subnet.primary.id
  network_security_group_id = azurerm_network_security_group.primary.id
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
  resource_group_name         = azurerm_resource_group.azure_task_primary.name
  network_security_group_name = azurerm_network_security_group.primary.name
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
  resource_group_name         = azurerm_resource_group.azure_task_primary.name
  network_security_group_name = azurerm_network_security_group.primary.name
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
  resource_group_name         = azurerm_resource_group.azure_task_primary.name
  network_security_group_name = azurerm_network_security_group.primary.name
}
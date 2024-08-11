resource "tls_private_key" "vm" {
    algorithm = "RSA"
    rsa_bits = 2048
}

data "azurerm_key_vault" "shared" {
  name                = "sharedsw0ho"
  resource_group_name = "shared"
}
resource "azurerm_key_vault_secret" "vm_private" {
  name = "${random_string.random.result}-private-key-${terraform.workspace}"
  value = tls_private_key.vm.private_key_pem
  key_vault_id = data.azurerm_key_vault.shared.id
}

resource "azurerm_key_vault_secret" "vm_public" {
    name = "${random_string.random.result}-public-key-${terraform.workspace}"
    value = tls_private_key.vm.public_key_openssh
     key_vault_id = data.azurerm_key_vault.shared.id
}

# resource "local_file" "private_key" {
#     content = tls_private_key.vm.private_key_pem
#     filename = "${path.module}/integration.pem"
#     file_permission = "0600"
# }
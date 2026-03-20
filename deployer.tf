resource "azurerm_user_assigned_identity" "deployer" {
  name                = "deployer-${local.resource_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

// Allow deployer to manage the function app
resource "azurerm_role_assignment" "deployer_contributor" {
  scope                = azurerm_linux_function_app.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.deployer.principal_id
}

// Allow deployer to upload to the storage account
resource "azurerm_role_assignment" "deployer_storage" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.deployer.principal_id
}

resource "azurerm_user_assigned_identity" "app" {
  name                = local.resource_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

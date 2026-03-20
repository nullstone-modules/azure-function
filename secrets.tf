resource "azurerm_key_vault" "app" {
  name                = substr(replace(local.resource_name, "/[^a-zA-Z0-9-]/", ""), 0, 24)
  location            = var.location
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.app.principal_id

    secret_permissions = ["Get", "List"]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "app_secret" {
  for_each = nonsensitive(local.managed_secret_values)

  name         = lower(replace("${local.resource_name}-${each.key}", "/[^a-zA-Z0-9-]/", "-"))
  value        = sensitive(each.value)
  key_vault_id = azurerm_key_vault.app.id
  tags         = local.tags
}

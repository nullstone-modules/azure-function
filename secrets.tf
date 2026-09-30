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
  for_each = data.ns_env_layout.this.managed_secret_keys

  name         = lower(replace("${local.resource_name}-${each.key}", "/[^a-zA-Z0-9-]/", "-"))
  value        = data.ns_env_values.this.secrets[each.key]
  key_vault_id = azurerm_key_vault.app.id
  tags         = local.tags
}

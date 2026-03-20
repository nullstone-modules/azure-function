// Storage account required by Azure Functions for triggers and state
resource "azurerm_storage_account" "this" {
  // Storage account names must be 3-24 chars, lowercase alphanumeric only
  name                     = substr(replace(lower(local.resource_name), "/[^a-z0-9]/", ""), 0, 24)
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

// App Service Plan (consumption or dedicated)
resource "azurerm_service_plan" "this" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = local.tags
}

// Azure Function App (Linux)
resource "azurerm_linux_function_app" "this" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id
  tags                       = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  site_config {
    application_stack {
      node_version    = var.runtime == "node" ? var.runtime_version : null
      python_version  = var.runtime == "python" ? var.runtime_version : null
      dotnet_version  = var.runtime == "dotnet" ? var.runtime_version : null
      java_version    = var.runtime == "java" ? var.runtime_version : null
    }

    app_scale_limit = var.max_instances

    // VNet integration for private subnet access
    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = local.private_subnet_ids[0]

  app_settings = local.all_env_vars

  lifecycle {
    ignore_changes = [
      // Ignore changes to app settings managed by deployment tools
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

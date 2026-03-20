output "function_app_id" {
  value       = azurerm_linux_function_app.this.id
  description = "string ||| The ID of the Azure Function App."
}

output "function_app_name" {
  value       = azurerm_linux_function_app.this.name
  description = "string ||| The name of the Azure Function App."
}

output "function_app_hostname" {
  value       = azurerm_linux_function_app.this.default_hostname
  description = "string ||| The default hostname of the Azure Function App."
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "string ||| The name of the storage account backing the function app."
}

output "deployer" {
  value = {
    subscription_id = local.subscription_id
    client_id       = try(azurerm_user_assigned_identity.deployer.client_id, "")
  }

  description = "object({ subscription_id: string, client_id: string }) ||| An Azure identity with explicit privilege to deploy this function app."
}

output "log_provider" {
  value       = "azuremonitor"
  description = "string ||| The log provider used for this service."
}

output "private_urls" {
  value       = local.private_urls
  description = "list(string) ||| A list of URLs only accessible inside the network"
}

output "public_urls" {
  value       = local.public_urls
  description = "list(string) ||| A list of URLs accessible to the public"
}

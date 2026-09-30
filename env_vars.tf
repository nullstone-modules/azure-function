variable "env_vars" {
  type        = map(string)
  default     = {}
  description = <<EOF
The environment variables to inject into the function app.
These are typically used to configure a function per environment.
EOF
}

variable "secrets" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = <<EOF
The sensitive environment variables to inject into the function app.
EOF
}

locals {
  standard_env_vars = tomap({
    NULLSTONE_STACK         = data.ns_workspace.this.stack_name
    NULLSTONE_APP           = data.ns_workspace.this.block_name
    NULLSTONE_ENV           = data.ns_workspace.this.env_name
    NULLSTONE_VERSION       = data.ns_app_env.this.version
    NULLSTONE_COMMIT_SHA    = data.ns_app_env.this.commit_sha
    NULLSTONE_PUBLIC_HOSTS  = join(",", local.public_hosts)
    NULLSTONE_PRIVATE_HOSTS = join(",", local.private_hosts)
  })
  azure_env_vars = tomap({
    AZURE_SUBSCRIPTION_ID = local.subscription_id
    AZURE_CLIENT_ID       = azurerm_user_assigned_identity.app.client_id
  })

  // Azure injects these into every function app; they are reported, not added to the app settings
  platform_env_vars = tomap({
    WEBSITE_SITE_NAME = local.resource_name
  })
  cloud_env_vars = merge(local.azure_env_vars, local.platform_env_vars)
}

// ns_env_layout classifies secrets using keys only, so the set of secrets to add to key vault is known at plan time
data "ns_env_layout" "this" {
  platform         = "azure_function"
  standard_keys    = keys(local.standard_env_vars)
  cloud_keys       = keys(local.cloud_env_vars)
  user_env         = var.env_vars
  user_secret_keys = nonsensitive(keys(var.secrets))
}

data "ns_env_values" "this" {
  platform     = "azure_function"
  standard     = local.standard_env_vars
  cloud        = local.cloud_env_vars
  user_env     = var.env_vars
  user_secrets = var.secrets
}

// ns_env_platform_data records where each managed secret lives so Nullstone can display the environment
data "ns_env_platform_data" "this" {
  values     = data.ns_env_values.this.platform_data
  secret_ids = { for key, secret in azurerm_key_vault_secret.app_secret : key => secret.versionless_id }
}

locals {
  // A platform variable reaches the app settings only when the user overrides it
  app_settings = {
    for k, v in data.ns_env_values.this.env_variables : k => v
    if !(contains(keys(local.platform_env_vars), k) && data.ns_env_values.this.sources[k] == "cloud")
  }
}

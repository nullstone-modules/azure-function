variable "location" {
  type        = string
  description = "Azure region to deploy resources."
}

variable "runtime" {
  type        = string
  description = <<EOF
The runtime stack for the function app.
Azure Functions supports: node, dotnet, java, python, powershell, custom.
Examples: "node", "python", "dotnet", "java"
See https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages for full support schedule.
EOF
}

variable "runtime_version" {
  type        = string
  description = <<EOF
The version of the runtime stack.
Examples: "18" (node), "3.11" (python), "8.0" (dotnet), "17" (java)
EOF
}

variable "sku_name" {
  type        = string
  default     = "Y1"
  description = <<EOF
The SKU for the App Service Plan.
Y1 = Consumption (serverless, pay-per-execution)
B1 = Basic (always-on, dedicated)
S1 = Standard (production workloads)
P1v2 = Premium v2 (enhanced performance)
EP1 = Elastic Premium (VNET integration, pre-warmed instances)
EOF
}

variable "max_instances" {
  type        = number
  default     = 3
  description = "The maximum number of instances for the function app when scaling."
}

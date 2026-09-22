variable "name_prefix" {
  description = "The prefix used for all resources in this example."
  type        = string
}

variable "location" {
  description = "The region where these resources should be deployed."
  type        = string
}

variable "tags" {
  description = "A mapping of tags which should be applied to each of the resources."
  type        = map(string)
  default     = {}
}

variable "cosmos_auth_mode" {
  description = "How the app authenticates to Cosmos: \"aad\" (managed identity) or \"key\" (primary key)."
  type        = string
  default     = "aad"
  validation {
    condition     = contains(["aad", "key"], var.cosmos_auth_mode)
    error_message = "cosmos_auth_mode must be \"aad\" or \"key\"."
  }
}

variable "app_service_sku" {
  description = "App Service plan SKU."
  type        = string
  default     = "B1"
}

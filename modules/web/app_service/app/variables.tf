variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "location" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "(optional) describe your variable"
  default     = null
}
variable "app_service_plan_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "dotnet_framework_version" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "scm_type" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "key_vault_reference_identity_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "site_config" {
  type        = any
  description = "(optional) describe your variable"
  default     = {}
}
variable "app_settings" {
  type        = map(any)
  description = "(optional) describe your variable"
  default     = {}
}
variable "connection_string" {
    type = map(object({
        name           = string
        type = string
        value = string
     }))
}
variable "identity" {
  type        = any
  description = "(required) describe your variable"
  default = "SystemAssigned"
}
variable "subnet_id" {
  type = string
  description = "(optional) describe your variable"
  default = null
}
variable "tags" {
  type        = map(any)
  description = "(required) describe your variable"
  default = {
    environment = "dev"
    owner       = "IT"
  }
}
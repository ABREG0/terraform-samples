
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
variable "kind" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "tier" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "size" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "maximum_elastic_worker_count" {
  type        = string
  description = "(optional) describe your variable"
  default     = null
}
variable "per_site_scaling" {
  type        = bool
  description = "(required) describe your variable"
  default     = null
}
variable "zone_redundant" {
  type        = bool
  description = "(required) describe your variable"
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(required) describe your variable"
  default = {
    environment = "dev"
    owner       = "IT"
  }
}
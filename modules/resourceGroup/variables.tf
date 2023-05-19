variable "location" {
  description = "location in which to deploy these resources"
  default     = ""
}

variable "name" {
  description = "Name of the Resource Group in which to deploy these resources"
  #   default     = "RG-Prod-USW2-CA"
  default = ""
}
variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}
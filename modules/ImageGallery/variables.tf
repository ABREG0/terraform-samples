variable "gallery_name" {
  description = "Name of the gallery to deploy"
  default     = "gallerydevops01"
}
variable "image_name" {
  description = "Name of the image to deploy"
  default     = "win10wvd-image"
}

variable "image_publisher" {
  description = "Publisher for the image to deploy"
  default     = "MicrosoftWindowsDesktop"
}
variable "image_offer" {
  description = "Offer for the image to deploy"
  default     = "Windows-10"
}
variable "image_sku" {
  description = "Sku for the image to deploy"
  default     = "21h1-evd"
}

variable "region" {
  description = "Region in which to deploy these resources"
  default     = "West US 2"
}

variable "resource_group_name" {
  description = "Name of the Resource Group in which to deploy these resources"
#   default     = "RG-Prod-USW2"
  default     = "RG-Test-USW2"
}

# variable "resource_group2_name" {
#   description = "Name of the Resource Group in which to deploy these resources"
# #   default     = "RG-Prod-USW2-CA"
#   default     = "DSHD_Network"
# }
locals {
  parse_object = { for top_index, top_value in {
    for k, v in var.object : k => "${k} = ${v}"

    }  : "cmk" => top_value...
                
  } 
}

output "parse_object" {
  value = local.parse_object
}

variable "object" {
  type = object({
    keyId = string
    uami = string
    name  = string
    version = string
  })
  default = {
    
    keyId = "key_resource_id"
    uami = "uami_id"
    name  = "name"
    version = "version"
  }
}
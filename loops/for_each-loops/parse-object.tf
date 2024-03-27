
# using this for variable type objects
resource "null_resource" "cluster" {
    
    for_each = length(var.objectVariable) > 0 ? {this = var.objectVariable} : {}
    triggers = {

        key_id = each.value["cmk_key_secret_id"]
        infrastructure = each.value["cmk_key_secret_id"] != null ? each.value["cmk_key_secret_id"] : null 
        user_assignm_managed_identity = each.value["user_assignm_managed_identity"] != null ? each.value["user_assignm_managed_identity"] : null
        system_managed_identity = each.value["user_assignm_managed_identity"] != null ? false : true
    
    }
}
output "null_ouput" {
  value = null_resource.cluster
}
variable "objectVariable" {
  type = object({
    cmk_key_secret_id = optional(string, null)
    user_assignm_managed_identity = optional(string, null)
  })
  default = {
    
    cmk_key_secret_id = "url_to_each_key"
    user_assignm_managed_identity = "uami_resource_id"
  }
}
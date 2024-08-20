
# using this for variable type objects
resource "null_resource" "cluster" {
    
    for_each = length(var.objectVariable) > 0 && var.objectVariable["cmk_key_secret_id"] != null ? {this = var.objectVariable} : {}
    triggers = {

        key_id = each.value["cmk_key_secret_id"] != null ? each.value["cmk_key_secret_id"] : "notSet"
        infrastructure = each.value["cmk_key_secret_id"] != null ? each.value["cmk_key_secret_id"] : "notSet" 
        user_assignm_managed_identity = each.value["user_assignm_managed_identity"] != null ? each.value["user_assignm_managed_identity"] : "notSet"
        system_managed_identity = each.value["user_assignm_managed_identity"] != null ? false : true
    
    }
}
output "null_ouput" {
  value = null_resource.cluster
}
output "test_varLenght" {
  value = length({this = var.objectVariable})
}
variable "objectVariable" {
  type = object({
    cmk_key_secret_id = optional(string, null)
    user_assignm_managed_identity = optional(string, null)
  })
  default = {}
}
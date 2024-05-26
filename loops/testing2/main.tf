
locals {
    workload_policy = { for top_key in flatten([
        for kk, kv in var.workload_policy : {
        kk = kv
        }
    ]) : "policy" => top_key ...} #   ]) : "${top_key.count}-${top_key.weekdays}" => top_key }
    protection_policy = { for top_key in flatten([
        for kk, kv in local.workload_policy : [
        kv
        ]
        # if local.workload_policy.policy.workload_type == "SQLDataBase"
    ])  : "protection" => top_key ...}
}

output "v" {
  value = local.protection_policy
}
/*
# using this for variable type objects
resource "null_resource" "cluster" {
    
    for_each = local.diff
    # {for key_index, value in var.backups_config: 
    #             "${key_index}" => value
    #             if (value.policy_type == "Differential" || var.backup_frequency == "Weekly")
    #             }

    triggers = {

            protection_policy = each.key
            frenquency = each.value.protection_policy
    }
}
*/
variable "workload_policy" {
  type = map(object({
    name = string
    resource_group_name = string
    recovery_vault_name = string
    workload_type = string
    settings = object({
      time_zone = string
      compression_enabled = bool
    })
    
    backup_frequency     = string
    protection_policy = map(object({
      policy_type = string # description = "(required) Specify policy type. Full, Differential, Logs"
      retention_daily_count = number
      retention_weekly = optional(object({
        count    = optional(number)
        weekdays = optional(list(string))
      }), {})
      # retention_daily = optional(number, null) # (Required) The count that is used to count retention duration with duration type Days. Possible values are between 7 and 35.
      backup = optional(object({
        time          = optional(string)
        frequency_in_minutes = optional(number)
        weekdays      = optional(list(string))
      }), {})

      retention_monthly = optional(object({
        count             = optional(number, null)
        weekdays          = optional(list(string), [])
        weeks             = optional(list(string), [])
        monthdays              = optional(list(number), [])
        include_last_days = optional(bool, false)
      }), {})

      retention_yearly = optional(object({
        count             = optional(number, null)
        months            = optional(list(string), [])
        weekdays          = optional(list(string), [])
        weeks             = optional(list(string), [])
        monthdays              = optional(list(number), [])
        include_last_days = optional(bool, false)
      }), {})
    
    }))
  }))
  default = {
    sqlworkload = {
      name                           = "pol-rsv-sql-vault-001"
      resource_group_name            = "rg_name"
      recovery_vault_name            = "vault_name"
      workload_type = "SQLDataBase"
      settings = {
        time_zone = "Pacific Standard Time"
        compression_enabled = false  
      }
      backup_frequency = "Daily" # Daily or Weekly
      protection_policy = {
        
        log = {
          policy_type = "Log"
          retention_daily_count = 15
          backup = {        
            frequency_in_minutes = 15
            time = "22:00"
            weekdays      = ["Tuesday", "Saturday", "Wednesday"]
          }
        }
        full = {
          policy_type = "Full"
          backup = {
            time          = "22:00"
            weekdays      = ["Tuesday", "Saturday", "Friday"]
          }
          retention_daily_count = 15
          retention_weekly = {
            count    = 10
            weekdays = ["Tuesday", "Saturday"]
          }
          retention_monthly = {
            count = 10
            weekdays =  ["Wednesday","Friday", "Monday"]
            weeks = ["First","Third"]
            monthdays = [3, 10, 20]
          }
          retention_yearly = {
            count  = 10
            months = ["January", "June", "October", "March"]
            # weekdays =  ["Thursday","Monday"]
            weeks = ["First", "Second","Third"]
            monthdays = [3, 10, 20]
          }

        }
        Differential = {
          policy_type = "Differential"
          retention_daily_count = 12
          backup = {
            time          = "22:00"
            weekdays      = ["Wednesday", "Friday"]
          }
        }
        
      }
    }
  }
  description = "(Required)"
}

locals {
    diff = {for key_index, value in var.backups_config: 
                "${key_index}" => value
                if (value.policy_type == "Differential" && var.backup_frequency == "Weekly")
                }
    log_full = {for key_index, value in var.backups_config: 
                "${key_index}" => value
                if (value.policy_type != "Differential")
                }
    backup = merge(local.diff, local.log_full)

}

# using this for variable type objects
resource "null_resource" "cluster" {
    
    for_each = local.backup
    # {for key_index, value in var.backups_config: 
    #             "${key_index}" => value
    #             if (value.policy_type == "Differential" || var.backup_frequency == "Weekly")
    #             }

    triggers = {

            policy_type = each.value["policy_type"]
            frenquency = var.backup_frequency
    }
}

variable "backups_config" {
  type = map(object({
    policy_type = string # description = "(required) Specify policy type. Full, Differential, Logs"
    # retention_daily = optional(number, null) # (Required) The count that is used to count retention duration with duration type Days. Possible values are between 7 and 35.
    backup = optional(object({
    #   frequency     = optional( string, null)
      time          = optional(string, null)
      frequency_in_minutes = optional(number, null)
      weekdays      = optional(list(string), [])
    }))

    retention_daily = optional(object({
      count    = optional(number, null) #(Required) The count that is used to count retention duration with duration type Days. Possible values are between 7 and 35.
    }), {})

    retention_weekly = optional(object({
      count    = optional(number, null)
      # weekdays = optional(list(string), null)
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
  default = {  
    log = {
      policy_type = "Log"
      retention_daily = {count = 10}
      backup = {        
        frequency_in_minutes = 60
        time = "23:00"
        weekdays      = ["Tuesday", "Saturday"]
      }
    }
    full = {
      policy_type = "Full"
      backup = {
        # frequency     = "Daily"
        time          = "22:00"
        weekdays      = ["Tuesday", "Saturday"]
      }
      retention_daily = {count = 10}
      retention_weekly = {
        count    = 10
        # weekdays = ["Tuesday", "Saturday"]

      }
      retention_monthly = {
        count = 10
        # weekdays =  ["Wednesday","Friday"]
        weeks = ["First","Third"]
        monthdays = [3, 10, 20]
      }
      retention_yearly = {
        count  = 10
        months = ["January", "June", "October"]
        # weekdays =  ["Thursday","Monday"]
        weeks = ["First","Third"]
        monthdays = [3, 10, 20]
      }

    }
    Differential = {
      policy_type = "Differential"
      retention_daily = {count = 10}
      backup = {
        # frequency     = "Weekly"
        time          = "22:00"
        weekdays      = ["Wednesday", "Friday"]
      }
    }
  }

  description = "(Required)"
}

variable "name" {
  type        = string
  description = "(required) Specify Name for Azure Recovery Services Vaults"
    default = "pol-rsv-vm-appName-001"
}
variable "resource_group_name" {
  type        = string
  description = "(required) Specify Name for Azure Resource Group"
    default = "rg-appNmae-001"
}
variable "recovery_vault_name" {
  type        = string
  description = "(required) Specify Azure Recovery Services Vault"
    default = "rsv-appNmae-001"
}
variable "workload_type" {
  type = string
  description = "(required) Specify Policy Workload type. SQLDataBase, SAPHanaDatabase"
  default = "SQLDataBase"
}
variable "settings" {
  type = object({
    time_zone = string
    compression_enabled = bool
  })
  description = "(required) Specify Policy setting"
  default = {
    time_zone = "Pacific Standard Time"
    compression_enabled = true  
  }
}
variable "timezone" {
  type = string
    default = "Pacific Standard Time" # "UTC" # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
}
variable "instant_restore_resource_group" {
  type = map(object({
    prefix = optional(string, null)
    suffix = optional(string, null)
  }))
  default = {
    first = {    
      prefix = "prefix-"
      suffix = null
    }
  }
}
variable "backup_frequency" {
  type = string
  default = "Weekly"
  description = "(Required) Specifiy bakcup frenquency. Log, Full, Differential"
}

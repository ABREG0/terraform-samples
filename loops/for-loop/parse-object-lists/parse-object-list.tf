
locals {
  flatten_at_top = flatten([
      for index_key, value in var.retentions : 
         value
    ])
  #   ]) : "${top_key.count}-${top_key.weekdays}" => top_key }

  backup_config = flatten([
    for index_key, value in local.flatten_at_top : 
    
      value["backup"]
  
    ] )
  retention_weekly = flatten([
    for index_key, value in local.flatten_at_top : 
    
      value["retention_weekly"]
  
    ] )
retentions_retention_weekly = flatten([ for top_key in flatten([
    for index_key, kv in var.retentions : [
      for rk, rv in kv.retention_weekly : {
        rk  = rk
        count         = index_key
        weekdays          = rk
      }
    ]
  ]) :  top_key ]) #   ]) : "${top_key.count}-${top_key.weekdays}" => top_key }

  parsin_retation = { for top_key, top_values in flatten([
    for index_key, kv in var.retentions : [
       kv.backup,
    #    "retention_daily = ${kv.retention_daily}"
    ]
  ]) : "backup" => {
        "topkey" = top_key
        "topValue" = top_values
        }
  } #   ]) : "${top_key.count}-${top_key.weekdays}" => top_key }
  get_backup = [ for top_key, top_values in flatten([
    for index_key, kv in var.retentions : [
       kv.backup,
    #    "retention_daily = ${kv.retention_daily}"
    ]
    ]) : top_values
  ] #   ]) : "${top_key.count}-${top_key.weekdays}" => top_key }

}

# output "flatten_at_top" {
#   value = local.flatten_at_top
# }
output "backup_flatten" {
  value = local.backup_config
}
output "retention_weekly" {
  value = local.retention_weekly
}
# output "parsin_retation" {
#   value = local.parsin_retation
# }
# output "get_backup" {
#   value = local.get_backup
# }

variable "retentions" {
  type = map(object({
    backup = object({
      frequency     = string
      time          = string
      hour_interval = optional(number, null)
      hour_duration = optional(number, null)
      weekdays      = optional(list(string), [])
    })
    retention_daily = optional(number, null)
    retention_weekly = optional(object({
      count    = optional(number, 7)
      weekdays = optional(list(string), [])
    }), {})
    retention_monthly = optional(object({
      count             = optional(number, 0)
      weekdays          = optional(list(string), [])
      weeks             = optional(list(string), [])
      days              = optional(list(number), [])
      include_last_days = optional(bool, false)
    }), {})
    retention_yearly = optional(object({
      count             = optional(number, 0)
      months            = optional(list(string), [])
      weekdays          = optional(list(string), [])
      weeks             = optional(list(string), [])
      days              = optional(list(number), [])
      include_last_days = optional(bool, false)
    }), {})
  }))
  default = {
   pol =  {
        backup = {
            frequency     = "Hourly"
            time          = "22:00"
            hour_interval = 6
            hour_duration = 12
            weekdays      = ["Tuesday", "Saturday"]
        }
        retention_daily = 7

        retention_weekly = {
                count    = 7
                weekdays = ["Monday", "Wednesday"]
        }
        retention_monthly = {
                count = 5
                weekdays =  ["Tuesday","Saturday"]
                weeks = ["First","Third"]
                days = [3, 10, 20]
        }
                retention_yearly = {
                count  = 5
                months = []
                weekdays =  ["Tuesday","Saturday"]
                weeks = ["First","Third"]
                days = [3, 10, 20]
        }
    }
  }
}
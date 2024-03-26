variable "list_string" {
  type = list(string)
  default = [ "first", "second", "monday", "sunday" ]
}

locals {
  # [] produces a list type as a result
  parse_list_make_list = [for key_index, value in var.list_string: "index[${key_index}]=value[${value}]"]
  list_to_set = toset(local.parse_list_make_list) # no need to do this because the above result is the same
  # remove 'first' from list
  filter_first_string_out = [for key_index, value in var.list_string: "index[${key_index}]=value[${value}]" if value != "first"]
  # remove 'first' from list
  filter_only_keep_sunday = [for key_index, value in var.list_string: "index[${key_index}]=value[${value}]" if value == "sunday"]

  # {} produces a map
  parse_list_make_map_object = {for key_index, value in var.list_string: "${key_index}-index" => upper(value) }
#   map_to_set = toset(local.parse_list_make_map_object) # errors out, can't conver map/objects to sets/lists

  # make a list from created map/obj 
  parse_object_make_list = [for index, value in local.parse_list_make_map_object: value ]

}

output "parse_list_make_list" {
  value = local.parse_list_make_list
  description = "outputs map created from list of strings by for loop"
}
output "filter_first_string_out" {
  value = local.filter_first_string_out
  description = "removing 'first' string out of the list"
}
output "filter_only_keep_sunday" {
  value = local.filter_only_keep_sunday
  description = "keeping 'sunday' string only from the list"
}

output "parse_list_make_map_object" {
  value = local.parse_list_make_map_object
  description = "outputs map created from list of strings by for loop"
}
output "parse_object_make_list" {
  value = local.parse_object_make_list
}

/*
for index or key values: The index or key symbol is always optional. If you specify only a single symbol after the for keyword then that symbol will always represent the value of each element of the input collection.
result type []or {}: The type of brackets around the for expression decide what type of result it produces. 
*/
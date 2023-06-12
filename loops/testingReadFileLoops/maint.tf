variable "fileToParse" {
  type = string
  default = "platform"
}
locals {
    template_file_vars = {}
    empty_list = []
    builtin_library_path = "${path.module}/lib"

  builtin_archetype_definitions_json = tolist(fileset(local.builtin_library_path, "**/*_def.{json,json.tftpl}"))
  builtin_archetype_definitions_yaml = tolist(fileset(local.builtin_library_path, "**/*_def.{yml,yml.tftpl,yaml,yaml.tftpl}"))

}
# Load the built-in archetype definitions from the internal library path
locals {
  builtin_files = {
    for filepath in local.builtin_archetype_definitions_json :
    filepath => "${local.builtin_library_path}/${filepath}"
    # if contains([filepath], "corp_def.json")
    if length(regexall(filepath, "corp_def.json platform_def.json")) != 0

  # + "corp_def.json",
  # + "platform_def.json",

    # filepath => jsondecode(templatefile("./lib", local.template_file_vars))
  }
  builtin_archetype_definitions_dataset_from_json = {
    for filepath in local.builtin_archetype_definitions_json :
    filepath => jsondecode(templatefile("${local.builtin_library_path}/${filepath}", local.template_file_vars))
    # if contains([filepath], "platform_def.json")

    # filepath => jsondecode(templatefile("./lib", local.template_file_vars))
  }
  builtin_archetype_definitions_map_from_json = {
    for key, value in local.builtin_archetype_definitions_dataset_from_json :
    keys(value)[0] => values(value)[0]
    # if contains([keys(value)[0]], "es_platform")
    if length(regexall(keys(value)[0], "es_corp es_platform")) != 0
  }
}

output "builtin_files" {
  value = local.builtin_files
}
output "all_files" {
  value = local.builtin_archetype_definitions_json
}
# output "builtin_archetype_definitions_dataset_from_json" {
#   value = local.builtin_archetype_definitions_dataset_from_json
# }

output "builtin_library_path" {
  value = "${path.module}/lib"
}

output "builtin_archetype_definitions_map_from_json" {
  value = local.builtin_archetype_definitions_map_from_json
}

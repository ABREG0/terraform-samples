variable "template_file_vars" {
  default = {
    name = "./lib"
    }
}
# The following locals are used to define the built-in
# library path, and determine whether a custom library
# path has been provided to enable conditional logic on
# loading configuration files from the library path(s).
locals {
  library_path = null
#   custom_library_path_specified = null
  empty_string = ""
  empty_list = []
  empty_map = {}
  template_file_vars = var.template_file_vars
}
locals {
  extend_archetype_definitions = merge(
    local.extend_archetype_definitions_map_from_json,
    local.extend_archetype_definitions_map_from_yaml,
  )
}

locals {
  builtin_library_path          = "${path.module}/lib"
  custom_library_path_specified = try(length(local.library_path) > 0, false)
  custom_library_path           = local.custom_library_path_specified ? replace(local.library_path, "//$/", local.empty_string) : null
}

# Load the built-in archetype definitions from the internal library path
locals {
  builtin_archetype_definitions_json = tolist(fileset(local.builtin_library_path, "**/archetype_definition_*.{json,json.tftpl}"))
  builtin_archetype_definitions_yaml = tolist(fileset(local.builtin_library_path, "**/archetype_definition_*.{yml,yml.tftpl,yaml,yaml.tftpl}"))
}

# Load the archetype definition extensions
locals {
  extend_archetype_definitions_json = local.custom_library_path_specified ? tolist(fileset(local.custom_library_path, "**/archetype_extension_*.{json,json.tftpl}")) : local.empty_list
  extend_archetype_definitions_yaml = local.custom_library_path_specified ? tolist(fileset(local.custom_library_path, "**/archetype_extension_*.{yml,yml.tftpl,yaml,yaml.tftpl}")) : local.empty_list
}

locals {
  builtin_archetype_definitions_dataset_from_json = {
    for filepath in local.builtin_archetype_definitions_json :
    filepath => jsondecode(templatefile("${local.builtin_library_path}/${filepath}", local.template_file_vars))
  }
  builtin_archetype_definitions_dataset_from_yaml = {
    for filepath in local.builtin_archetype_definitions_yaml :
    filepath => yamldecode(templatefile("${local.builtin_library_path}/${filepath}", local.template_file_vars))
  }
  extend_archetype_definitions_dataset_from_yaml = {
    for filepath in local.extend_archetype_definitions_yaml :
    filepath => yamldecode(templatefile("${local.custom_library_path}/${filepath}", local.template_file_vars))
  }
  extend_archetype_definitions_dataset_from_json = {
    for filepath in local.extend_archetype_definitions_json :
    filepath => jsondecode(templatefile("${local.custom_library_path}/${filepath}", local.template_file_vars))
  }
}

locals {
  builtin_archetype_definitions_map_from_json = {
    for key, value in local.builtin_archetype_definitions_dataset_from_json :
    keys(value)[0] => values(value)[0]
  }
  builtin_archetype_definitions_map_from_yaml = {
    for key, value in local.builtin_archetype_definitions_dataset_from_yaml :
    keys(value)[0] => values(value)[0]
  }
  extend_archetype_definitions_map_from_json = {
    for key, value in local.extend_archetype_definitions_dataset_from_json :
    keys(value)[0] => values(value)[0]
  }
  extend_archetype_definitions_map_from_yaml = {
    for key, value in local.extend_archetype_definitions_dataset_from_yaml :
    keys(value)[0] => values(value)[0]
  }
}

# Merge the archetype maps into a single map, and extract the desired archetype definition.
# If duplicates exist due to a custom archetype definition being
# defined to override a built-in definition, this is handled by
# merging the custom archetypes after the built-in archetypes.
locals {
  base_archetype_definitions = merge(
    local.builtin_archetype_definitions_map_from_json,
    local.builtin_archetype_definitions_map_from_yaml,
    # local.custom_archetype_definitions_map_from_json,
    # local.custom_archetype_definitions_map_from_yaml,
  )
}
# Add or remove configuration settings from an existing [built-in] or custom archetype definition.
# Get full description context in github #issue_72
locals {
  archetype_definitions = {
    for adk, adv in local.base_archetype_definitions :
    adk => {
      policy_assignments = [
        for value in distinct(concat(
          adv.policy_assignments,
          try(local.extend_archetype_definitions["extend_${adk}"].policy_assignments, local.empty_list)
        )) : value
        # if contains(try(local.exclude_archetype_definitions["exclude_${adk}"].policy_assignments, local.empty_list), value) != true
      ],
      policy_definitions = [
        for value in distinct(concat(
          adv.policy_definitions,
          try(local.extend_archetype_definitions["extend_${adk}"].policy_definitions, local.empty_list)
        )) : value
        # if contains(try(local.exclude_archetype_definitions["exclude_${adk}"].policy_definitions, local.empty_list), value) != true
      ],
      policy_set_definitions = [
        for value in distinct(concat(
          adv.policy_set_definitions,
          try(local.extend_archetype_definitions["extend_${adk}"].policy_set_definitions, local.empty_list)
        )) : value
        # if contains(try(local.exclude_archetype_definitions["exclude_${adk}"].policy_set_definitions, local.empty_list), value) != true
      ],
      role_definitions = [
        for value in distinct(concat(
          adv.role_definitions,
          try(local.extend_archetype_definitions["extend_${adk}"].role_definitions, local.empty_list)
        )) : value
        # if contains(try(local.exclude_archetype_definitions["exclude_${adk}"].role_definitions, local.empty_list), value) != true
      ],
      archetype_config = {
        parameters = merge(
          adv.archetype_config.parameters,
          try(local.extend_archetype_definitions["extend_${adk}"].archetype_config.parameters, local.empty_map)
        )
        access_control = merge(
          adv.archetype_config.access_control,
          try(local.extend_archetype_definitions["extend_${adk}"].archetype_config.access_control, local.empty_map)
        )
      }
    }
  }
}

# Extract the required archetype_definition value for the current context
locals {
  archetype_id = "id"
  archetype_definition = local.archetype_definitions #[local.archetype_id]
}
output "builtin_archetype_definitions_dataset_from_json" {
  value = local.builtin_archetype_definitions_dataset_from_json
}
output "builtin_archetype_definitions_json" {
  value = local.builtin_archetype_definitions_json
}
# output "builtin_archetype_definitions_dataset_from_json" {
#   value = local.builtin_archetype_definitions_dataset_from_json
# }
# output "archetype_definition" {
#   value = local.archetype_definition
# }

# output "base_archetype_definitions" {
#   value = local.base_archetype_definitions
# }

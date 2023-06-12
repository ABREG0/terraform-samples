module "testing_read_file_loops" {
  source = "./testingReadFileLoops"

  fileToParse = "corp" # "platform_def.json" #"corp"
}

output "builtin_archetype_definitions_dataset_from_json" {
  value = module.testing_read_file_loops.builtin_archetype_definitions_dataset_from_json
}
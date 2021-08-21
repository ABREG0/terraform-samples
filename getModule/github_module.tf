# download module from github
# repo gets downloade to \.terraform\modules\abrego_modules
module "abrego" {
  source = "github.com/ABREG0/terraform-samples/providers" #"github.com/ABREG0/ps-examples" - the module tf file are inside "providers" folder
#   var_one = "foo"
#   var_two = "bar"
}

module "sentinel" {
  source = "git::https://github.com/ABREG0/az-sentinel.git"
}

# module "storage" {
#   source = "git::ssh://username@example.com/storage.git"
# }

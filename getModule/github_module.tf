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

#Azure Devops repo
#    source              = "git::https://dev.azure.com/org/devProject/_git/repoName//folder1/base/resource_group?ref=mybranc-name"
#   module "resourcegroup" {
#   source              = "git::https://dev.azure.com/[org]/[project]/_git/terraform.module//azurerm/base/resource_group?ref=[BranchName or tagVer v1.2.3"
#   name                = "name"
#   location            = "eastus2"
# }

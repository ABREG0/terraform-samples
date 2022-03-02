variable "linux-vm" {
  default = {
    resource_group = {
      name     = "nix-vms-wu2-rg"
      location = ""
      exists   = false # true
    }
    vnet = {
      name                = "hub-westus2-vnet"
      resource_group_name = "vnets-westus2-rg"
      subnet_name         = "vmpublic"
    }
    enable_availability_set = true
    enable_vm_zones         = true
    set_vm_zones            = "1,2,3"
    enable_scale_set        = false
    #is_Linux_image          = true
    hostname                = "mynixclient"
    size                    = "Standard_B2ms"
    os_simple               = "RHEL"
    admin_password          = "This1SmyBestP@sswordEver"
    public_ip_dns           = [null]
    deploy_pip              = true
    allocation_method       = "Static"            # Dynamic or Static
    enable_ssh_key          = false               #if true fill .pub file below
    ssh_key                 = "pubkey/id_rsa.pub" #public key location "./id_rsa.pub" #
  }
}

variable "windows-vm" {
  default = {
    resource_group = {
      name     = "win-vms-wu2-rg"
      location = ""
      exists   = false # true
    }
    vnet = {
      name                = "hub-westus2-vnet"
      resource_group_name = "vnets-westus2-rg"
      subnet_name         = "vmpublic"
    }
    enable_availability_set = true
    enable_vm_zones         = true
    set_vm_zones            = "1,2,3"
    enable_scale_set        = false
    is_windows_image        = true
    hostname                = "mywinclient"
    size                    = "Standard_B2ms"
    os_simple               = "WindowsDesktop"
    admin_password          = "This1SmyBestP@sswordEver"
    public_ip_dns           = [null]
    deploy_pip              = true
    allocation_method       = "Static" # Dynamic or Static
  }
}

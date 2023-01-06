#cabrego 2021
# todo: add wsl with ubuntu, https://www.graphviz.org/download

write-host "Check if PS was launched as admin..." -ForegroundColor Yellow
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = $SCRIPT:MyInvocation.MyCommand.Path 

  write-host "check if PS was launched as admin... re-launching the script:  $($arguments) " -ForegroundColor Red
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  
  Break
} 
 else{
    Write-Host "PowerShell was Launched as Admin... " -ForegroundColor Green
 }

 $TLS12Protocol = [System.Net.SecurityProtocolType] 'Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

function Install-choco {
    Set-ExecutionPolicy Bypass -Scope Process -Force;

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    

}

function Install-azModule {

    Set-PSRepository -name 'PSGallery' -InstallationPolicy Trusted 
    $azModule  = $(cmd /c "C:\Program Files\PowerShell\7\pwsh.exe" -WorkingDirectory ~ -c {Get-InstalledModule -Name az -ErrorAction SilentlyContinue | Select-Object version})

    if($null -eq $azModule){

    write-host " az Module is NOT Installed... Installing Azure az module" -ForegroundColor red 
    start-process -FilePath "C:\Program Files\PowerShell\7\pwsh.exe" -WorkingDirectory ~  -ArgumentList '-c "& {"Az.Accounts","Az.Resources","Az.Compute","Az.Keyvault" | % {Install-Module -Name $_ -Scope AllUsers  -Repository PSGallery -Force -AllowClobber}}"'
    }
     else{

       write-host " Azure az module is installed... Version: $($azModule.Version)" -ForegroundColor Green 
     }
}


$vcExtentions = @'
4ops.terraform
amazonwebservices.aws-toolkit-vscode
azps-tools.azps-tools
bencoleman.armview
bierner.markdown-yaml-preamble
DavidAnson.vscode-markdownlint
donjayamanne.python-extension-pack
ed-elliott.azure-arm-template-helper
erd0s.terraform-autocomplete
garytyler.darcula-pycharm
GitHub.vscode-pull-request-github
golang.go
GrapeCity.gc-excelviewer
hashicorp.terraform
KnisterPeter.vscode-github
magicstack.MagicPython
mark-tucker.aws-cli-configure
mechatroner.rainbow-csv
mindaro-dev.file-downloader
mindginative.terraform-snippets
ms-azure-devops.azure-pipelines
ms-azuretools.vscode-azureappservice
ms-azuretools.vscode-azurefunctions
ms-azuretools.vscode-azureresourcegroups
ms-azuretools.vscode-azurestorage
ms-azuretools.vscode-azureterraform
ms-azuretools.vscode-azurevirtualmachines
ms-azuretools.vscode-bicep
ms-azuretools.vscode-cosmosdb
ms-azuretools.vscode-docker
ms-dotnettools.vscode-dotnet-runtime
ms-python.python
ms-python.vscode-pylance
ms-toolsai.jupyter
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode-remote.remote-wsl
ms-vscode-remote.vscode-remote-extensionpack
ms-vscode.azure-account
ms-vscode.azurecli
ms-vscode.notepadplusplus-keybindings
ms-vscode.powershell
ms-vscode.vscode-node-azure-pack
msazurermtools.azurerm-vscode-tools
redhat.vscode-commons
redhat.vscode-yaml
rosshamish.kuskus-kusto-syntax-highlighting
run-at-scale.terraform-doc-snippets
tht13.python
TomAustin.azure-devops-yaml-pipeline-validator
VisualStudioExptTeam.vscodeintellicode
yzhang.markdown-all-in-one
'@
function Add-vsCodeExtentions {
    param($vcExtentions)
  $vcExtentions = $vcExtentions -replace "`n", ''
  $vcExtentions = $vcExtentions.Split("`r")

  $vcExtentions.Count
  #Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }
  for ($i = 0; $i -lt $vcExtentions.Count; $i++) {
      $ext = "$($vcExtentions[$i])"
      Write-Host "Installing extention Name: $($vcExtentions[$i])"
      #& cmd /c code --install-extension $ext --force
      & pwsh -c "code --install-extension $ext --force"
  }
}

### todo ###
# install Authme (Two-factor authenticator)
############

Set-PSRepository -name 'PSGallery' -InstallationPolicy Trusted 

"Az.Accounts","Az.Resources","Az.Compute","Az.Keyvault" | % {Install-Module -Name $_ -Scope AllUsers  -Repository PSGallery -Force -AllowClobber}

Install-choco

choco install powershell-core --version=7.2.1 -y --force --force-dependencies
    
choco install azure-cli -y --force --force-dependencies

choco install vscode -y --force --force-dependencies

choco install git -y --force --force-dependencies

choco install terraform -y --force --force-dependencies

choco install googlechrome -y --force --force-dependencies

& refreshenv


Install-azModule
get-appxpackage Microsoft.WindowsTerminal -allusers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

wsl --install

DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V

#Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }

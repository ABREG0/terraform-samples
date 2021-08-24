#cabrego 2021
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
function Install-vscode {
    $vcodeVersion = @(code -v)[0]

    if($null -eq $vcodeVersion){
      Write-Host "vs code not installed... Installing"

      $url = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user'

      $destination = "$env:TEMP\vscode.exe"

      Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing

      Start-Process -Wait -FilePath $destination -ArgumentList '/VERYSILENT /NORESTART /MERGETASKS=!runcode,desktopicon,addcontextmenufiles,addcontextmenufolders'
      
      Remove-Item -Path $destination -Force
    }
    else{

      Write-Host "vs code version: $($vcodeVersion)"
    }
}
function Install-choco {
    Set-ExecutionPolicy Bypass -Scope Process -Force;

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    choco install powershell-core --version=7.1.1
    
    choco install azure-cli
    
    choco install vscode
    
    choco install git
    
    choco install terraform
}
function Install-psCore {

  $poshHub = 'https://github.com/PowerShell/PowerShell'

  $getSite = (Invoke-WebRequest -Uri $poshHub -UseBasicParsing)

  $LatestRelease = ($getSite.links.href -match 'releases/tag').split('/')[-1] -replace 'v',''

  $PSInstalled = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {($_.DisplayName -match "PowerShell [\d]-x" ) -and ($_.Displayversion -match $LatestRelease) }
  
  if($null -eq $PSInstalled){
    Write-Host " PS core is NOT installed...  Need to Install PowerShell Core latest version" -ForegroundColor Red

    $source = "$($poshHub)/releases/download/v$($LatestRelease)/PowerShell-$($LatestRelease)-win-x64.msi"

    $destination = "$env:TEMP\PowerShell-$($LatestRelease)-win-x64.msi"

    Invoke-webrequest -uri $source -outfile $destination -UseBasicParsing

    Write-Host "Installing Lastest version of Powershell core... $($LatestRelease)"

    $InstallArg = "/package $($destination) /qb ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1"

    Start-Process -FilePath msiexec -ArgumentList $InstallArg -wait

    Remove-Item $destination -Force
   }
   else{

   Write-Host " PS Core is Installed... `n version: $($PSInstalled.Displayversion)" -ForegroundColor Green
  }
}
function Install-azModule {
  pwsh -Command {

    write-host "PS version $($psversionTable.psversion)" -ForegroundColor red
    $azModule = Get-InstalledModule -Name az -ErrorAction SilentlyContinue
  
    #check for Azure az module
    if($null -eq $azModule){

    write-host "Installing Azure az module"
    #Install-Module -Name Az -Repository PSGallery -Force -AllowClobber

    }
     else{

       write-host "Azure az module is installed... Version: $($azModule.Version)"
     }
  }
}
function Install-GitWin {

  $gitHub = 'https://github.com'

  try {

    $gitVer = (git --version).split(' ')[-1]
  }
  catch {

    $gitVer = 0
  }
  
  $url = "$($gitHub)/git-for-windows/git"

  $getSite = (Invoke-WebRequest -Uri $url -UseBasicParsing)

  $LatestRelease = ($getSite.links.href -match 'releases/tag').split('/')[-1]

  if(($LatestRelease -replace 'v','') -eq $gitVer){

      Write-Host "Latest version of Git is installed... version: $($gitVer)"
  }
   else{

      Write-Host "Installed version: $($gitVer) `n Later version of Git is not installed... Installing... $LatestRelease" -ForegroundColor Red
      $gitWeb = (Invoke-WebRequest -Uri "$($gitHub)/git-for-windows/git/releases/tag/$($LatestRelease)" -UseBasicParsing)

      $source = "$($gitHub)$($gitWeb.Links.href -match 'git-\w.*\W.*-64-bit.exe')"

      $destination = "$env:TEMP\$($source.Split('/')[-1])"
      
      Invoke-webrequest -uri $source -outfile $destination -UseBasicParsing

      Start-Process -Wait -FilePath $destination -ArgumentList "/VERYSILENT /NORESTART /COMPONENTS=icons,icons\desktop,ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh,autoupdate" # /LOG=`"%WINDIR%\Temp\$($source.Split('/')[-1]).log`""
      
      Remove-Item -Path $destination -Force 
  }
}
Function Install-AzureCLI {
    try {

      $azVersion = @(az version) | ConvertFrom-Json

      $InstalledCLI = $azVersion.'azure-cli' 
    }
    catch {

      $InstalledCLI = 0  
    }  

    $cliHub = 'https://github.com/Azure/azure-cli'

    $getSite = (Invoke-WebRequest -Uri $cliHub -UseBasicParsing)

    $LatestRelease = ($getSite.links.href -match 'releases/tag').split('/')[-1] -replace 'azure-cli-',''

    if($LatestRelease -ne $InstalledCLI){

      $source = 'https://aka.ms/installazurecliwindows'

      $destination = "$env:TEMP\AzureCLI-$($LatestRelease)-win.msi"

      Write-Host "`nDownloading Azure CLI to current folder"
      Invoke-WebRequest -Uri $source -OutFile $destination -UseBasicParsing ; 

      Write-Host "`nInstalling Azure CLI from current folder"
      Start-Process msiexec.exe -Wait -ArgumentList "/I $destination /qb" 

      Write-Host "`nRemove Azure CLI from current folder"
      Remove-Item $destination -Force
    }
    else{

      Write-Host "Azure CLI is Installed... `n version: $($InstalledCLI)" -ForegroundColor Green
     }
}
function Install-Terraform {
    
    $Url = 'https://www.terraform.io/downloads.html'
    
    try {

      $terraformPath = $ENV:Path -split ';' | Where-Object { $_ -match 'terraform'}

      $tfVersion = @(terraform -v) | Where-Object{$_ -match 'terraform'} | ForEach-Object{"$($_ -replace 'terraform v')"}
    }
    catch {

      $terraformPath = $null
    }

    if(($null -eq $terraformPath) -and ($null -eq $tfVersion)){

        $terraformPath = 'C:\Terraform\'

        $envRegpath = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'

        $PathString = (Get-ItemProperty -Path $envRegpath -Name PATH).Path

        $PathString += ";$($terraformPath)"

        $null = New-Item -Path $($terraformPath) -ItemType Directory -Force 

        $source = (Invoke-WebRequest -Uri $url -UseBasicParsing).links.href | Where-Object {$_ -match 'windows_amd64'}

        $destination = "$env:TEMP\$(Split-Path -Path $source -Leaf)"

        Invoke-WebRequest -Uri $source -OutFile $destination -UseBasicParsing
        
        Expand-Archive -Path $destination -DestinationPath $terraformPath -Force

        Remove-Item -Path $destination -Force

        Set-ItemProperty -Path $envRegpath -Name PATH -Value $PathString

        $ENV:Path += ";$($terraformPath)"
      }
      else{

        Write-Host "Terraform is Installed... version: $($tfVersion)"
      }
}

Install-AzureCLI

Install-psCore

Install-GitWin

Install-Terraform

Install-vscode

Install-azModule

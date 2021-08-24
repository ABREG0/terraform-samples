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

Install-psCore
Install-azModule
 
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

Install-AzureCLI
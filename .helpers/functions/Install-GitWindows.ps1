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

function Install-GitWin {
  $gitHub = 'https://github.com'

  $url = "$($gitHub)/git-for-windows/git"

  $getSite = (Invoke-WebRequest -Uri $url -UseBasicParsing)

  $LatestRelease = ($getSite.links.href -match 'releases/tag').split('/')[-1]

try {

  $gitVer = (git --version).split(' ')[-1]

}
catch {

  $gitVer = 0
}

if(($LatestRelease -replace 'v','') -eq $gitVer){

    Write-Host " Latest version of Git is installed... version: $($gitVer)" -ForegroundColor Green
}
 else{

    Write-Host " Latest version of Git is NOT Installed... Installing... $LatestRelease" -ForegroundColor Red
    $gitWeb = (Invoke-WebRequest -Uri "$($gitHub)/git-for-windows/git/releases/tag/$($LatestRelease)" -UseBasicParsing)

    $source = "$($gitHub)$($gitWeb.Links.href -match 'git-\w.*\W.*-64-bit.exe')"

    $destination = "$env:TEMP\$($source.Split('/')[-1])"
    
    Invoke-webrequest -uri $source -outfile $destination -UseBasicParsing

    Start-Process -Wait -FilePath $destination -ArgumentList "/VERYSILENT /NORESTART /COMPONENTS=icons,icons\desktop,ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh,autoupdate" # /LOG=`"%WINDIR%\Temp\$($source.Split('/')[-1]).log`""
    
    Remove-Item -Path $destination -Force 
}
}

Install-GitWin
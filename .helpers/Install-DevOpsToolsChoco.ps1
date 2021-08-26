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

function Install-choco {
    Set-ExecutionPolicy Bypass -Scope Process -Force;

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    

}

function Install-azModule {
    $azModule  = $(cmd /c "C:\Program Files\PowerShell\7\pwsh.exe" -c {Get-InstalledModule -Name az -ErrorAction SilentlyContinue | Select-Object version})

    if($null -eq $azModule){

    write-host " az Module is NOT Installed... Installing Azure az module" -ForegroundColor red 
    start-process -FilePath "C:\Program Files\PowerShell\7\pwsh.exe" -ArgumentList '-c "& {Install-Module -Name Az -Repository PSGallery -Force -AllowClobber}"'
    #Install-Module -Name Az -Repository PSGallery -Force -AllowClobber

    }
     else{

       write-host " Azure az module is installed... Version: $($azModule.Version)" -ForegroundColor Green 
     }
}

Install-choco

choco install powershell-core --version=7.1.1 -y --force --force-dependencies
    
choco install azure-cli -y --force --force-dependencies

choco install vscode -y --force --force-dependencies

choco install git -y --force --force-dependencies

choco install terraform -y --force --force-dependencies

Install-azModule

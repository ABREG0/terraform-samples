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
  try {

      $vcodeVersion = @(cmd /c code -v)[0]

    }
    catch {

      Write-Host " VS code not installed... Installing" -ForegroundColor Red

    } 

  if($null -eq $vcodeVersion){

    $source = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user'

    $destination = "$env:TEMP\vscode.exe"

    Invoke-WebRequest -Uri $source -OutFile $destination -UseBasicParsing

    Start-Process -Wait -FilePath $destination -ArgumentList '/VERYSILENT /NORESTART /MERGETASKS=!runcode,desktopicon,addcontextmenufiles,addcontextmenufolders'
    
    Remove-Item -Path $destination -Force
  }
  else{

    Write-Host " vs code version: $($vcodeVersion)" -ForegroundColor Green
  }
}

Install-vscode 
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

Install-Terraform

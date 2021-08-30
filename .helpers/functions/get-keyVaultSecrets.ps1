<#
.SYNOPSIS
    Sets Azure Key Vault secrets into environment variables for the current PowerShell session.
.DESCRIPTION
    Sets Azure Key Vault secrets into environment variables for the current PowerShell session.
        - 'keyvaultName'
        - 'ARM_SUBSCRIPTION_ID','ARM_CLIENT_ID','ARM_CLIENT_SECRET','ARM_TENANT_ID','ARM_SAS_TOKEN','ARM_ACCESS_KEY'
.EXAMPLE
    get-keyVaultSecrets.ps1 -KeyVaultName 'kvName' -secretNames '',''

.NOTES
    IMPORTANT: secret names MUST exist in Keyvault with "-" in the names. no underscores "_" allowed in KV secret names. 
#>


[CmdletBinding()]
param (
    # Find the Azure Key Vault that includes this string in it's name
    [string]$KeyVaultName,
    [array]$secretNames
)

Invoke-Command -FilePath -ArgumentList
write-host -Message "Checking for an active Azure login..." -NoNewline

$azContext = Get-AzContext

if (-not $azContext) {
    Write-Error "There is no active login session to Azure. Running ('Connect-AzAccount')" -ErrorAction SilentlyContinue
    Connect-AzAccount
}

Write-Host "`nSetting current session env variables.." -ForegroundColor 'Green'

$KeyVault = Get-AzKeyVault | Where-Object VaultName -match $KeyVaultName
if (-not $KeyVault) {
    throw "Could not find Azure Key Vault with name including search string: [$KeyVaultName]"
}


# Get Azure KeyVault Secrets
$count = $secretNames.Count

Write-Host "Getting [$($count)] Secrets from $($KeyVaultName)"

for ($index = 0; $index -lt $Count; $index++) {

    write-host -Message "Get secret [$($secretNames[$index])] from Azure Key Vault..." -NoNewline
    Write-Host " [$($index+1)] of [$($count)] `n $($secretNames[$index])"

    # get secret
    $SecretsParams = @{
        Name        = ($($secretNames[$index]) -replace '_', '-')
        VaultName   = $KeyVault.VaultName
        ErrorAction = 'Stop'
    }

    write-host -Message "name: [$($SecretsParams.Name)]" -ForegroundColor red

    $secret = Get-AzKeyVaultSecret @SecretsParams -AsPlainText

    if($null -ne $secret){
        Set-Item -path env:$($secretNames[$index]) -Value "$($secret)"
    }
    else{
        Write-Error "Can't find $($SecretsParams.Name) Name.." -Exception
    }
}
Write-Host "Variables are set: `n to view vars run: Dir env:" -ForegroundColor 'Green'


function test-cmd {
    param (
        $hi,$hi2
    )
$vcExtentions = @'
4ops.terraform
amazonwebservices.aws-toolkit-vscode
azps-tools.azps-tools
'@

    Invoke-Command { & 'C:\Program Files\PowerShell\7\pwsh.exe' -command {
                        param ($hi,$hi2,$ar3)
                        write-host "ps version $($Host.Version)"
                        Write-Host "hi $($hi)";
                        Write-Host "hi2 $($hi2)"
                        Write-Host $ar3;
                            $vcExtentions = $ar3 -replace "`n", ''
                            $vcExtentions = $vcExtentions.Split("`r")

                            $vcExtentions.Count
                            #Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }
                            for ($i = 0; $i -lt $vcExtentions.Count; $i++) {
                                $ext = "$($vcExtentions[$i])"
                                Write-Host "Installing extention Name: $($vcExtentions[$i])"
                                #& cmd /c code --install-extension $ext --force
                            }
                        Start-Sleep 10 
                        } -args $hi,$hi2,$vcExtentions
                    }


}

test-cmd -hi 'hola' -hi2 'hola2'

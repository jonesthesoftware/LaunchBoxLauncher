# Copyright (c) Wayne Jones
# Licensed under the MIT License.

function Start-Emulator {
    param (
        [hashtable]$EmulatorArguments
    )    
    $ResolvedEmulatorArguments = $EmulatorArguments.EmulatorParameters | 
        Select-Object @{Name="Parameter"; Expression={ Get-ResolvedParameter -Parameter $_ -EmulatorArguments $EmulatorArguments } }

    $EmulatorDirectory = Split-Path -Parent $($EmulatorArguments.EmulatorPath)
    Push-Location -Path $EmulatorDirectory
    $ArgumentList = $ResolvedEmulatorArguments.Parameter -Join " "

    Start-Process -FilePath $($EmulatorArguments.EmulatorPath) -ArgumentList $ArgumentList
    Pop-Location

}

function Get-ResolvedParameter {
    param (
        [PSCustomObject]$Parameter,
        [hashtable]$EmulatorArguments
    ) 

    if ( $null -ne $Parameter.Switch ) {
        $Switch = "$($_.Switch)$($_.SwitchSeparator)"
    } else {
        $Switch = ""
    }
    $Argument = switch ( $Parameter.Type ) {
        'MameAutoboot' {
            if ( $Parameter.Value -eq $true ) {
                if ( $EmulatorArguments.Autoboot.IsPath -eq $true ) {
                    "-autoboot_script ""$($EmulatorArguments.Autoboot.Script)"""
                } else {
                    "-autoboot_command ""$($EmulatorArguments.Autoboot.Script)"""
                }
            }   
        }
        'Variable' {
            $EmulatorArguments.VariableAssignment[$Parameter.Value]
        }
        'Default' {
            switch ( $Parameter.Value ) {
                'autoboot' {
                    """$($EmulatorArguments.Autoboot.Script)"""
                }
                'rompath' {
                    """$($EmulatorArguments.RomPath)"""
                }
                'program' {
                    """$($EmulatorArguments.Program)"""
                }
            }
        }
        default {
            $Parameter.Value
        }
    }

    return "$($Switch)$($Argument)"

}



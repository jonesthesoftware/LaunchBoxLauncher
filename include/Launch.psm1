# Copyright (c) Wayne Jones
# Licensed under the MIT License.

function Start-Emulator {
    param (
        [hashtable]$EmulatorArguments
    )    
    $ResolvedEmulatorArguments = $EmulatorArguments.EmulatorParameters | 
        Select-Object @{Name="Parameter"; Expression={
            switch ( $_ ) {
                { $_.Type -eq 'Variable' } {
                    $EmulatorArguments.VariableAssignment[$_.Value]
                }
                { $_.Type -eq 'Default' } {
                    switch ( $_.Value ) {
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
                    $_.Value
                }
            }
        } }

    $EmulatorDirectory = Split-Path -Parent $($EmulatorArguments.EmulatorPath)
    Push-Location -Path $EmulatorDirectory
    $ArgumentList = $ResolvedEmulatorArguments.Parameter -Join " "
    Start-Process -FilePath $($EmulatorArguments.EmulatorPath) -ArgumentList $ArgumentList
    Pop-Location

}


# Copyright (c) Wayne Jones
# Licensed under the MIT License.

Import-Module "$PSScriptRoot\xml\LauncherConfiguration.psm1"

function Get-EmulatorConfiguration {
    <#
        .SYNOPSIS
            Obtains the Emulator Configuration for a specific rom
        .DESCRIPTION
            Uses the Launcher Configuration XML file to select the emulator and autoboot preferences for the passed rom
            The PSCustomObject returned contains a generic representation of the emulator, autoboot script, and variables
            This data will require additional provision from the Autoboot, Emulator, and Launchbox XML files
    #>
    param (
        [string]$XmlPath,
        [string]$PlatformName,
        [string]$RomPath
    )
    $RomExtension = [System.IO.Path]::GetExtension( $RomPath ).ToLower().Substring(1)
    Request-XmlContent -Path $XmlPath
    $EmulatorConfigurationXml = Get-EmulatorConfigurationXml -PlatformName $PlatformName -RomExtension $RomExtension

    # Create a Hash Table of the Variable Assignments available in this configuration
    $VariableAssignment = @{}
    $EmulatorConfigurationXml.VariableAssignment | ForEach-Object { $VariableAssignment[$_.name] = $_.InnerText }

    return [PsCustomObject]@{
        EmulatorKey = $EmulatorConfigurationXml.emulator
        AutobootKey = $EmulatorConfigurationXml.autoboot
        VariableAssignment = $VariableAssignment
    }
}

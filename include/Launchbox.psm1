# Read XML from Launchbox
# Copyright (c) Wayne Jones
# Licensed under the MIT License.

Function Set-LaunchboxDirectory{
    param(
        [string]$LaunchboxDirectory
    )

    $script:LaunchboxDirectory = $LaunchboxDirectory
}

Function Get-Program
{
    param(
        [string]$PlatformName,
	    [string]$GameId
    )

    $Path = "$script:LaunchboxDirectory\Data\Platforms\$PlatformName.xml"

    $XPath = "/LaunchBox/CustomField[GameID[text()='" + $GameId + "'] and Name[text()='program']]/Value"
    $ProgramNode = Select-Xml -Path $Path -XPath $XPath | Select-Object -ExpandProperty Node
    return [PSCustomObject]@{
        Name = $ProgramNode.InnerText
    }
}

Function Get-LaunchboxEmulator
{
    param(
	    [string]$EmulatorName
    )

    $Path = "$script:LaunchboxDirectory\Data\Emulators.xml"

    $XPath = "/LaunchBox/Emulator[Title[text()='" + $EmulatorName + "']]"
    $EmulatorNode = Select-Xml -Path $Path -XPath $XPath | Select-Object -ExpandProperty Node

    $EmulatorPath = $($EmulatorNode.ApplicationPath)
    if ( [System.IO.Path]::IsPathRooted( $EmulatorPath ) -eq $false ) {
        $ConcatenatedPath = $script:LaunchboxDirectory + "\" + $EmulatorPath
        $ActualPath = Resolve-Path -Path $ConcatenatedPath
    } else {
        $ActualPath = $EmulatorPath
    }

    return [PSCustomObject]@{
        Path = $ActualPath
    }
    
}


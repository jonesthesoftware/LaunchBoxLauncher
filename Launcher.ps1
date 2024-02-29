# Launcher for Launchbox
# Copyright (c) Wayne Jones
# Licensed under the MIT License.

param (
    [Parameter(Mandatory)]$LaunchboxPath,
    [Parameter(Mandatory)]$PlatformName,
    [String]$GameId,
	[String]$RomPath
)

Import-Module "$PSScriptRoot\include\Launchbox.psm1"
Import-Module "$PSScriptRoot\include\Emulator.psm1"
Import-Module "$PSScriptRoot\include\Autoboot.psm1"
Import-Module "$PSScriptRoot\include\Configuration.psm1"
Import-Module "$PSScriptRoot\include\Launch.psm1"

# Extract the Directory that Launchbox uses, this will be useful to extract information from Launchbox XML files
$LaunchboxDirectory=[System.IO.Path]::GetDirectoryName( $LaunchboxPath )
Set-LaunchboxDirectory $LaunchboxDirectory

#Load up the configuration file into a hashtable, this will be used to define the location of the XML files for configuration
$LauncherConfig = Get-Content "launcher.cfg" | ConvertFrom-StringData

$EmulatorConfiguration = Get-EmulatorConfiguration -XmlPath $LauncherConfig.ConfigurationXML -PlatformName $PlatformName -RomPath $RomPath

# Generate the Autoboot Script - this may use the Custom Field "program", from Launchbox, if it is defined
if ( $null -ne $EmulatorConfiguration.AutobootKey ) {
    $Program = Get-Program -PlatformName $PlatformName -GameId $GameId
    $Autoboot = Get-Autoboot -XmlPath $LauncherConfig.AutobootXML -Key $EmulatorConfiguration.AutobootKey -Program $Program -LuaScriptPath $LauncherConfig.LuaAutobootScripts
}

$EmulatorDefinition = Get-EmulatorDefinition -XmlPath $LauncherConfig.EmulatorXML -Key $EmulatorConfiguration.EmulatorKey

# If we have a Launchbox Emulator then we need to look up the path in the Launchbox XML
if ( $EmulatorDefinition.Emulator.IsLaunchbox -eq $true ) {
    $LaunchboxEmulator = Get-LaunchboxEmulator $EmulatorDefinition.Emulator.Value
    $EmulatorPath = $LaunchboxEmulator.Path
} else {
    $EmulatorPath = $EmulatorDefinition.Emulator.Value
}

# Splat the Emulator Arguments into a hash table, this is probably the cleanest way to pass all the arguments required
$EmulatorArguments = @{
    EmulatorPath = $EmulatorPath
    RomPath = $RomPath
    Autoboot = $Autoboot
    EmulatorParameters = $EmulatorDefinition.Parameters
    VariableAssignment = $EmulatorConfiguration.VariableAssignment
    Program = $Program
}
Start-Emulator -EmulatorArguments $EmulatorArguments

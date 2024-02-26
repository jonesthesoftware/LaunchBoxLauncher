# Copyright (c) Wayne Jones
# Licensed under the MIT License.

[xml]$script:Xml = $null
function Request-XmlContent {
    param (
        [string]$Path
    ) 
    [xml]$script:Xml = Get-Content -Path $Path
}

function Get-PlatformXml {
    param (
        [string]$PlatformName
    )    
    $script:Xml.SelectSingleNode("//LauncherConfiguration/Platform[@LaunchBoxPlatform='$PlatformName']") 
}

function Get-MediaXml {
    param (
        [string]$PlatformName,
        [string]$RomExtension
    )    
    Get-PlatformXml $PlatformName | Select-Object -ExpandProperty Media | Where-Object -FilterScript { $RomExtension -in $_.extension.Split() }
}

function Get-EmulatorConfigurationXml {
    param (
        [string]$PlatformName,
        [string]$RomExtension
    )    
    $MediaXml = Get-MediaXml -PlatformName $PlatformName -RomExtension $RomExtension
    $MediaXml.EmulatorConfiguration
}

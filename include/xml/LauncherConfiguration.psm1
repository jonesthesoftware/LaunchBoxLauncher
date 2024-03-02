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
    $PlatformNode = Get-PlatformXml $PlatformName 
    $MediaNodes = $PlatformNode.SelectNodes("Media")
    if ( $MediaNodes.Count -eq 1 )  {
        if ( $null -eq $PlatformNode.Media.extension ) {
            # No extension specified in configuration, use directly
            $MediaNodes
        } else {
            $MediaNodes | Where-Object -FilterScript { $RomExtension -in $_.extension.Split() }
        }
    } else { 
        $MediaNodes | Where-Object -FilterScript { $RomExtension -in $_.extension.Split() }
    }
}

function Get-EmulatorConfigurationXml {
    param (
        [string]$PlatformName,
        [string]$RomExtension
    )    
    $MediaXml = Get-MediaXml -PlatformName $PlatformName -RomExtension $RomExtension
    $MediaXml.EmulatorConfiguration
}

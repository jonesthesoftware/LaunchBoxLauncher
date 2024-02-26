# Copyright (c) Wayne Jones
# Licensed under the MIT License.

[xml]$script:Xml = $null
function Request-XmlContent {
    param (
        [string]$Path
    ) 
    [xml]$script:Xml = Get-Content -Path $Path
}

function Get-EmulatorXml {
    param (
        [string]$Key
    )    
    $script:Xml.SelectSingleNode("//LauncherEmulator/Emulator[@key='$Key']") 
}

function Get-PrototypeXml {
    param (
        
        [string]$Key
    )    
    $script:Xml.SelectSingleNode("//LauncherEmulator/Prototype[@key='$Key']") 
}
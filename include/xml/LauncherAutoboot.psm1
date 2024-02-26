# Copyright (c) Wayne Jones
# Licensed under the MIT License.

[xml]$script:Xml = $null
function Request-XmlContent {
    param (
        [string]$Path
    ) 
    $script:Xml = Get-Content -Path $Path
}

function Get-AutobootXml {
    param (
        [string]$Key
    )    
    $script:Xml.SelectSingleNode("//LauncherAutoboot/Autoboot[@key='$Key']") 
}
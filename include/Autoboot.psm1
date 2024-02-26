# Copyright (c) Wayne Jones
# Licensed under the MIT License.

Import-Module "$PSScriptRoot\xml\LauncherAutoboot.psm1"

Function Get-Autoboot
{
    param(
        [string]$XmlPath,
        [string]$Key,
        [PsCustomObject]$Program
    )

    Request-XmlContent -Path $XmlPath
    $AutobootNodeXml = Get-AutobootXml $Key

    if ( $null -eq $Program.Name ) {
        $CommandNodeList = $AutobootNodeXml.SelectNodes( "DefaultBootSequence/Command" )
    } else {
        $CommandNodeList = $AutobootNodeXml.SelectNodes( "NamedProgramBootSequence/Command" )
        if ( $null -eq $CommandNodeList ) {
            $CommandNodeList = $AutobootNodeXml.SelectNodes( "DefaultBootSequence/Command" )    
        }
    }

    $Command = $($CommandNodeList.InnerText) -Join "\n"
    $AutobootScript = $Command -replace '%program%', $Program.Name

    return [PSCustomObject]@{
        Script = $AutobootScript
    }
}


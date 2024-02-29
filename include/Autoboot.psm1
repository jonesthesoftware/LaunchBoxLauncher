# Copyright (c) Wayne Jones
# Licensed under the MIT License.

Import-Module "$PSScriptRoot\xml\LauncherAutoboot.psm1"

Function Get-Autoboot
{
    param(
        [string]$XmlPath,
        [string]$Key,
        [PsCustomObject]$Program,
        [string]$LuaScriptPath
    )

    Request-XmlContent -Path $XmlPath
    $AutobootNodeXml = Get-AutobootXml $Key

    if ( $null -eq $Program.Name ) {
        $CommandNodeList = $AutobootNodeXml.SelectNodes( "DefaultBootSequence/Command" )
    } else {
        $CommandNodeList = $AutobootNodeXml.SelectNodes( "NamedProgramBootSequence/Command" )
        if ( $CommandNodeList.Count -eq 0 ) {
            $CommandNodeList = $AutobootNodeXml.SelectNodes( "DefaultBootSequence/Command" )    
        }
    }

    if ( $CommandNodeList.Count -eq 0 ) {
        # No named program, or default boot sequence, must be using a lua script
        $IsAutobootPath = $true
        $Path = $AutobootNodeXml.SelectSingleNode( "DefaultLuaScriptPath" ).InnerText
        $IsAbsolutePath = Split-Path -Path $Path -IsAbsolute
        if ( $IsAbsolutePath -eq $false ) {
            $ConcatenatedPath = $LuaScriptPath + "\" + $Path
            $AutobootScript = Resolve-Path -Path $ConcatenatedPath
        } else {
            $AutobootScript = $Path
        }    
    } else {
        $Command = $($CommandNodeList.InnerText) -Join "\n"
        $IsAutobootPath = $false
        $AutobootScript = $Command -replace '%program%', $Program.Name
    }

    return [PSCustomObject]@{
        IsPath = $IsAutobootPath
        Script = $AutobootScript
    }
}


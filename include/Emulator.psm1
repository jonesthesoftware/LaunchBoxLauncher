# Copyright (c) Wayne Jones
# Licensed under the MIT License.

Import-Module "$PSScriptRoot\xml\LauncherEmulator.psm1"

function Get-EmulatorDefinition {
    <#
        .SYNOPSIS
            Obtains the Emulator Definition based on a named Key
        .DESCRIPTION
            Uses XML configuration files to obtain the information required to build up an emulator definition
            The PSCustomObject returned contains a generic representation of the command line, this will require
            additional provision from the Autoboot and Launchbox XML files; any non constant parameters will 
            also need to be provisioned at a later stage.
    #>
    param (
        [string]$XmlPath,
        [string]$Key
    )    
    # Get the base emulator that will be used for this Platform / Rom combination
    Request-XmlContent $XmlPath
    $EmulatorXml = Get-EmulatorXml -Key $Key
    
    # The Prototype represents the base emulator configuration
    $PrototypeKey = $EmulatorXml.prototype
    if ( $PrototypeKey ) {
        $PrototypeXml = Get-PrototypeXml -Key $PrototypeKey
    }

    $EmulatorParameters = Get-EmulatorParameters -EmulatorXml $EmulatorXml -PrototypeXml $PrototypeXml
    $Emulator = Get-Emulator -PrototypeXml $PrototypeXml

    return [PsCustomObject]@{
        Emulator = $Emulator
        Parameters = $EmulatorParameters
    }
}


function Get-Emulator {
    <#
        .SYNOPSIS
            Obtains the Emulator from the Prototype XML
        .DESCRIPTION
            Obtains either the title of the Launchbox Emulator or a path to a custom Emulator
            The PSCustomObject specifies whether the Value returned should be provisioned at a later stage
            (if it is a launchbox emulator, the emulator path will need to read from the Launchbox XML files)
    #>
    param (
        [System.Xml.XmlElement]$PrototypeXml
    )
    $Node = $PrototypeXml.SelectSingleNode( "EmulatorDefinition/LaunchboxEmulator/Title" )
    if ( $null -ne $Node) {
        # The Launchbox Emulator path will be resolved later using the title
        $IsLaunchbox = $true
    } else {
        # A Bespoke Emulator is being used, this will be defined by the path to the Emulator executable
        $Islaunchbox = $false
        $Node = $PrototypeXml.SelectSingleNode( "EmulatorDefinition/BespokeEmulator/EmulatorPath" )
    }
    return [PSCustomObject]@{
        IsLaunchbox = $IsLaunchbox
        Value = $Node.InnerText     # The value will either be the title of the Launchbox Emulator, or the path to a defined Emulator 
    }
}

function Get-EmulatorParameters {
    <#
        .SYNOPSIS
            Obtains the Emulator Parameters from the XML
        .DESCRIPTION
            Parameters are stored against both the Prototype and the Emulator
            Obtain the Parameters from each and combine them
    #>
    param (
        [System.Xml.XmlElement]$EmulatorXml,
        [System.Xml.XmlElement]$PrototypeXml
    )     
    $PrototypeParameters = Get-ParametersFromXml -Xml $PrototypeXml
    $EmulatorParameters = Get-ParametersFromXml -Xml $EmulatorXml
    if ( $PrototypeParameters.Count -eq 0 ) {
        return $EmulatorParameters
    } elseif ( $EmulatorParameters.Count -eq 0 ) {
        return $PrototypeParameters
    } else {        
        $AllEmulatorParameters = $PrototypeParameters + $EmulatorParameters
        return $AllEmulatorParameters
    }

}

function Get-ParametersFromXml {
    <#
        .SYNOPSIS
            Obtains the Parameters from the supplied XML
        .DESCRIPTION
            The XML supplied must contain an EmulatorDefinition Element
            The Parameters in the XML are queried, then combined into a List of PSCustomObjects which describe how to construct the
            command line.
            A Parameter may have a switch, this is just added to the list and will be interpreted into the command line at a later stage. 
            A Parameter may be a MameAutoboot, this should only happen if there are no inner elements, the command line for autobooting 
            will be determined at a later stage.
            The inner element in the parameter describes the type of parameter, this may be :-
                Constant:   The value will be used directly as defined
                Default:    This is a special case, it is reserved for rom specific options (rompath, autoboot, or program), 
                            it will be substituted at a later process with the correct value
                Variable:   The value will be substituted in a later process with the Variable Assignment in the Launcher Configuration
    #>
    param (
        [System.Xml.XmlElement]$Xml
    ) 
    [System.Collections.Generic.List[PSCustomObject]]$ParameterList = @()
    $NodeList = $Xml.SelectNodes( "EmulatorDefinition/CommandLine/ParameterList/Parameter" )
    foreach ($Node in $NodeList) {
        $Switch = $null
        $SwitchSeparator = $null
        $Type = $null
        $Value = $null
        if ( $Node.HasAttribute( 'Switch' ) ) {
            $Switch = $Node.Switch
            if ( $Node.HasAttribute( 'SwitchSeparator' ) ) {
                $SwitchSeparator = $Node.SwitchSeparator
            }
        } 
        if ( $Node.HasChildNodes ) {
            $ParameterType = $Node.FirstChild
            $Type = $ParameterType.Name
            $Value = $ParameterType.InnerText
            if ( $null -ne $Switch -and $null -eq $SwitchSeparator ) {
                $SwitchSeparator = " "
            }
        } elseif ( $Node.HasAttribute( 'MameAutoboot') ) {
            # A MameAutoboot node should have no child nodes
            $Type = 'MameAutoboot'
            $Value = $Node.MameAutoboot
        } 
        $ParameterList.Add( [PSCustomObject]@{ 
            Type            = $Type
            Switch          = $Switch
            SwitchSeparator = $SwitchSeparator
            Value           = $Value
        } )
        
    }

    return ,$ParameterList

}


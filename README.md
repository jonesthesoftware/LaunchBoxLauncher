# LaunchBoxLauncher
A launcher for LaunchBox, allowing easier autobooting / launching of roms for (primarily) older 8 bit systems.

The program file to run is defined using a custom field named "program" in Launchbox, this is stored against each individual rom. If a rom is not supplied then a default autoboot script may be run, for some systems this is all that is required, but some systems rely on the name of a program to run automatically (for example the Acorn Atom).

The launcher is currently set up for Mame, but it can run other emulators through the XML configuration.

**Note**
The included RandoMame Lua Scripts are Licensed under Apache License 2.0, please see LICENSE.txt in the lua\RandoMame directory.

Source code for RandoMame can be obtained from
https://github.com/Bob-Z/RandoMame

No changes have been made to the scripts.

Thank you to Bob-Z for producing these wonderful scripts, and releasing them under a permissive license.


## Example
As an example, if you have the Acorn Atom Game Galaxians, you may add to "Custom Fields" in Launchbox a field named "program" with the value "GALAXI".
In the default configuration when the file is launched through launcher.bat it will execute, using the Mame Autoboot command line switch.
<pre>*DOS
*RUN"GALAXI"</pre>

## Installation
Just copy the whole thing to your system, wherever you like, and then set it up like a normal emulator in [Launchbox](https://www.launchbox-app.com/).

For example, if you decide to copy it into the Emulators directory in launchbox, you'd define the application path as 

<pre>.\Emulators\LaunchBoxLauncher-MyConfig\launcher.bat</pre>

The Default command line parameters should be set to

<pre>"%launchboxorbigboxexepath%" "%platform%" %gameid%</pre>

Do not remove quotes, spaces, or file extension / folder path; the rompath will always be passed as the final parameter from Launchbox.

You then just associate each platform you want to use with this Emulator, leave the default command line parameters for each of these platforms blank - there's no need to repeat these.

Note that the scripts rely on an emulator called **MAME** existing in LaunchBox, you may change this through the [Emulator Configuration](#launcher-emulator-configuration)

## Basic Configuration
Launching of emulators is configured using the XML files, which by default are read from the xml directory; you can change this by modifying the *launcher.cfg* file. The configuration file should be fairly self-explanatory

<pre>ConfigurationXML = xml/LauncherConfiguration.xml
AutobootXML = xml/LauncherAutoboot.xml
EmulatorXML = xml/LauncherEmulator.xml
LuaAutobootScripts = lua/RandoMame/autoboot</pre>

Each line relates to the location of the relevant XML file, if you want to store these configuration files somewhere else or easily swap between configurations then you can change each file independently.
The LuaAutobootScripts refers to the default location for lua scripts used in the Autoboot Configuration.

### XML Configuration
The LaunchBoxLauncher is primarily configured using 3 XML files, these define how an emulator should be launched, allowing re-use of autoboot scripts and emulator configuration where possible.

**TODO:** This whole section needs extra work, and the xsd files need appropriate annotation to explain the function of each element.

#### Launcher Configuration
The LauncherConfiguration.xml file defines how the scripts will act with a given platform and file.

Using the below section for a platform named "Acorn Atom" in Launchbox :-

```xml
    <Platform LaunchBoxPlatform="Acorn Atom">
        <Media extension="dsk 40t">
            <EmulatorConfiguration emulator="MameFloppyAutoboot" autoboot="AtomDisk">
                <VariableAssignment name="system">atom</VariableAssignment>
                <VariableAssignment name="biosPath"><![CDATA["Z:\Systems\Acorn\Atom\Mame\Bios"]]></VariableAssignment>
            </EmulatorConfiguration>  
        </Media>
    </Platform>
```

When the Platform is passed from Launchbox *(%platform%)*, and the extension of the rompath is either *dsk* or *40t*, then the Emulator named "MameFloppyAutoboot" (in Emulator Configuration) will be built and the variable defined as "system" will be replaced with "atom". The variable defined as "biosPath" will be replaced with "Z:\Systems\Acorn\Atom\Mame\Bios", note the CDATA section to allow non-standard characters to be passed.

#### Emulator Configuration
The LauncherEmulator.xml file defines how an Emulator will be called.

A prototype should be defined, this is used to define how the emulator is executed.

Using the below section for a Prototype called "BespokeMame", will define the basic command line options for running an emulator. The "EmulatorPath" is used in this example, but you may also define an emulator within Launchbox (in fact the default is to use a Launchbox emulator called MAME).

```xml
    <Prototype key="BespokeMame">
        <EmulatorDefinition>
            <BespokeEmulator>
                <EmulatorPath>V:\Emulators\Arcade\mame0235b\mame.exe</EmulatorPath>
            </BespokeEmulator>
            <CommandLine>
                <ParameterList>
                    <Parameter>
                        <Variable>system</Variable>
                    </Parameter>
                    <Parameter Switch="-keyboardprovider">
                        <Constant>dinput</Constant>
                    </Parameter>
                    <Parameter Switch="-skip_gameinfo"/>
                    <Parameter Switch="-nowindow"/>
                    <Parameter Switch="-rompath">
                        <Variable>biospath</Variable>
                    </Parameter>
                </ParameterList>
            </CommandLine>
        </EmulatorDefinition>
    </Prototype>
```

The Emulator Path defines the path to the executable, the ParameterList defines how the command line options should be built.
Note the difference types of Parameters, and the optional *Switch* attriibute.
When no Switch is defined this means a command line option without a switch, for example in mame you will pass the system name without a command line switch. When the Switch is present then this will be inserted as a command line switch before the value.
Variable means just that, it is a variable that is configured by the Launcher Configuration, see the VariableAssignment in the section above.
Constant means directly place this value after the command line switch.
Default isn't generally used in the Prototype, but may be one of autoboot, rompath, or program; this will substitute the value based on the rom in use - autoboot is the generated autoboot script, rompath is the full path to the rom being emulated, and program is the named of the program which is being booted in the emulation (i.e. from the custom field "program" in LaunchBox)


If changing the name of the default emulator used, and you want to use an emulator from Launchbox, change the Launchbox Emulator defined in this file (just change Title to the name of the emulator you've defined in Launchbox).

```xml
    <Prototype key="Mame">
        <EmulatorDefinition>
            <LaunchboxEmulator>
                <Title>MAME</Title>
            </LaunchboxEmulator>
...
```

The actual emulator definition will use a reusable protoype, so will inherit any options defined in the prototype. The example below will use the "BespokeMame" prototype defined above, inheriting all those command line parameters.

```xml
    <Emulator key="MameFloppyAutoboot" prototype="BespokeMame">
        <EmulatorDefinition>
            <CommandLine>
                <ParameterList>
                    <Parameter Switch="-flop1">
                        <Default>rompath</Default>
                    </Parameter>
                    <Parameter Switch="-autoboot_command">
                        <Default>autoboot</Default>
                    </Parameter>
                    <Parameter Switch="-autoboot_delay">
                        <Constant>2</Constant>
                    </Parameter>
                </ParameterList>
            </CommandLine>
        </EmulatorDefinition>
    </Emulator>
```

If you are using Mame as your emulator you may simplify the Parameter autoboot_command, which will also automatically swap between autoboot_command and autoboot_script switches.

instead of this :-
```xml
                    <Parameter Switch="-autoboot_command">
                        <Default>autoboot</Default>
                    </Parameter>
```
you may use this instead :-
```xml
                    <Parameter MameAutoboot="true"/>
```



The Parameters are defined in exactly the same way as the prototype, but are generally more specific to the type of emulation taking place. 

The prototype will usually define something very generic, for example running Mame with CRT emulation on an undefined system. The emulator will generally define more specific information, like how the devices work for a single emulated platform or type of device.

#### Autoboot Configuration
The LauncherAutoboot.xml file defines how to run a program within the emulator.

```xml    
    <Autoboot key="AtomDisk">
        <NamedProgramBootSequence>
            <Command><![CDATA[*DOS]]></Command>
            <Command><![CDATA[*RUN """%program%"""]]></Command>
            <Command/>
        </NamedProgramBootSequence>
        <DefaultBootSequence>
            <Command><![CDATA[*DOS]]></Command>
            <Command><![CDATA[*CAT]]></Command>
            <Command/>
            <Command/>
            <Command><![CDATA[*RUN "]]></Command>
        </DefaultBootSequence>
    </Autoboot>
```

Lua Scripts work better for tape loaders, the included RandoMame scripts speed up mame whilst loading so you don't have to hold down insert / skip frames / increase emulation speed manually.

I've also added an alternative option for lua scripts, it will use the path specified in the configuration path, for example :-

```xml    
    <Autoboot key="AmstradCPCTape">
        <DefaultLuaScriptPath><![CDATA[cpc_cass.lua]]></DefaultLuaScriptPath>
    </Autoboot>
```
You may also use an absolute path, if you have lua scripts stored in multiple locations, which will override the lua script path defined.


Each Command is run in sequence, a blank Command will provide a carriage return in the emulator. If the last command is not a blank command then the emulator will wait for you to type something, this can be useful if you want to catalog a disk & wait to type in the program you want to run without having to remember the run command for that particular system.

The NamedProgramBootSequence uses the custom field "program", from LaunchBox, to launch a named program. 
The DefaultBootSequence is used when the "program" custom field is not defined, for many systems this will be enough - you don't always need to know the name of the program to run, or they generally default to a specific value.

The commands are generally wrapped in CDATA sections, they often contain values that aren't valid in XML, but they may be escaped if you prefer. If they do not contain illegal XML characters then you can place them straight in the command element.

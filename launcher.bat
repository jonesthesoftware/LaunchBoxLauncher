@REM Launcher for Launchbox
@REM (c) Wayne Jones Feb 2024
@REM Licensed under the MIT License.

@ECHO OFF
IF [%4] == [] (
	IF [%3] == [] (
		IF [%2] == [] (
			@ECHO No Platform or Launchbox Path Specified
			@PAUSE
			@EXIT /B 1
		) ELSE (
			@Powershell.exe -executionpolicy remotesigned -File .\Launcher.ps1 -LaunchboxPath %1 -PlatformName %2
		)
	) ELSE (
		@Powershell.exe -executionpolicy remotesigned -File .\Launcher.ps1 -LaunchboxPath %1 -PlatformName %2 -GameId %3
	)
)  ELSE (
	@Powershell.exe -executionpolicy remotesigned -File .\Launcher.ps1 -LaunchboxPath %1 -PlatformName %2 -GameId %3 -RomPath %4
) 

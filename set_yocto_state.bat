@ECHO OFF

SET "WORKING_DIR=%~dp0"
SET "SET_STATE=True"
SET "SET_KEYS=False"
:Loop
IF "%~1"=="" GOTO Continue
	IF "%~1"=="--help" (
		echo: 
		echo ######################################
		echo ### Set Toradex build state script ###
		echo ######################################
		echo: 
		echo .\set_yocto_state^.bat [--no-state] [--no-keys]
		echo:
		echo example:
		echo   %WORKING_DIR%set_yocto_state^.bat --no-keys
		echo:
		echo:
		echo --no-state: This will ignore importing any build state ^(useful as it can several GB in size, but will make the build take significantly longer^)^.
		echo --no-keys: This will ignore importing any keys and certificates ^(useful if not running a '--secure-boot' prepared environment^)^.
		echo --help: Shows these help details^.
		echo:
		echo ######################################
		echo: 
		EXIT 0
	) ELSE IF "%~1"=="--no-state" (
		SET "SET_STATE=False"
	) ELSE IF "%~1"=="--no-keys" (
		SET "SET_KEYS=False"
	)
	SHIFT
GOTO Loop
:Continue

PUSHD %WORKING_DIR%
	IF "%SET_STATE%"=="True" (
		docker cp ./output/yocto-state.tar.gz tdx-builder:/opt/artifacts/
	)
	IF "%SET_KEYS%"=="True" (
		docker cp ./output/fit-keys.tar.gz tdx-builder:/opt/artifacts/
	)
POPD

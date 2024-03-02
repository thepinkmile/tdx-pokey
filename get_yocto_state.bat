@ECHO OFF

SET "WORKING_DIR=%~dp0"
SET "GET_IMAGE=True"
SET "GET_STATE=True"
SET "GET_KEYS=True"
:Loop
IF "%~1"=="" GOTO Continue
	IF "%~1"=="--help" (
		echo: 
		echo ############################################
		echo ### Retrieve Toradex build output script ###
		echo ############################################
		echo: 
		echo .\get_yocto_state^.bat [--no-image] [--no-state] [--no-keys]
		echo:
		echo   NOTE:
		echo     This script will copy the following files:
		echo       - 'verdin-image.tar.gz' in the 'output' folder - This contains the built deploy image files^.
		echo       - 'yocto-state.tar.gz' in the 'output' folder - This contains the build state ^(this can be several GB in size^)^.
		echo       - 'fit-keys.tar.gz' in the 'output' folder - This contains the fit image keys ^(if the '--secure-boot' environment is used^)^.
		echo       - 'cst.tar.gz' in the 'context' folder - This contains the image signing certificates ^(if the '--secure-boot' environment is used^)^.
		echo:
		echo example:
		echo   %WORKING_DIR%get_yocto_state^.bat --no-keys
		echo:
		echo:
		echo --no-image: This will ignore exporting the image deploy output^.
		echo --no-state: This will ignore exporting the build state output ^(useful as it can several GB in size^)^.
		echo --no-keys: This will ignore exporting any generated keys and certificates ^(useful if not running a '--secure-boot' prepared environment^)^.
		echo --help: Shows these help details^.
		echo:
		echo ############################################
		echo: 
		EXIT 0
	) ELSE IF "%~1"=="--no-image" (
		SET "GET_IMAGE=False"
	) ELSE IF "%~1"=="--no-state" (
		SET "GET_STATE=False"
	) ELSE IF "%~1"=="--no-keys" (
		SET "GET_KEYS=False"
	)
	SHIFT
GOTO Loop
:Continue

PUSHD %WORKING_DIR%
	IF "%GET_IMAGE%"=="True" (
		docker cp tdx-builder:/opt/yocto-output/verdin-image.tar.gz ./output/
	)
	IF "%GET_STATE%"=="True" (
		docker cp tdx-builder:/opt/yocto-output/yocto-state.tar.gz ./output/
	)
	IF "%GET_KEYS%"=="True" (
		docker cp tdx-builder:/opt/yocto-output/fit-keys.tar.gz ./output/
		docker cp tdx-builder:/opt/yocto-output/cst.tar.gz ./context/
	)
POPD
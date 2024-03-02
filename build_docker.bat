@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET "WD=%~dp0"

SET "EXTRA_ARGS="
SET "PASSTHROUGH_ARGS="
SET "IS_PASSTHROUGH=False"
:Loop
IF "%~1"=="" GOTO Continue
	IF "%~1"=="--help" (
		echo: 
		echo ###############################################
		echo ### Build Toradex Docker environment script ###
		echo ###############################################
		echo: 
		echo .\build_docker^.bat {docker-file-args} [--help] [-- {docker-build-args}]
		echo:
		echo example:
		echo   %WD%build_docker.bat PREP_ARGS ^"--secure-boot --threads 4^" -- --no-cache
		echo:
		echo:
		echo --docker-file-args: Arguments to pass into the docker file during build ^(see: dockerfile ARG=^.^.^.^)^.
		echo   PREP_ARGS ^"{prep-args}^": Arguments to pass to the docker prepare^.sh script
		echo   USERNAME ^"{username}^": Default 'ubuntu'^; The non-root username to be created
		echo   USER_UID ^"{linux-user-id}^": Default '1000'^; The non-root user id
		echo   USER_GID ^"{linux-group-id}^": Default '1000'^; The non-root user's group id
		echo --help: Shows these help details^.
		echo --: Separates arguments for this script from any custom Docker build command parameters you require^.
		echo   {docker-build-args}: Custom arguments to pass to the docker build command ^(e.g. '--no-cache'^)^.
		echo:
		echo ###############################################
		echo: 
		EXIT 0
	) ELSE IF "%~1"=="--" (
		SET "IS_PASSTHROUGH=True"
	) ELSE IF "%IS_PASSTHROUGH%"=="True" (
		SET "PASSTHROUGH_ARGS=%PASSTHROUGH_ARGS% %1"
	) ELSE (
		ECHO ARG: %~1=%2
		SET "EXTRA_ARGS=%EXTRA_ARGS% --build-arg %~1=%2"
		SHIFT
	)
	SHIFT
GOTO Loop
:Continue

ECHO Passthrough Args: %PASSTHROUGH_ARGS%
ECHO Using Args: %EXTRA_ARGS%
PUSHD %WD%
	docker build%PASSTHROUGH_ARGS% -t tdx-base -f Dockerfile%EXTRA_ARGS% ./context
POPD
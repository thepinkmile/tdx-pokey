@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET "WD=%~dp0"

SET "EXTRA_ARGS="
:Loop
IF "%~1"=="" GOTO Continue
ECHO ARG: %~1=%2
SET "EXTRA_ARGS=%EXTRA_ARGS% --build-arg %~1=%2"
SHIFT
SHIFT
GOTO Loop
:Continue

ECHO Using Args: %EXTRA_ARGS%
PUSHD %WD%
	docker build --no-cache -t tdx-base -f Dockerfile%EXTRA_ARGS% ./context
POPD
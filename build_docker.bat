@ECHO OFF
PUSHD %~dp0

	docker build --no-cache -t tdx-base -f Dockerfile ./context

POPD
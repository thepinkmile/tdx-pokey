@ECHO OFF
PUSHD %~dp0

	docker build -t tdx-base -f Dockerfile ./context

POPD
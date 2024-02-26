@ECHO OFF
PUSHD %~dp0
	docker cp ./output/yocto-state.tar.gz tdx-builder:/opt/artifacts/
	docker cp ./output/fit-keys.tar.gz tdx-builder:/opt/artifacts/
POPD

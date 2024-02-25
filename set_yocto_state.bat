@ECHO OFF
PUSHD %~dp0
	docker cp ./output/yocto-state.tar.gz tdx-builder:/opt/artifacts/
	docker cp ./output/verdin-image.tar.gz tdx-builder:/opt/artifacts/
POPD
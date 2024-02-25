@ECHO OFF
PUSHD %~dp0
	docker cp tdx-builder:/opt/yocto-output/yocto-state.tar.gz ./output/
	docker cp tdx-builder:/opt/yocto-output/verdin-image.tar.gz ./output/
	docker cp tdx-builder:/opt/yocto-output/cst.tar.gz ./context/
POPD
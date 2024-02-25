@ECHO OFF
PUSHD %~dp0
	if exists ./output/yocto-state.tar.gz (
		echo "Extracting build state"
		docker cp ./output/yocto-state.tar.gz tdx-builder:/opt/artifacts/
	)
	if exists ./output/fit-keys.tar.gz (
		echo "Extracting build fit image keys"
		docker cp ./output/fit-keys.tar.gz tdx-builder:/opt/artifacts/
	)
POPD
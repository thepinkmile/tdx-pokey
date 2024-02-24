#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
artifacts_directory=${path}/../artifacts
cst_crts_root=${working_directory}/cst
reference_image=tdx-reference-minimal-image

echo "Running in: ${working_directory}"
echo "Script directory: ${path}"

# copy previous output if provided
if [ -f ${artifacts_directory}/verdin-image.tar.gz ]; then
    tar -xzvf ${artifacts_directory}/verdin-image.tar.gz -C ${working_directory}
	rm -f ${artifacts_directory}/verdin-image.tar.gz
fi
# copy previous state
if [ -f ${artifacts_directory}/yocto-state.tar.gz ]; then
    tar -xzvf ${artifacts_directory}/yocto-state.tar.gz -C /opt
	rm -f ${artifacts_directory}/yocto-state.tar.gz
fi

source export

bitbake -k ${reference_image}

mkdir /opt/yocto-output
tar -czvf /opt/yocto-output/yocto-state.tar.gz -C /opt yocto-state
tar -czvf /opt/yocto-output/verdin-image.tar.gz -C ${working_directory} build/deploy/images/verdin-imx8mp/
tar -czvf /opt/yocto-output/cst.tar.gz -C ${working_directory} cst

#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
reference_image=tdx-reference-minimal-image

echo "Running in: ${working_directory}"
echo "Script directory: ${path}"

source export

PARALLEL_MAKE="-j 4" BB_NUMBER_THREADS="4" bitbake -k ${reference_image}

mkdir /opt/yocto-output
tar -czvf /opt/yocto-output/yocto-state.tar.gz /opt/yocto-state/
tar -czvf /opt/yocto-output/verdin-image.tar.gz ${working_directory}/build/deploy/images/verdin-imx8mp/
tar -czvf /opt/yocto-output/cst.tar.gz ${working_directory}/cst/

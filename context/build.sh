#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
reference_image=tdx-reference-minimal-image

echo "Running in: ${working_directory}"
echo "Script directory: ${path}"

source export

PARALLEL_MAKE="-j 3" BB_NUMBER_THREADS="4" bitbake -k ${reference_image}

mv -r ${working_directory}/build/verdin-imx8mp/ /opt/output/

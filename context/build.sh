#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
artifacts_directory=${path}/../artifacts
cst_crts_root=${working_directory}/cst
reference_image=tdx-reference-minimal-image

while [[ $# -gt 0 ]]; do
    case $1 in
        --image)
            shift
            echo "Setting image: $1"
            reference_image=$1
            ;;
        --help)
            echo "##################################"
            echo "### Toradex yocto build script ###"
            echo "##################################"
            echo ""
            echo "./build.sh [--image {image-name}]"
            echo ""
            echo "--image: Default=tdx-reference-minimal-image, This allows for selecting a different bitbake image to be built."
            echo "    Known Image Names: [tdx-reference-minimal-image] [tdx-reference-multimedia-image]"
            echo ""
            echo "##################################"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

echo "Running in: ${working_directory}"
echo "Script directory: ${path}"

# copy previous state
if [ -f ${artifacts_directory}/yocto-state.tar.gz ]; then
    echo "Extracting previous state..."
    tar -xzvf ${artifacts_directory}/yocto-state.tar.gz -C /opt
    rm -f ${artifacts_directory}/yocto-state.tar.gz
fi
# copy previous fit image keys
if [ -f ${artifacts_directory}/fit-keys.tar.gz ]; then
    echo "Extracting previous fit image keys..."
    tar -xzvf ${artifacts_directory}/fit-keys.tar.gz -C ${working_directory}
    rm -f ${artifacts_directory}/fit-keys.tar.gz
fi

source export

bitbake -k ${reference_image}

if ! [ -d /opt/yocto-output ]; then
    mkdir /opt/yocto-output
fi
tar -czvf /opt/yocto-output/yocto-state.tar.gz -C /opt yocto-state/
tar -czvf /opt/yocto-output/verdin-image.tar.gz -C ${working_directory} build/deploy/images/verdin-imx8mp/
tar -czvf /opt/yocto-output/fit-keys.tar.gz -C ${working_directory} build/keys/

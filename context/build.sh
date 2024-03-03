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
    pv ${artifacts_directory}/yocto-state.tar.gz | tar -xzf - -C /opt
    rm -f ${artifacts_directory}/yocto-state.tar.gz
fi
# copy previous fit image keys
if [ -f ${artifacts_directory}/fit-keys.tar.gz ]; then
    echo "Extracting previous fit image keys..."
    pv ${artifacts_directory}/fit-keys.tar.gz | tar -xzf - -C ${working_directory}
    rm -f ${artifacts_directory}/fit-keys.tar.gz
fi

source export
if ! [ -d /opt/yocto-output ]; then
    mkdir /opt/yocto-output
fi

# Generate build graphs
bitbake -g ${reference_image}
if [ -d /opt/yocto-output/dot ]; then
    rm -rf /opt/yocto-output/dot
fi
mkdir /opt/yocto-output/dot
cp -f ${working_directory}/*.dot /opt/yocto-output/dot/
cp -f ${working_directory}/pn-buildlist /opt/yocto-output/dot/
pushd /opt/yocto-output/dot
    dot -Tsvg package-depends.dot > package-depends.svg
    dot -Tsvg pn-depends.dot > pn-depends.svg
    dot -Tsvg task-depends.dot > task-depends.svg
popd
tar cf - -C /opt/yocto-output dot/ | pv -s $(du -sb /opt/yocto-output/dot | awk '{print $1}') | gzip > /opt/yocto-output/yocto-dot.tar.gz

# Perform the build
bitbake -k ${reference_image}
tar cf - -C /opt yocto-state/ | pv -s $(du -sb /opt/yocto-state | awk '{print $1}') | gzip > /opt/yocto-output/yocto-state.tar.gz
tar cf - -C ${working_directory} build/deploy/images/verdin-imx8mp/ | pv -s $(du -sb ${working_directory}build/deploy/images/verdin-imx8mp | awk '{print $1}') | gzip > /opt/yocto-output/verdin-image.tar.gz
tar cf - -C ${working_directory} build/keys/ | pv -s $(du -sb ${working_directory}/build/keys | awk '{print $1}') | gzip > /opt/yocto-output/fit-keys.tar.gz
